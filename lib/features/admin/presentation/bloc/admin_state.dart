import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminUploading extends AdminState {}

class AdminUsersLoaded extends AdminState {
  final List<UserEntity> users;

  const AdminUsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class AdminSuccess extends AdminState {
  final String message;

  const AdminSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AdminFailure extends AdminState {
  final String error;

  const AdminFailure(this.error);

  @override
  List<Object> get props => [error];
}
