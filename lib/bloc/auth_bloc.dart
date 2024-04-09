import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/* Bloc이벤트 정의 */
// 회원가입, 로그인, 로그아웃
abstract class AuthenticationEvent {}

class SignUpRequested extends AuthenticationEvent {
  final String email;
  final String password;

  SignUpRequested({required this.email, required this.password});
}

class LoginRequested extends AuthenticationEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class LogoutRequested extends AuthenticationEvent {}

/* Bloc상태 정의 */
abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  final User user;

  AuthenticationSuccess({required this.user});
}

class AuthenticationSignUpSuccess extends AuthenticationState {}

class AuthenticationLoginSuccess extends AuthenticationState {}

class AuthenticationFailure extends AuthenticationState {
  final String message;

  AuthenticationFailure({required this.message});
}

/* Bloc Class */
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuth _firebaseAuth;

  AuthenticationBloc(this._firebaseAuth) : super(AuthenticationInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthenticationSignUpSuccess());
      emit(AuthenticationSuccess(user: _firebaseAuth.currentUser!));
    } on FirebaseAuthException catch (e) {
      emit(AuthenticationFailure(message: e.message ?? 'Sign Up Failed'));
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      //emit(AuthenticationLoginSuccess(user: userCredential.user!));
      emit(AuthenticationLoginSuccess());
      emit(AuthenticationSuccess(user: userCredential.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthenticationFailure(message: e.message ?? 'Login Failed'));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await _firebaseAuth.signOut();
      emit(AuthenticationInitial());
    } catch (e) {
      emit(AuthenticationFailure(message: 'Logout Failed: ${e.toString()}'));
    }
  }
}
