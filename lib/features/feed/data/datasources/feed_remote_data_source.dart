import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/failures.dart';
import '../models/feed_model.dart';

abstract class FeedRemoteDataSource {
  Stream<List<FeedModel>> getFeed();
  Stream<List<FeedModel>> getFavorites(String uid);
  Future<void> likePost(String feedId, String uid);
  Future<void> unlikePost(String feedId, String uid);
  Future<void> addComment(String feedId, String uid, String username, String text);
  Stream<List<Map<String, dynamic>>> getComments(String feedId);
  Future<bool> isPostLiked(String feedId, String uid);
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final FirebaseFirestore firestore;

  FeedRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<FeedModel>> getFeed() {
    return firestore
        .collection('feed')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FeedModel.fromSnapshot(doc))
          .toList();
    }).handleError((error) {
       throw const ServerFailure('Failed to fetch feed stream');
    });
  }

  @override
  Future<void> likePost(String feedId, String uid) async {
    final feedRef = firestore.collection('feed').doc(feedId);
    final likeRef = feedRef.collection('likes').doc(uid);
    final userFavRef = firestore.collection('users').doc(uid).collection('favorites').doc(feedId);

    return firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(feedRef);
      if (!snapshot.exists) throw Exception("Post does not exist!");

      final likeSnapshot = await transaction.get(likeRef);
      if (likeSnapshot.exists) return; // Already liked

      // Update count locally to transaction
      int newLikes = (snapshot.data()?['likes'] ?? 0) + 1;
      
      transaction.update(feedRef, {'likes': newLikes});
      transaction.set(likeRef, {'likedAt': FieldValue.serverTimestamp()});
      
      // Add to user favorites
      transaction.set(userFavRef, {
        'feedId': feedId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> unlikePost(String feedId, String uid) async {
    final feedRef = firestore.collection('feed').doc(feedId);
    final likeRef = feedRef.collection('likes').doc(uid);
    final userFavRef = firestore.collection('users').doc(uid).collection('favorites').doc(feedId);

    return firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(feedRef);
      if (!snapshot.exists) throw Exception("Post does not exist!");

      final likeSnapshot = await transaction.get(likeRef);
      if (!likeSnapshot.exists) return; // Not liked

      int currentLikes = snapshot.data()?['likes'] ?? 0;
      int newLikes = currentLikes > 0 ? currentLikes - 1 : 0;
      
      transaction.update(feedRef, {'likes': newLikes});
      transaction.delete(likeRef);
      
      // Remove from user favorites
      transaction.delete(userFavRef);
    });
  }
  
  @override
  Stream<List<FeedModel>> getFavorites(String uid) {
     return firestore.collection('users').doc(uid).collection('favorites')
         .orderBy('addedAt', descending: true)
         .snapshots()
         .asyncMap((snapshot) async {
             // Get list of feed IDs
             final feedIds = snapshot.docs.map((doc) => doc.id).toList();
             
             if (feedIds.isEmpty) return [];
             
             // Fetch actual feed items
             // Note: whereIn is limited to 10. For larger lists, we might need multiple queries
             // or fetching individual docs. For MVP, fetching individually is safer for logic simplicity
             // provided list isn't huge. Or simpler: fetch all feed and filter? No, inefficient.
             // Best for MVP: Loop and get.
             
             List<FeedModel> favorites = [];
             for (var id in feedIds) {
               final doc = await firestore.collection('feed').doc(id).get();
               if (doc.exists) {
                 favorites.add(FeedModel.fromSnapshot(doc));
               }
             }
             return favorites;
         });
  }

  @override
  Future<void> addComment(String feedId, String uid, String username, String text) async {
    await firestore.collection('feed').doc(feedId).collection('comments').add({
      'uid': uid,
      'username': username,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getComments(String feedId) {
    return firestore
        .collection('feed')
        .doc(feedId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }

  @override
  Future<bool> isPostLiked(String feedId, String uid) async {
    final doc = await firestore.collection('feed').doc(feedId).collection('likes').doc(uid).get();
    return doc.exists;
  }
}
