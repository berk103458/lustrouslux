import 'package:equatable/equatable.dart';
import '../../domain/entities/ebook_entity.dart';

abstract class VaultState extends Equatable {
  const VaultState();

  @override
  List<Object> get props => [];
}

class VaultInitial extends VaultState {}

class VaultLoading extends VaultState {}

class VaultLoaded extends VaultState {
  final List<EbookEntity> ebooks;

  const VaultLoaded(this.ebooks);

  @override
  List<Object> get props => [ebooks];
}

class VaultError extends VaultState {
  final String message;

  const VaultError(this.message);

  @override
  List<Object> get props => [message];
}
