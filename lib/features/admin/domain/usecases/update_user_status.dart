import '../repositories/admin_repository.dart';

class UpdateUserStatus {
  final AdminRepository repository;

  UpdateUserStatus(this.repository);

  Future<void> call({
    required String uid,
    bool? isPremium,
    bool? isBanned,
  }) async {
    return await repository.updateUserStatus(
      uid: uid,
      isPremium: isPremium,
      isBanned: isBanned,
    );
  }
}
