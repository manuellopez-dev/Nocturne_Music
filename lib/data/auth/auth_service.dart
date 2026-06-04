import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _scopes = [
    'https://www.googleapis.com/auth/youtube',
    'https://www.googleapis.com/auth/youtube.readonly',
    'email',
    'profile',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _idTokenKey = 'id_token';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';

  Future<bool> login() async {
    try {
      print('[Auth] Iniciando Google Sign In...');

      final account = await _googleSignIn.signIn();
      if (account == null) {
        print('[Auth] Usuario canceló el login');
        return false;
      }

      print('[Auth] Usuario: ${account.email}');

      final auth = await account.authentication;
      final accessToken = auth.accessToken;
      final idToken = auth.idToken;

      if (accessToken == null) {
        print('[Auth] No se obtuvo access token');
        return false;
      }

      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _idTokenKey, value: idToken ?? '');
      await _storage.write(key: _userEmailKey, value: account.email);
      await _storage.write(key: _userNameKey, value: account.displayName ?? '');

      print('[Auth] Login exitoso: ${account.email}');
      return true;
    } catch (e) {
      print('[Auth] Error: $e');
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    // Intenta renovar el token automáticamente
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        if (auth.accessToken != null) {
          await _storage.write(
              key: _accessTokenKey, value: auth.accessToken!);
          return auth.accessToken;
        }
      }
    } catch (e) {
      print('[Auth] Error renovando token: $e');
    }
    return await _storage.read(key: _accessTokenKey);
  }

  Future<bool> isLoggedIn() async {
    try {
      final isSignedIn = await _googleSignIn.isSignedIn();
      return isSignedIn;
    } catch (e) {
      final token = await _storage.read(key: _accessTokenKey);
      return token != null && token.isNotEmpty;
    }
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _storage.deleteAll();
    print('[Auth] Sesión cerrada');
  }

  Future<bool> trySilentSignIn() async {
  try {
    final account = await _googleSignIn.signInSilently();
    if (account == null) {
      print('[Auth] No hay sesión previa, se requiere login manual');
      await _storage.deleteAll(); // limpia tokens viejos
      return false;
    }

    final auth = await account.authentication;
    if (auth.accessToken == null) {
      print('[Auth] signInSilently OK pero sin accessToken');
      await _storage.deleteAll();
      return false;
    }

    // Guarda el token fresco
    await _storage.write(key: _accessTokenKey, value: auth.accessToken!);
    await _storage.write(key: _idTokenKey, value: auth.idToken ?? '');
    await _storage.write(key: _userEmailKey, value: account.email);
    await _storage.write(key: _userNameKey, value: account.displayName ?? '');

    print('[Auth] Silent sign-in OK: ${account.email}');
    print('[Auth] Token renovado: ${auth.accessToken!.substring(0, 20)}...');
    return true;
  } catch (e) {
    print('[Auth] Error en trySilentSignIn: $e');
    await _storage.deleteAll();
    return false;
  }
}
}