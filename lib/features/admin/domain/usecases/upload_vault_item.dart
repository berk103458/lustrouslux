import 'dart:io';
import '../repositories/admin_repository.dart';

class UploadVaultItem {
  final AdminRepository repository;

  UploadVaultItem(this.repository);

  Future<void> call({
    required String title,
    required String author,
    required String description,
    required double price,
    required bool isPremium,
    required String imageUrl,
    required String pdfUrl,
  }) async {
    return await repository.uploadVaultItem(
      title: title,
      author: author,
      description: description,
      price: price,
      isPremium: isPremium,
      imageUrl: imageUrl,
      pdfUrl: pdfUrl,
    );
  }
}
