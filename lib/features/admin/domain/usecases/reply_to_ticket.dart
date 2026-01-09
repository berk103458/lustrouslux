import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/admin_repository.dart';

class ReplyToTicket {
  final AdminRepository repository;

  ReplyToTicket(this.repository);

  Future<Either<Failure, void>> call(String ticketId, String userUid, String response) {
    return repository.replyToTicket(ticketId: ticketId, userUid: userUid, response: response);
  }
}
