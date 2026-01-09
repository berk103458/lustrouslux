import '../../domain/repositories/admin_repository.dart';

class GetSupportTickets {
  final AdminRepository repository;

  GetSupportTickets(this.repository);

  Stream<List<Map<String, dynamic>>> call() {
    return repository.getSupportTickets();
  }
}
