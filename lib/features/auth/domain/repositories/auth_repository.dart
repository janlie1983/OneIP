import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String companyName,
    required String role,
  });

  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword({required String email});
}
