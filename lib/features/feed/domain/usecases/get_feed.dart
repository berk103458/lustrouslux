import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed_entity.dart';
import '../repositories/feed_repository.dart';

class GetFeed {
  final FeedRepository repository;

  GetFeed(this.repository);

  Stream<List<FeedEntity>> call() {
    return repository.getFeed();
  }
}
