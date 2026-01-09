import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SendUserMessage {
  final AuthRepository repository;

  SendUserMessage(this.repository);

  Future<Either<Failure, void>> call(String ticketId, String message) {
    return repository.sendUserMessage(ticketId, message);
  }
}
