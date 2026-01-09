import '../repositories/feed_repository.dart';

class AddComment {
  final FeedRepository repository;

  AddComment(this.repository);

  Future<void> call(String feedId, String uid, String username, String text) async {
    await repository.addComment(feedId, uid, username, text);
  }
}
