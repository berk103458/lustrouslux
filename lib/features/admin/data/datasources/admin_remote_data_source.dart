import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/services/backblaze_service.dart';
import '../../../auth/data/models/user_model.dart';

abstract class AdminRemoteDataSource {
  Future<void> uploadVaultItem({
    required String title,
    required String author,
    required String description,
    required double price,
    required bool isPremium,
    required String imageUrl,
    required String pdfUrl,
  });

  Future<void> deleteVaultItem(String id);

  Future<void> deleteFeedItem(String id);
  
  Future<void> uploadFeedItem({
    required String title,
    required String content,
    required String imageUrl,
  });

  Future<void> initializeSystemDefaults();

  Future<void> uploadAppUpdate({
    required File apkFile,
    required String version,
  });

  Future<List<UserModel>> getUsers();

  Future<void> updateUserStatus({
    required String uid,
    bool? isPremium,
    bool? isBanned,
  });

  Stream<List<Map<String, dynamic>>> getSupportTickets();
  Future<void> replyToTicket({required String ticketId, required String userUid, required String response});
  Future<void> closeTicket(String ticketId);
  Future<void> deleteTicket(String ticketId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage firebaseStorage;
  final BackblazeService backblazeService;

  AdminRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseStorage,
    required this.backblazeService,
  });

  @override
  Stream<List<Map<String, dynamic>>> getSupportTickets() {
    return firestore.collection('support_tickets')
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data(),
            }).toList());
  }

  @override
  Future<void> replyToTicket({required String ticketId, required String userUid, required String response}) async {
    // 1. Update Ticket
    final ticketRef = firestore.collection('support_tickets').doc(ticketId);
    await ticketRef.update({
      'status': 'resolved',
      'lastUpdated': FieldValue.serverTimestamp(),
      'messages': FieldValue.arrayUnion([
        {
          'sender': 'admin',
          'message': response,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ]),
    });

    // 2. Send Notification to User
    final notifRef = firestore.collection('users').doc(userUid).collection('notifications').doc();
    await notifRef.set({
      'title': 'Support Request Update',
      'body': 'New reply from support: "$response"',
      'type': 'support_reply',
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
      'relatedId': ticketId,
      'timestamp': FieldValue.serverTimestamp(),
      'relatedId': ticketId,
    });
  }

  @override
  Future<void> closeTicket(String ticketId) async {
    await firestore.collection('support_tickets').doc(ticketId).update({
      'status': 'closed',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteTicket(String ticketId) async {
    await firestore.collection('support_tickets').doc(ticketId).delete();
  }

  @override
  Future<void> uploadVaultItem({
    required String title,
    required String author,
    required String description,
    required double price,
    required bool isPremium,
    required String imageUrl,
    required String pdfUrl,
  }) async {
    // Save to Firestore directly with provided URLs
    await firestore.collection('ebooks').add({
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'isPremium': isPremium,
      'coverUrl': imageUrl,
      'pdfUrl': pdfUrl, // Make sure this matches EbookModel field (pdfUrl)
      'isLocked': isPremium, // Map isPremium to isLocked for compatibility
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  @override
  Future<void> deleteVaultItem(String id) async {
    await firestore.collection('ebooks').doc(id).delete();
  }

  @override
  Future<void> deleteFeedItem(String id) async {
    await firestore.collection('feed').doc(id).delete();
  }

  @override
  Future<void> uploadFeedItem({
    required String title,
    required String content,
    required String imageUrl,
  }) async {
    // Save to Firestore directly with provided URL
    await firestore.collection('feed').add({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
    });
  }

  @override
  Future<void> initializeSystemDefaults() async {
    // 1. Create App Config (For Updates)
    await firestore.collection('app_config').doc('maintenance').set({
      'latest_version': '1.1.0', // Set match current version initially
      'update_url': 'https://lustrouslux.com', // App redirects here
      // 'download_url': '', // Don't wipe this on init
      'force_update': false,
      'maintenance_mode': false,
    }, SetOptions(merge: true));

    // 2. Create Sample Vault Item (Optional)
    // Only if collection is empty to avoid duplicates, but for setup script we can overwrite or add new.
    // For simplicity, we just ensure the collection exists by adding a doc if none exists, 
    // but Firestore creates collections implicitly. 
    // We will just log/ensure the structure is ready.
  }

  @override
  Future<void> uploadAppUpdate({
    required File apkFile,
    required String version,
  }) async {
    // 1. Upload APK to Backblaze B2
    final b2Service = BackblazeService();
    // Ensure no spaces or special chars in version for filename safety
    final safeVersion = version.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w.-]'), ''); 
    final fileName = 'LustrousLux_v$safeVersion.apk';
    final downloadUrl = await b2Service.uploadFile(apkFile, fileName);

    // 2. Update Config
    await firestore.collection('app_config').doc('maintenance').update({
      'latest_version': version,
      'download_url': downloadUrl,
    });
  }

  @override
  Future<List<UserModel>> getUsers() async {
    final snapshot = await firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<void> updateUserStatus({
    required String uid,
    bool? isPremium,
    bool? isBanned,
  }) async {
    final Map<String, dynamic> data = {};
    if (isPremium != null) data['isPremium'] = isPremium;
    if (isBanned != null) data['isBanned'] = isBanned;
    
    if (data.isNotEmpty) {
      await firestore.collection('users').doc(uid).update(data);
    }
  }
}
