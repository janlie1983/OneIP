import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).whenOrNull(
        data: (state) => state.session?.user,
      );
});

final currentProfileProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final data = await SupabaseConfig.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();
  if (data == null) return null;
  return UserModel.fromMap({...data, 'email': user.email ?? ''});
});

final userRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(currentProfileProvider).whenOrNull(
            data: (profile) => profile?.role,
          ) ??
      UserRole.guest;
});

final hasPermissionProvider =
    FutureProvider.family<bool, String>((ref, permission) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  final result = await SupabaseConfig.client.rpc(
    'has_permission',
    params: {'user_id': user.id, 'permission_name': permission},
  );
  return result as bool? ?? false;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider).isAdmin;
});

final isSupplyProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider).isSupply;
});

final isDemandProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider).isDemand;
});
