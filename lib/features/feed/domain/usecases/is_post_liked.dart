import '../repositories/feed_repository.dart';

class IsPostLiked {
  final FeedRepository repository;

  IsPostLiked(this.repository);

  Future<bool> call(String feedId, String uid) {
    return repository.isPostLiked(feedId, uid);
  }
}
