import '../../domain/repositories/admin_repository.dart';

class DeleteVaultItem {
  final AdminRepository repository;

  DeleteVaultItem(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteVaultItem(id);
  }
}
