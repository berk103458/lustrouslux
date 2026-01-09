import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';
import '../../../auth/domain/entities/user_entity.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> uploadVaultItem({
    required String title,
    required String author,
    required String description,
    required double price,
    required bool isPremium,
    required String imageUrl,
    required String pdfUrl,
  }) async {
    return await remoteDataSource.uploadVaultItem(
      title: title,
      author: author,
      description: description,
      price: price,
      isPremium: isPremium,
      imageUrl: imageUrl,
      pdfUrl: pdfUrl,
    );
  }

  @override
  Future<void> deleteVaultItem(String id) async {
    return await remoteDataSource.deleteVaultItem(id);
  }

  @override
  Future<Either<Failure, void>> deleteFeedItem(String id) async {
    try {
      await remoteDataSource.deleteFeedItem(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> uploadFeedItem({
    required String title,
    required String content,
    required String imageUrl,
  }) async {
    return await remoteDataSource.uploadFeedItem(
      title: title,
      content: content,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<void> initializeSystemDefaults() async {
    return await remoteDataSource.initializeSystemDefaults();
  }

  @override
  Future<void> uploadAppUpdate({
    required File apkFile,
    required String version,
  }) async {
    return await remoteDataSource.uploadAppUpdate(
      apkFile: apkFile,
      version: version,
    );
  }

  @override
  Future<List<UserEntity>> getUsers() async {
    return await remoteDataSource.getUsers();
  }

  @override
  Future<void> updateUserStatus({
    required String uid,
    bool? isPremium,
    bool? isBanned,
  }) async {
    return await remoteDataSource.updateUserStatus(
      uid: uid,
      isPremium: isPremium,
      isBanned: isBanned,
    );
  }

  @override
  Stream<List<Map<String, dynamic>>> getSupportTickets() => remoteDataSource.getSupportTickets();

  @override
  Future<Either<Failure, void>> replyToTicket({required String ticketId, required String userUid, required String response}) async {
    try {
      await remoteDataSource.replyToTicket(ticketId: ticketId, userUid: userUid, response: response);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> closeTicket(String ticketId) async {
    try {
      await remoteDataSource.closeTicket(ticketId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTicket(String ticketId) async {
    try {
      await remoteDataSource.deleteTicket(ticketId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
