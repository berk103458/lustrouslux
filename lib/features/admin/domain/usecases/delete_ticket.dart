import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

class DeleteTicket {
  final AdminRepository repository;

  DeleteTicket(this.repository);

  Future<Either<Failure, void>> call(String ticketId) async {
    return await repository.deleteTicket(ticketId);
  }
}
