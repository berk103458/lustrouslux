import '../repositories/feed_repository.dart';
import '../entities/feed_entity.dart';

class GetFavorites {
  final FeedRepository repository;

  GetFavorites(this.repository);

  Stream<List<FeedEntity>> call(String uid) {
    return repository.getFavorites(uid);
  }
}
