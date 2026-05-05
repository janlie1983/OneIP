import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<AuthState> get authStateChanges => _dataSource.authStateChanges;

  @override
  User? get currentUser => _dataSource.currentUser;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _dataSource.signInWithEmail(email: email, password: password);

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String companyName,
    required String role,
  }) =>
      _dataSource.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        companyName: companyName,
        role: role,
      );

  @override
  Future<void> signInWithGoogle() => _dataSource.signInWithGoogle();

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<void> resetPassword({required String email}) =>
      _dataSource.resetPassword(email: email);
}
