import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

abstract class AuthService {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(String email, String password, String displayName);
  Future<User?> signInWithGoogle();
  Future<User?> signInWithApple();
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<bool> isSignedIn();
  Future<String?> getToken();
}

class MockAuthService implements AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  // Disabled Google Sign-In for now to avoid web configuration issues
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ['email', 'profile'],
  // );

  User? _currentUser;

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    
    // Test credentials for easy login - try to get real JWT token
    if ((email == 'user@mail.com' || email == 'user@web.com') && password == '123456') {
      // Try to authenticate with the actual API
      final realToken = await _authenticateWithAPI(email, password);
      
      final user = User(
        id: 'c1a7b30d-b623-4885-ae0d-b395cdda4b49', // Use the actual test user ID from API
        name: 'Test User',
        email: email,
        authProvider: AuthProvider.email,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
      
      // Save user and token
      await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
      if (realToken != null) {
        await _storage.write(key: _tokenKey, value: realToken);
        print('✅ Successfully authenticated with API and got JWT token');
      } else {
        await _storage.write(key: _tokenKey, value: _generateToken());
        print('⚠️ API authentication failed, using mock token');
      }
      
      _currentUser = user;
      return user;
    }
    
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    
    // For any other email/password, simulate successful login
    final user = User(
      id: _generateId(),
      name: email.split('@').first,
      email: email,
      authProvider: AuthProvider.email,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
    
    await _saveUser(user);
    _currentUser = user;
    return user;
  }

  @override
  Future<User?> signUpWithEmail(String email, String password, String displayName) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
      throw Exception('All fields are required');
    }
    
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    
    if (!_isValidEmail(email)) {
      throw Exception('Please enter a valid email address');
    }
    
    final user = User(
      id: _generateId(),
      name: displayName,
      email: email,
      authProvider: AuthProvider.email,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
    
    await _saveUser(user);
    _currentUser = user;
    return user;
  }

  @override
  Future<User?> signInWithGoogle() async {
    // Temporarily disabled Google Sign-In to avoid web configuration issues
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return a mock Google user for testing
    final user = User(
      id: _generateId(),
      name: 'Test Google User',
      email: 'test@google.com',
      avatarUrl: null,
      authProvider: AuthProvider.google,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
      
    await _saveUser(user);
    await _storage.write(key: _tokenKey, value: 'mock_google_token');
    _currentUser = user;
    return user;
  }

  @override
  Future<User?> signInWithApple() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final String displayName = credential.givenName != null && credential.familyName != null
          ? '${credential.givenName} ${credential.familyName}'
          : credential.email?.split('@').first ?? 'Apple User';
      
      final user = User(
        id: _generateId(),
        name: displayName,
        email: credential.email ?? '${credential.userIdentifier}@apple.com',
        authProvider: AuthProvider.apple,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
      
      await _saveUser(user);
      await _storage.write(key: _tokenKey, value: credential.identityToken);
      _currentUser = user;
      return user;
      
    } catch (e) {
      throw Exception('Apple Sign-In failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentUser?.authProvider == AuthProvider.google) {
      // await _googleSignIn.signOut(); // Disabled for now
    }
    
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _tokenKey);
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      return _currentUser;
    }
    
    return null;
  }

  @override
  Future<bool> isSignedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> _saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    await _storage.write(key: _tokenKey, value: _generateToken());
  }

  String _generateId() {
    final random = Random();
    return 'user_${random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  String _generateToken() {
    // For testing, we should get a real JWT token from the API
    // For now, return a temporary mock token
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Method to authenticate with the actual API and get a real JWT token
  Future<String?> _authenticateWithAPI(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://collections-api-3c2p.onrender.com/api/v1/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token']; // Assuming the API returns a 'token' field
      }
    } catch (e) {
      print('API authentication failed: $e');
    }
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class ProductionAuthService implements AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _baseUrl = 'YOUR_API_BASE_URL';
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  // Disabled Google Sign-In for production service too
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ['email', 'profile'],
  // );

  User? _currentUser;

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    throw UnimplementedError('Production API not yet implemented');
  }

  @override
  Future<User?> signUpWithEmail(String email, String password, String displayName) async {
    throw UnimplementedError('Production API not yet implemented');
  }

  @override
  Future<User?> signInWithGoogle() async {
    throw UnimplementedError('Production API not yet implemented');
  }

  @override
  Future<User?> signInWithApple() async {
    throw UnimplementedError('Production API not yet implemented');
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError('Production API not yet implemented');
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      return _currentUser;
    }
    
    return null;
  }

  @override
  Future<bool> isSignedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}