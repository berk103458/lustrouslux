import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class CreateTicket {
  final AuthRepository repository;

  CreateTicket(this.repository);

  Future<Either<Failure, void>> call(String uid, String email, String subject, String message) {
    return repository.createSupportTicket(uid, email, subject, message);
  }
}
