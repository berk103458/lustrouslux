import 'dart:io';
import '../repositories/admin_repository.dart';

class UploadAppUpdate {
  final AdminRepository repository;

  UploadAppUpdate(this.repository);

  Future<void> call({
    required File apkFile,
    required String version,
  }) async {
    return await repository.uploadAppUpdate(
      apkFile: apkFile,
      version: version,
    );
  }
}
