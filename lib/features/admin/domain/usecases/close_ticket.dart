import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

class CloseTicket {
  final AdminRepository repository;

  CloseTicket(this.repository);

  Future<Either<Failure, void>> call(String ticketId) {
    return repository.closeTicket(ticketId);
  }
}
