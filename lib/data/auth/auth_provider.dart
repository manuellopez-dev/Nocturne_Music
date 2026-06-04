import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState(isLoading: true)) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Intenta renovar silenciosamente la sesión de Google
      final refreshed = await _authService.trySilentSignIn();
      state = state.copyWith(isLoggedIn: refreshed, isLoading: false);
    } catch (e) {
      print('[Auth] Error en checkLoginStatus: $e');
      state = state.copyWith(isLoggedIn: false, isLoading: false);
    }
  }

  Future<void> login() async {
    state = state.copyWith(isLoading: true, error: null);
    final success = await _authService.login();
    state = state.copyWith(
      isLoggedIn: success,
      isLoading: false,
      error: success ? null : 'No se pudo iniciar sesión',
    );
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(service);
});