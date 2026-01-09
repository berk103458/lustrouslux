import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/logout_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

import 'dart:async';
import '../../domain/usecases/get_user_stream.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final CheckAuthStatus checkAuthStatus;
  final LogoutUser logoutUser;
  final GetUserStream getUserStream;

  StreamSubscription<UserEntity>? _userSubscription;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.checkAuthStatus,
    required this.logoutUser,
    required this.getUserStream,
  }) : super(AuthUninitialized()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<SignUpRequested>(_onSignUpRequested);
    on<LoggedOut>(_onLoggedOut);
    on<UserUpdated>(_onUserUpdated);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final result = await checkAuthStatus(const NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        _subscribeToUserStream(user.uid);
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUser(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        _subscribeToUserStream(user.uid);
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUser(RegisterParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(const AuthError("Registration Successful! Please verify your email to log in.")),
    );
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
      await _userSubscription?.cancel();
      await logoutUser(const NoParams());
      emit(AuthUnauthenticated());
  }

  void _onUserUpdated(UserUpdated event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }

  void _subscribeToUserStream(String uid) {
    _userSubscription?.cancel();
    _userSubscription = getUserStream(uid).listen((user) {
      add(UserUpdated(user));
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
