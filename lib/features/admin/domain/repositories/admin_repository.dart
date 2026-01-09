import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class AdminRepository {
  Future<void> uploadVaultItem({
    required String title,
    required String author,
    required String description,
    required double price,
    required bool isPremium,
    required String imageUrl,
    required String pdfUrl,
  });

  Future<void> deleteVaultItem(String id);
  
  Future<void> deleteFeedItem(String id);
  Stream<List<Map<String, dynamic>>> getSupportTickets();
  Future<Either<Failure, void>> replyToTicket({required String ticketId, required String userUid, required String response});
  Future<Either<Failure, void>> closeTicket(String ticketId);
  Future<Either<Failure, void>> deleteTicket(String ticketId);

  Future<void> uploadFeedItem({
    required String title,
    required String content,
    required String imageUrl,
  });

  Future<void> initializeSystemDefaults();

  Future<void> uploadAppUpdate({
    required File apkFile,
    required String version,
  });

  Future<List<UserEntity>> getUsers();

  Future<void> updateUserStatus({
    required String uid,
    bool? isPremium,
    bool? isBanned,
  });
}
