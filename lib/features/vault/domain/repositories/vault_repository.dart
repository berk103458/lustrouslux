import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/ebook_entity.dart';

abstract class VaultRepository {
  Stream<List<EbookEntity>> getEbooks();
  // Future<Either<Failure, void>> unlockEbook(String ebookId); // Future scope
}
