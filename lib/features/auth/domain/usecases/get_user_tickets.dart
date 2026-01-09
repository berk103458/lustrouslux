import '../repositories/auth_repository.dart';

class GetUserTickets {
  final AuthRepository repository;

  GetUserTickets(this.repository);

  Stream<List<Map<String, dynamic>>> call(String uid) {
    return repository.getUserTickets(uid);
  }
}
