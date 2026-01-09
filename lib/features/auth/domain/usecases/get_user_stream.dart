import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetUserStream {
  final AuthRepository repository;

  GetUserStream(this.repository);

  Stream<UserEntity> call(String uid) {
    return repository.getUserStream(uid);
  }
}
