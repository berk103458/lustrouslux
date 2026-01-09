import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/feed_entity.dart';

abstract class FeedRepository {
  Stream<List<FeedEntity>> getFeed();
  Stream<List<FeedEntity>> getFavorites(String uid);
  Future<void> likePost(String feedId, String uid);
  Future<void> unlikePost(String feedId, String uid);
  Future<void> addComment(String feedId, String uid, String username, String text);
  Stream<List<Map<String, dynamic>>> getComments(String feedId);
  Future<bool> isPostLiked(String feedId, String uid);
}
