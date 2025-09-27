import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/login.dart';
import '../services/secure_storage_service.dart';
import '../services/profile_api_service.dart';

enum LoginState { idle, loading, success, error }

class LoginController {
  LoginState _state = LoginState.idle;
  String? _errorMessage;
  LoginUser? _currentUser;

  // Getters
  LoginState get state => _state;
  String? get errorMessage => _errorMessage;
  LoginUser? get currentUser => _currentUser;

  // State management
  void _setState(LoginState newState) {
    _state = newState;
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(LoginState.error);
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Validation
  bool validateCredentials(LoginCredentials credentials) {
    _clearError();

    final emailError = credentials.validateEmail();
    if (emailError != null) {
      _setError(emailError);
      return false;
    }

    final passwordError = credentials.validatePassword();
    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    return true;
  }

  // Firebase login
  Future<firebase_auth.User?> _loginWithFirebase(LoginCredentials credentials) async {
    try {
      final credential = await firebase_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: credentials.email.trim(),
        password: credentials.password,
      );

      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar.';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid.';
          break;
        case 'user-disabled':
          errorMessage = 'Akun ini telah dinonaktifkan.';
          break;
        case 'too-many-requests':
          errorMessage = 'Terlalu banyak percobaan. Coba lagi nanti.';
          break;
        case 'invalid-credential':
          errorMessage = 'Email atau password salah.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
      throw Exception(errorMessage);
    }
  }

  // Main login method
  Future<LoginResult> login(LoginCredentials credentials) async {
    if (!validateCredentials(credentials)) {
      return LoginResult(
        success: false,
        message: _errorMessage ?? 'Validation failed',
        type: LoginResultType.validationError,
      );
    }

    _setState(LoginState.loading);

    try {
      // Step 1: Login with Firebase
      final firebaseUser = await _loginWithFirebase(credentials);
      
      if (firebaseUser == null) {
        throw Exception('Failed to login with Firebase');
      }

      // Step 2: Get Firebase JWT token and refresh token
      final idToken = await firebaseUser.getIdToken();
      final refreshToken = firebaseUser.refreshToken;
      
      if (idToken == null) {
        throw Exception('Failed to get authentication token');
      }

      // Step 3: Get profile data from API
      final profileResult = await ProfileApiService.getProfile(idToken);
      
      if (!profileResult['success']) {
        throw Exception(profileResult['message'] ?? 'Failed to get profile data');
      }

      final profileData = profileResult['data'];

      // Step 4: Create LoginUser object with complete profile data
      _currentUser = LoginUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? credentials.email,
        displayName: profileData['display_name'],
        token: idToken,
        refreshToken: refreshToken,
        loginTime: DateTime.now(),
        isVerified: profileData['is_verified'] ?? false,
        gender: profileData['gender'],
        age: profileData['age'],
      );

      // Step 5: Save to secure storage
      await SecureStorageService.saveUserData(_currentUser!);

      _setState(LoginState.success);
      
      return LoginResult(
        success: true,
        message: profileData['message'] ?? 'Login berhasil!',
        type: LoginResultType.success,
        user: _currentUser,
      );
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      
      return LoginResult(
        success: false,
        message: _errorMessage ?? 'Terjadi kesalahan tidak dikenal',
        type: LoginResultType.error,
      );
    }
  }

  // Check if user is already logged in
  Future<LoginResult> checkLoginStatus() async {
    try {
      final isLoggedIn = await SecureStorageService.isLoggedIn();
      
      if (!isLoggedIn) {
        return LoginResult(
          success: false,
          message: 'User not logged in',
          type: LoginResultType.notLoggedIn,
        );
      }

      // Check if token is expired
      final isExpired = await SecureStorageService.isTokenExpired();
      if (isExpired) {
        await logout(); // Clear expired data
        return LoginResult(
          success: false,
          message: 'Session expired',
          type: LoginResultType.sessionExpired,
        );
      }

      // Get user data from storage
      _currentUser = await SecureStorageService.getUserData();
      
      if (_currentUser != null) {
        _setState(LoginState.success);
        return LoginResult(
          success: true,
          message: 'User is logged in',
          type: LoginResultType.success,
          user: _currentUser,
        );
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      await logout(); // Clear corrupted data
      return LoginResult(
        success: false,
        message: 'Failed to check login status',
        type: LoginResultType.error,
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await firebase_auth.FirebaseAuth.instance.signOut();
      
      // Clear secure storage
      await SecureStorageService.clearAllData();
      
      // Reset state
      _currentUser = null;
      _setState(LoginState.idle);
      _clearError();
    } catch (e) {
      print('Error during logout: $e');
      // Force clear even if Firebase logout fails
      await SecureStorageService.clearAllData();
      _currentUser = null;
      _setState(LoginState.idle);
      _clearError();
    }
  }

  // Reset controller state
  void reset() {
    _state = LoginState.idle;
    _errorMessage = null;
    // Don't clear _currentUser here as it might be needed
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final newToken = await currentUser.getIdToken(true); // Force refresh
        final newRefreshToken = currentUser.refreshToken;
        
        if (newToken != null) {
          await SecureStorageService.updateToken(newToken);
          
          // Update current user with new tokens
          if (_currentUser != null) {
            _currentUser = LoginUser(
              uid: _currentUser!.uid,
              email: _currentUser!.email,
              displayName: _currentUser!.displayName,
              token: newToken,
              refreshToken: newRefreshToken,
              loginTime: DateTime.now(),
              isVerified: _currentUser!.isVerified,
              gender: _currentUser!.gender,
              age: _currentUser!.age,
            );
            await SecureStorageService.saveUserData(_currentUser!);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }
}

// Result classes
enum LoginResultType { success, validationError, error, notLoggedIn, sessionExpired }

class LoginResult {
  final bool success;
  final String message;
  final LoginResultType type;
  final LoginUser? user;

  LoginResult({
    required this.success,
    required this.message,
    required this.type,
    this.user,
  });
}