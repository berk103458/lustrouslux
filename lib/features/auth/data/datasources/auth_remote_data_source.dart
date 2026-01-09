import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password);
  Future<void> signOut();
  Future<UserModel> getCurrentUser();
  Stream<User?> get authStateChanges;
  Future<void> sendPasswordResetEmail(String email);
  Future<void> createSupportTicket(String uid, String email, String subject, String message);
  Future<void> sendUserMessage(String ticketId, String message);
  Stream<List<Map<String, dynamic>>> getUserTickets(String uid);
  Stream<UserModel> getUserStream(String uid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({required this.auth, required this.firestore});

  @override
  Stream<User?> get authStateChanges => auth.authStateChanges();

  @override
  Future<UserModel> signIn(String email, String password) async {
    final userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Check Email Verification
    if (!userCredential.user!.emailVerified) {
        await auth.signOut(); // Force logout
        throw FirebaseAuthException(
            code: 'email-not-verified',
            message: 'Please verify your email address before logging in.'
        );
    }

    // Fetch extra data from Firestore
    final uid = userCredential.user!.uid;
    final doc = await firestore.collection('users').doc(uid).get();
    
    if (doc.exists) {
        return UserModel.fromSnapshot(doc);
    } else {
        // Fallback if data is missing, though signUp should ensure it exists
        return UserModel(uid: uid, email: email);
    }
  }

  @override
  Future<UserModel> signUp(String email, String password) async {
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Send Activation Email
    await userCredential.user!.sendEmailVerification();

    final UserModel newUser = UserModel(
      uid: userCredential.user!.uid,
      email: email,
      role: 'user', // Default
      isApproved: false, // Default
    );

    await firestore
        .collection('users')
        .doc(newUser.uid)
        .set(newUser.toDocument());

    // CRITICAL: Prevent Auto-Login
    await auth.signOut();

    return newUser;
  }

  @override
  Future<void> signOut() async {
    return await auth.signOut();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final doc = await firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return UserModel(uid: currentUser.uid, email: currentUser.email!);
    } else {
      throw Exception('No user found');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> createSupportTicket(String uid, String email, String subject, String message) async {
    await firestore.collection('support_tickets').add({
      'uid': uid,
      'email': email,
      'subject': subject,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'messages': [
        {
          'sender': 'user',
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ],
    });
  }

  @override
  Future<void> sendUserMessage(String ticketId, String message) async {
    final ticketRef = firestore.collection('support_tickets').doc(ticketId);
    await ticketRef.update({
      'lastUpdated': FieldValue.serverTimestamp(),
      'status': 'open', // Re-open if closed? Or just update. Let's keep it 'open' or 'user_reply'.
      'messages': FieldValue.arrayUnion([
        {
          'sender': 'user',
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ]),
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getUserTickets(String uid) {
    return firestore.collection('support_tickets')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data(),
            }).toList();
          
          // Sort client-side to avoid Firestore Index requirements for MVP
          docs.sort((a, b) {
             final tA = (a['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime(1970);
             final tB = (b['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime(1970);
             return tB.compareTo(tA); // Descending
          });
          
          return docs;
        });
  }

  @override
  Stream<UserModel> getUserStream(String uid) {
    return firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      } else {
        // Return a default user model if the document doesn't exist yet to prevent stream crashes
        return UserModel(uid: uid, email: '', role: 'user');
      }
    });
  }
}
