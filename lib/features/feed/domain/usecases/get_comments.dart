import '../repositories/feed_repository.dart';

class GetComments {
  final FeedRepository repository;

  GetComments(this.repository);

  Stream<List<Map<String, dynamic>>> call(String feedId) {
    return repository.getComments(feedId);
  }
}
