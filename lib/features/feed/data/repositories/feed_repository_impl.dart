import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/feed_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_data_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;

  FeedRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<FeedEntity>> getFeed() => remoteDataSource.getFeed();

  @override
  Stream<List<FeedEntity>> getFavorites(String uid) => remoteDataSource.getFavorites(uid);

  @override
  Future<void> likePost(String feedId, String uid) => remoteDataSource.likePost(feedId, uid);

  @override
  Future<void> unlikePost(String feedId, String uid) => remoteDataSource.unlikePost(feedId, uid);

  @override
  Future<void> addComment(String feedId, String uid, String username, String text) => remoteDataSource.addComment(feedId, uid, username, text);

  @override
  Stream<List<Map<String, dynamic>>> getComments(String feedId) => remoteDataSource.getComments(feedId);

  @override
  Future<bool> isPostLiked(String feedId, String uid) => remoteDataSource.isPostLiked(feedId, uid);
}
