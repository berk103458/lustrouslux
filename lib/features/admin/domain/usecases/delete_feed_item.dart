import '../../domain/repositories/admin_repository.dart';

class DeleteFeedItem {
  final AdminRepository repository;

  DeleteFeedItem(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteFeedItem(id);
  }
}
