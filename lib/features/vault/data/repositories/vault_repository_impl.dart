import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ebook_entity.dart';
import '../../domain/repositories/vault_repository.dart';
import '../datasources/vault_remote_data_source.dart';

class VaultRepositoryImpl implements VaultRepository {
  final VaultRemoteDataSource remoteDataSource;

  VaultRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<EbookEntity>> getEbooks() {
    return remoteDataSource.getEbooks();
  }
}
