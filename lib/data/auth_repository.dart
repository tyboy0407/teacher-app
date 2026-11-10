import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {
  const AppUser({required this.id, this.email});

  final String id;
  final String? email;
}

/// 帳號服務。未連線 Supabase 時用 [AuthUnavailableRepository],
/// App 顯示連線引導而不是登入表單。
abstract class AuthRepository {
  /// 是否有後端可用(未連線 Supabase 時為 false)
  bool get isAvailable;

  AppUser? get currentUser;

  Stream<AppUser?> authStateChanges();

  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> signUp({required String email, required String password});

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}

class AuthUnavailableRepository implements AuthRepository {
  Never _unsupported() => throw StateError('尚未連線 Supabase,無法使用帳號功能');

  @override
  bool get isAvailable => false;

  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> authStateChanges() => Stream<AppUser?>.value(null);

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async => _unsupported();

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async => _unsupported();

  @override
  Future<void> sendPasswordReset(String email) async => _unsupported();

  @override
  Future<void> signOut() async {}
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  AppUser? _map(User? user) =>
      user == null ? null : AppUser(id: user.id, email: user.email);

  @override
  bool get isAvailable => true;

  @override
  AppUser? get currentUser => _map(_client.auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() =>
      _client.auth.onAuthStateChange.map((event) => _map(event.session?.user));

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
