import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ebook_entity.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_ebooks.dart';
import 'vault_event.dart';
import 'vault_state.dart';

class VaultBloc extends Bloc<VaultEvent, VaultState> {
  final GetEbooks getEbooks;

  StreamSubscription<List<EbookEntity>>? _ebooksSubscription;

  VaultBloc({required this.getEbooks}) : super(VaultInitial()) {
    on<LoadVault>(_onLoadVault);
    on<VaultUpdated>(_onVaultUpdated);
    on<VaultErrorEvent>((event, emit) => emit(VaultError(event.message)));
  }

  void _onLoadVault(LoadVault event, Emitter<VaultState> emit) {
    emit(VaultLoading());
    _ebooksSubscription?.cancel();
    _ebooksSubscription = getEbooks().listen(
      (ebooks) => add(VaultUpdated(ebooks)),
      onError: (error) => add(VaultErrorEvent(error.toString())),
    );
  }

  void _onVaultUpdated(VaultUpdated event, Emitter<VaultState> emit) {
    emit(VaultLoaded(event.ebooks));
  }
  
  // Also need to handle Error Event if I add it
  @override
  Future<void> close() {
    _ebooksSubscription?.cancel();
    return super.close();
  }
}
