import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service for DiSensor app.
/// Supports: Email/Password, Google OAuth, Apple Sign-In, and Anonymous mode.
class AuthService extends ChangeNotifier {
  final SupabaseClient _client;

  User? _currentUser;
  bool _isAnonymous = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Persistence keys
  static const String _anonModeKey = 'auth_anonymous_mode';

  AuthService(this._client) {
    _initAuth();
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAnonymous => _isAnonymous;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if user email is verified
  bool get isEmailVerified => _currentUser?.emailConfirmedAt != null;

  /// Initialize authentication state
  Future<void> _initAuth() async {
    _currentUser = _client.auth.currentUser;

    // Check if anonymous mode was previously chosen
    final prefs = await SharedPreferences.getInstance();
    _isAnonymous = prefs.getBool(_anonModeKey) ?? false;

    // Listen to auth state changes
    _client.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      if (_currentUser != null) {
        _isAnonymous = false;
        _saveAnonMode(false);
      }
      notifyListeners();
    });

    notifyListeners();
  }

  /// Save anonymous mode preference
  Future<void> _saveAnonMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_anonModeKey, value);
  }

  /// Sign up or sign in with email and password.
  /// Automatically detects if user exists.
  Future<bool> signInOrSignUpWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try to sign in first
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        _isAnonymous = false;
        await _saveAnonMode(false);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on AuthException catch (e) {
      // If "Invalid credentials", try to sign up
      if (e.message.contains('Invalid') || e.message.contains('credentials')) {
        try {
          final signUpResponse = await _client.auth.signUp(
            email: email,
            password: password,
          );

          if (signUpResponse.user != null) {
            _currentUser = signUpResponse.user;
            _isAnonymous = false;
            await _saveAnonMode(false);
            _isLoading = false;
            notifyListeners();
            return true;
          }
        } on AuthException catch (signUpError) {
          _errorMessage = _parseAuthError(signUpError.message);
        }
      } else {
        _errorMessage = _parseAuthError(e.message);
      }
    } catch (e) {
      _errorMessage = '网络错误，请稍后重试';
      debugPrint('Auth error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign in with Google OAuth
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.disensor://login-callback',
      );

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = 'Google登录失败';
      debugPrint('Google OAuth error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.disensor://login-callback',
      );

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = 'Apple登录失败';
      debugPrint('Apple OAuth error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Continue as anonymous (guest mode)
  /// Warning: Earnings will only be stored locally
  Future<void> continueAsAnonymous() async {
    _isAnonymous = true;
    await _saveAnonMode(true);
    notifyListeners();
  }

  /// Reset password via email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.disensor://reset-callback',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _parseAuthError(e.message);
    } catch (e) {
      _errorMessage = '发送重置邮件失败';
      debugPrint('Password reset error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _currentUser = null;
      _isAnonymous = false;
      await _saveAnonMode(false);
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Parse auth error messages to user-friendly Chinese
  String _parseAuthError(String message) {
    if (message.contains('Email not confirmed')) {
      return '请先验证邮箱';
    } else if (message.contains('Invalid login credentials')) {
      return '邮箱或密码错误';
    } else if (message.contains('User already registered')) {
      return '该邮箱已注册，请直接登录';
    } else if (message.contains('Password should be')) {
      return '密码至少需要6位';
    } else if (message.contains('rate limit')) {
      return '操作太频繁，请稍后再试';
    } else if (message.contains('network')) {
      return '网络错误，请检查连接';
    }
    return message;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
