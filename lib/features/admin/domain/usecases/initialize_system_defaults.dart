import '../repositories/admin_repository.dart';

class InitializeSystemDefaults {
  final AdminRepository repository;

  InitializeSystemDefaults(this.repository);

  Future<void> call() async {
    return await repository.initializeSystemDefaults();
  }
}
