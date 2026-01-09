// Firebase Configuration
// !!! REPLACE WITH YOUR FIREBASE CONFIG FROM FLUTTER !!!
const firebaseConfig = {
    apiKey: "AIzaSyAgoWz1lwNGhunRzCl-qtgALZcctfGF_xI",
    authDomain: "programolur.firebaseapp.com",
    projectId: "programolur",
    storageBucket: "programolur.firebasestorage.app",
    messagingSenderId: "746136349673",
    appId: "1:746136349673:web:fbc2cd5a8732420a33f978"
};

// Initialize Firebase
try {
    firebase.initializeApp(firebaseConfig);
    const db = firebase.firestore();
    const auth = firebase.auth();

    // DOM Elements
    const androidVersionEl = document.getElementById('android-version');
    const androidBtn = document.getElementById('android-btn');
    const systemStatus = document.getElementById('system-status');

    // Authenticate anonymously to bypass security rules
    auth.signInAnonymously()
        .then(() => {
            console.log("Connected to secure network.");
            // Fetch Version Info
            db.collection('app_config').doc('maintenance')
                .onSnapshot((doc) => {
                    if (doc.exists) {
                        const data = doc.data();

                        // Update Maintenance Status
                        if (data.maintenance_mode) {
                            systemStatus.innerText = "SYSTEM MAINTENANCE";
                            systemStatus.style.color = "red";
                            document.querySelector('.dot').style.backgroundColor = "red";
                            document.querySelector('.dot').style.boxShadow = "0 0 5px red";
                        } else {
                            systemStatus.innerText = "SYSTEM ONLINE";
                            systemStatus.style.color = "#00ff00";
                        }

                        // Update Android Version & Link
                        const version = data.latest_version || 'Unknown';
                        const url = data.download_url || '#';

                        androidVersionEl.innerText = `Latest: v${version}`;

                        if (url && url !== '#') {
                            androidBtn.href = url;
                            androidBtn.classList.remove('disabled');
                            androidBtn.querySelector('span').innerText = "DOWNLOAD APK";
                        } else {
                            androidBtn.classList.add('disabled');
                            androidBtn.querySelector('span').innerText = "COMING SOON";
                        }
                    }
                }, (error) => {
                    console.error("Error fetching updates:", error);
                    androidVersionEl.innerText = "Error: " + error.code; // Show exact Firestore error
                });
        })
        .catch((error) => {
            console.error("Authentication Failed:", error);
            androidVersionEl.innerText = "Auth Error: " + error.code; // Show exact Auth error
        });

} catch (e) {
    console.error("Firebase Init Error:", e);
}
