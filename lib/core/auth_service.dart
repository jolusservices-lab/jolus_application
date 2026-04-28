import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // Si estamos en Windows, usamos el flujo de Supabase OAuth que abre el navegador
      if (Platform.isWindows) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'io.supabase.flutter://callback',
        );
        return null;
      }

      // Flujo nativo para Android/iOS (requiere google_sign_in)
      const webClientId = '263098935601-sqajrf72d84tq0ili7f0ar11a54v7igk.apps.googleusercontent.com';
      const iosClientId = '263098935601-v9usisiabaemj9gtmrnerr8m6uct05q2.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: Platform.isIOS ? iosClientId : webClientId,
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'No se pudo obtener el token de Google';
      }

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      print('Error en Google Sign In: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
