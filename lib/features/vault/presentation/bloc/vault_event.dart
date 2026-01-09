import 'package:equatable/equatable.dart';
import '../../domain/entities/ebook_entity.dart';

abstract class VaultEvent extends Equatable {
  const VaultEvent();

  @override
  List<Object> get props => [];
}

class LoadVault extends VaultEvent {}

class VaultUpdated extends VaultEvent {
  final List<EbookEntity> ebooks;
  const VaultUpdated(this.ebooks);
  @override
  List<Object> get props => [ebooks];
}

class VaultErrorEvent extends VaultEvent {
  final String message;
  const VaultErrorEvent(this.message);
  @override
  List<Object> get props => [message];
}
