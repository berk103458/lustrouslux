import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ebook_entity.dart';
import '../repositories/vault_repository.dart';

class GetEbooks {
  final VaultRepository repository;

  GetEbooks(this.repository);

  Stream<List<EbookEntity>> call() {
    return repository.getEbooks();
  }
}
