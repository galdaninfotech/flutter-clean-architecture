import 'package:flutter_application_1/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:flutter_application_1/core/usecase/usecase.dart';
import 'package:flutter_application_1/core/common/entities/user.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/current_user.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/user_login.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserLogin _userLogin;
  final UserSignUp _userSignUp;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;

  AuthBloc ({
    required UserLogin userLogin,
    required UserSignUp userSignUp,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
  }): _userLogin = userLogin,
      _userSignUp = userSignUp,
      _currentUser = currentUser,
      _appUserCubit = appUserCubit,
      super(AuthInitial()) {
    on<AuthEvent> ((_, emit) => emit(AuthLoading()));
    on<AuthLogin> (_onAuthLogin);
    on<AuthSignUp> (_onAuthSignUp);
    on<AuthIsUserLoggedIn> (_isUserLoggedIn);
  }

  void _onAuthLogin(
    AuthLogin event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userLogin(
      UserLoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _onAuthSignUp(
    AuthSignUp event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userSignUp(
      UserSignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _emitAuthSuccess(
    User user,
    Emitter<AuthState> emit,
  ) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }


}