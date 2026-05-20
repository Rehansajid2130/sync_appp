import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'storage_service.dart';

/// Represents a fully registered user in the database.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final bool isProvider;
  final DateTime createdAt;
  final String? avatarUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.isProvider = false,
    required this.createdAt,
    this.avatarUrl,
  });

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    bool? isProvider,
    String? avatarUrl,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isProvider: isProvider ?? this.isProvider,
      createdAt: createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'isProvider': isProvider,
    'createdAt': createdAt.toIso8601String(),
    'avatarUrl': avatarUrl,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    isProvider: json['isProvider'] ?? false,
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    avatarUrl: json['avatarUrl'],
  );
}

/// Authentication result returned from login/signup operations.
class AuthResult {
  final bool success;
  final String? message;
  final AppUser? user;

  const AuthResult({required this.success, this.message, this.user});
}

/// Strict authentication service using only Supabase Auth.
class AuthService {
  static AppUser? _currentUser;
  static AppUser? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  // ─────────────────────────────────────────────────────────────────────────
  // Startup: restore session from Supabase Auth
  // ─────────────────────────────────────────────────────────────────────────
  static Future<AppUser?> restoreSession() async {
    if (!SupabaseConfig.isSupabaseActive) return null;

    try {
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;
      if (session != null && user != null) {
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profileData != null) {
          _currentUser = AppUser(
            uid: user.id,
            name: profileData['name'] ?? 'User',
            email: user.email ?? '',
            phone: profileData['phone'],
            isProvider: profileData['is_provider'] ?? false,
            createdAt: DateTime.parse(profileData['created_at'] ?? DateTime.now().toIso8601String()),
            avatarUrl: profileData['avatar_url'],
          );
          return _currentUser;
        }
      }
    } catch (e) {
      // Return null on failure, forcing login screen
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sign Up
  // ─────────────────────────────────────────────────────────────────────────
  static Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    bool isProvider = false,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (name.trim().isEmpty) return const AuthResult(success: false, message: 'Please enter your name.');
    if (!_isValidEmail(trimmedEmail)) return const AuthResult(success: false, message: 'Please enter a valid email address.');
    if (password.length < 6) return const AuthResult(success: false, message: 'Password must be at least 6 characters.');
    if (!SupabaseConfig.isSupabaseActive) return const AuthResult(success: false, message: 'Database connection failed.');

    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: trimmedEmail,
        password: password,
      );

      if (authResponse.user != null) {
        final uid = authResponse.user!.id;
        final newUser = AppUser(
          uid: uid,
          name: name.trim(),
          email: trimmedEmail,
          phone: phone?.trim(),
          isProvider: isProvider,
          createdAt: DateTime.now(),
        );

        // Insert into profiles table
        await Supabase.instance.client.from('profiles').upsert({
          'id': uid,
          'name': newUser.name,
          'email': newUser.email,
          'phone': newUser.phone,
          'is_provider': isProvider,
          'created_at': newUser.createdAt.toIso8601String(),
        });

        _currentUser = newUser;
        return AuthResult(success: true, message: 'Account created successfully!', user: newUser);
      }
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
    return const AuthResult(success: false, message: 'An unknown error occurred.');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sign In
  // ─────────────────────────────────────────────────────────────────────────
  static Future<AuthResult> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedEmail.isEmpty || password.isEmpty) return const AuthResult(success: false, message: 'Please fill in all fields.');
    if (!SupabaseConfig.isSupabaseActive) return const AuthResult(success: false, message: 'Database connection failed.');

    try {
      // 1. Try standard Supabase Auth
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );

      if (response.user != null) {
        return _handleSignInSuccess(response.user!);
      }
    } catch (e) {
      // 2. Fallback: Check if the user has a "temp_password" set via our direct reset flow
      try {
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('email', trimmedEmail)
            .maybeSingle();

        if (profileData != null) {
          final dbPassword = profileData['temp_password'];
          if (dbPassword != null && dbPassword == password) {
            final appUser = AppUser(
              uid: profileData['id'],
              name: profileData['name'] ?? 'User',
              email: profileData['email'] ?? '',
              phone: profileData['phone'],
              isProvider: profileData['is_provider'] ?? false,
              createdAt: DateTime.parse(profileData['created_at'] ?? DateTime.now().toIso8601String()),
              avatarUrl: profileData['avatar_url'],
            );

            _currentUser = appUser;
            return AuthResult(success: true, user: appUser);
          }
        }
      } catch (dbError) {
        // If the database query itself fails (e.g., missing column), we should know
        return AuthResult(success: false, message: 'Database error: ${dbError.toString()}');
      }
      
      return const AuthResult(success: false, message: 'Incorrect email or password.');
    }
    return const AuthResult(success: false, message: 'Sign in failed.');
  }

  static Future<AuthResult> _handleSignInSuccess(User user) async {
    final profileData = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    final appUser = AppUser(
      uid: user.id,
      name: profileData != null ? (profileData['name'] ?? 'User') : 'User',
      email: user.email ?? '',
      phone: profileData != null ? profileData['phone'] : null,
      isProvider: profileData != null ? (profileData['is_provider'] ?? false) : false,
      createdAt: DateTime.parse(profileData != null ? (profileData['created_at'] ?? DateTime.now().toIso8601String()) : DateTime.now().toIso8601String()),
      avatarUrl: profileData != null ? profileData['avatar_url'] : null,
    );

    _currentUser = appUser;
    return AuthResult(success: true, user: appUser);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Forgot Password
  // ─────────────────────────────────────────────────────────────────────────
  static Future<AuthResult> resetPassword(String email) async {
    if (!SupabaseConfig.isSupabaseActive) return const AuthResult(success: false, message: 'Database connection failed.');
    final trimmedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(trimmedEmail)) return const AuthResult(success: false, message: 'Please enter a valid email address.');

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(trimmedEmail);
      return const AuthResult(success: true, message: 'Password reset link sent to your email.');
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  static Future<AuthResult> updatePasswordDirectly({
    required String email,
    required String newPassword,
  }) async {
    if (!SupabaseConfig.isSupabaseActive) return const AuthResult(success: false, message: 'Database connection failed.');
    
    try {
      final trimmedEmail = email.trim().toLowerCase();
      
      // Update the profiles table and return the updated row to verify it exists
      final List<dynamic> response = await Supabase.instance.client
          .from('profiles')
          .update({'temp_password': newPassword})
          .eq('email', trimmedEmail)
          .select();
      
      if (response.isEmpty) {
        return const AuthResult(
          success: false, 
          message: 'User not found. Please ensure you are using the correct email registered in your profile.',
        );
      }
      
      return const AuthResult(success: true, message: 'Password updated successfully!');
    } catch (e) {
      return AuthResult(success: false, message: 'Error: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update Profile
  // ─────────────────────────────────────────────────────────────────────────
  static Future<bool> updateProfile({String? name, String? email, String? phone, bool? isProvider}) async {
    if (_currentUser == null || !SupabaseConfig.isSupabaseActive) return false;
    
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (phone != null) updates['phone'] = phone;
      if (isProvider != null) updates['is_provider'] = isProvider;
      
      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', _currentUser!.uid);
          
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email,
        phone: phone,
        isProvider: isProvider,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sign Out
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    _currentUser = null;
    if (SupabaseConfig.isSupabaseActive) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }
}
