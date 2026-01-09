import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/failures.dart';
import '../models/ebook_model.dart';

abstract class VaultRemoteDataSource {
  Stream<List<EbookModel>> getEbooks();
}

class VaultRemoteDataSourceImpl implements VaultRemoteDataSource {
  final FirebaseFirestore firestore;

  VaultRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<EbookModel>> getEbooks() {
    return firestore.collection('ebooks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EbookModel.fromSnapshot(doc)).toList();
    }).handleError((error) {
       throw const ServerFailure('Failed to fetch ebooks stream');
    });
  }
}
