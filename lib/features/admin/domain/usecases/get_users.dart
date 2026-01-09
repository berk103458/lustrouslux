import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/admin_repository.dart';

class GetUsers {
  final AdminRepository repository;

  GetUsers(this.repository);

  Future<List<UserEntity>> call() async {
    return await repository.getUsers();
  }
}
