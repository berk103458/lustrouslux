import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
  Future<Either<Failure, UserEntity>> signUp(String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Stream<UserEntity> getUserStream(String uid);
  Future<Either<Failure, void>> createSupportTicket(String uid, String email, String subject, String message);
  Future<Either<Failure, void>> sendUserMessage(String ticketId, String message);
  Stream<List<Map<String, dynamic>>> getUserTickets(String uid);
}
