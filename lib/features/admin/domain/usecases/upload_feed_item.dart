import 'dart:io';
import '../repositories/admin_repository.dart';

class UploadFeedItem {
  final AdminRepository repository;

  UploadFeedItem(this.repository);

  Future<void> call({
    required String title,
    required String content,
    required String imageUrl,
  }) async {
    return await repository.uploadFeedItem(
      title: title,
      content: content,
      imageUrl: imageUrl,
    );
  }
}
