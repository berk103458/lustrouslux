import '../repositories/feed_repository.dart';

class ToggleLike {
  final FeedRepository repository;

  ToggleLike(this.repository);

  Future<void> call(String feedId, String uid, bool isLiked) async {
    if (isLiked) {
      await repository.unlikePost(feedId, uid);
    } else {
      await repository.likePost(feedId, uid);
    }
  }
}
