import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'storage_service.dart';

/// Represents a fully registered user in the database.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String passwordHash;
  final String? phone;
  final bool isProvider;
  final DateTime createdAt;
  final String? avatarUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.passwordHash,
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
      passwordHash: passwordHash,
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
    'passwordHash': passwordHash,
    'phone': phone,
    'isProvider': isProvider,
    'createdAt': createdAt.toIso8601String(),
    'avatarUrl': avatarUrl,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'],
    name: json['name'],
    email: json['email'],
    passwordHash: json['passwordHash'] ?? '',
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

/// Dynamic, hybrid authentication service supporting both local SharedPreferences and Supabase Auth.
class AuthService {
  static const String _usersKey = 'hh_users';
  static const String _sessionTokenKey = 'hh_session_token';
  static const String _sessionUidKey = 'hh_session_uid';

  static AppUser? _currentUser;
  static AppUser? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  // ─────────────────────────────────────────────────────────────────────────
  // Startup: restore session from storage or Supabase Auth
  // ─────────────────────────────────────────────────────────────────────────

  /// Call this at app startup to restore a previously saved session.
  static Future<AppUser?> restoreSession() async {
    if (SupabaseConfig.isSupabaseActive) {
      try {
        final session = Supabase.instance.client.auth.currentSession;
        final user = Supabase.instance.client.auth.currentUser;
        if (session != null && user != null) {
          // Fetch additional profile data from profiles table
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
              passwordHash: '',
              phone: profileData['phone'],
              isProvider: profileData['is_provider'] ?? false,
              createdAt: DateTime.parse(profileData['created_at'] ?? DateTime.now().toIso8601String()),
              avatarUrl: profileData['avatar_url'],
            );
            return _currentUser;
          }
        }
      } catch (e) {
        // Fallback to local session on error
      }
    }

    // Local SharedPreferences Fallback
    final token = StorageService.getData(_sessionTokenKey);
    final uid = StorageService.getData(_sessionUidKey);
    if (token == null || uid == null || token.isEmpty || uid.isEmpty) return null;

    final users = await _loadAllUsers();
    try {
      final user = users.firstWhere((u) => u.uid == uid);
      _currentUser = user;
      return user;
    } catch (_) {
      await _clearSession();
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sign Up
  // ─────────────────────────────────────────────────────────────────────────

  /// Registers a new user. Returns an error if the email is already taken.
  static Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    bool isProvider = false,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    // Validate inputs
    if (name.trim().isEmpty) {
      return const AuthResult(success: false, message: 'Please enter your name.');
    }
    if (!_isValidEmail(trimmedEmail)) {
      return const AuthResult(success: false, message: 'Please enter a valid email address.');
    }
    if (password.length < 6) {
      return const AuthResult(success: false, message: 'Password must be at least 6 characters.');
    }

    if (SupabaseConfig.isSupabaseActive) {
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
            passwordHash: '',
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
          await _writeSession(uid);
          return AuthResult(success: true, message: 'Account created successfully!', user: newUser);
        }
      } catch (e) {
        return AuthResult(success: false, message: e.toString());
      }
    }

    // Local SharedPreferences Fallback
    final users = await _loadAllUsers();
    final exists = users.any((u) => u.email == trimmedEmail);
    if (exists) {
      return const AuthResult(success: false, message: 'An account with this email already exists.');
    }

    final newUser = AppUser(
      uid: const Uuid().v4(),
      name: name.trim(),
      email: trimmedEmail,
      passwordHash: _hashPassword(password),
      phone: phone?.trim(),
      isProvider: isProvider,
      createdAt: DateTime.now(),
    );

    users.add(newUser);
    await _saveAllUsers(users);
    _currentUser = newUser;
    await _writeSession(newUser.uid);

    return AuthResult(success: true, message: 'Account created successfully!', user: newUser);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sign In
  // ─────────────────────────────────────────────────────────────────────────

  /// Signs a user in with email and password.
  static Future<AuthResult> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      return const AuthResult(success: false, message: 'Please fill in all fields.');
    }

    if (SupabaseConfig.isSupabaseActive) {
      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: trimmedEmail,
          password: password,
        );

        if (response.user != null) {
          final user = response.user!;
          
          // Fetch profile data
          final profileData = await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          final appUser = AppUser(
            uid: user.id,
            name: profileData != null ? (profileData['name'] ?? 'User') : 'User',
            email: user.email ?? '',
            passwordHash: '',
            phone: profileData != null ? profileData['phone'] : null,
            isProvider: profileData != null ? (profileData['is_provider'] ?? false) : false,
            createdAt: DateTime.parse(profileData != null ? (profileData['created_at'] ?? DateTime.now().toIso8601String()) : DateTime.now().toIso8601String()),
            avatarUrl: profileData != null ? profileData['avatar_url'] : null,
          );

          _currentUser = appUser;
          await _writeSession(user.id);
          return AuthResult(success: true, user: appUser);
        }
      } catch (e) {
        return AuthResult(success: false, message: e.toString());
      }
    }

    // Local SharedPreferences Fallback
    final users = await _loadAllUsers();
    AppUser? found;
    try {
      found = users.firstWhere((u) => u.email == trimmedEmail);
    } catch (_) {
      return const AuthResult(success: false, message: 'No account found with this email.');
    }

    if (found.passwordHash != _hashPassword(password)) {
      return const AuthResult(success: false, message: 'Incorrect password.');
    }

    _currentUser = found;
    await _writeSession(found.uid);
    return AuthResult(success: true, user: found);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Social Sign In
  // ─────────────────────────────────────────────────────────────────────────

  /// Signs a user in with a social account (Google or Apple).
  static Future<AuthResult> signInWithSocial({
    required String provider,
  }) async {
    final mockUid = 'social_${provider.toLowerCase()}_12345';
    final mockEmail = 'user.${provider.toLowerCase()}@helperhive.com';
    final mockName = 'Fajar Kun'; // Dynamic placeholder for demo user

    final newUser = AppUser(
      uid: mockUid,
      name: mockName,
      email: mockEmail,
      passwordHash: '',
      isProvider: false,
      createdAt: DateTime.now(),
    );

    if (SupabaseConfig.isSupabaseActive) {
      try {
        // Create profile in Supabase profiles if active
        await Supabase.instance.client.from('profiles').upsert({
          'id': mockUid,
          'name': mockName,
          'email': mockEmail,
          'is_provider': false,
          'created_at': newUser.createdAt.toIso8601String(),
        });
      } catch (_) {}
    }

    // Local SharedPreferences Fallback
    final users = await _loadAllUsers();
    final idx = users.indexWhere((u) => u.uid == mockUid);
    if (idx == -1) {
      users.add(newUser);
      await _saveAllUsers(users);
    } else {
      // Keep existing profile
      final existing = users[idx];
      _currentUser = existing;
      await _writeSession(existing.uid);
      return AuthResult(success: true, user: existing);
    }

    _currentUser = newUser;
    await _writeSession(newUser.uid);
    return AuthResult(success: true, user: newUser);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sign Out
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    _currentUser = null;
    await _clearSession();
    if (SupabaseConfig.isSupabaseActive) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update Profile
  // ─────────────────────────────────────────────────────────────────────────

  static Future<AuthResult> updateProfile({
    String? name,
    String? email,
    String? phone,
    bool? isProvider,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) {
      return const AuthResult(success: false, message: 'Not logged in.');
    }

    final updated = _currentUser!.copyWith(
      name: name,
      email: email,
      phone: phone,
      isProvider: isProvider,
      avatarUrl: avatarUrl,
    );

    if (SupabaseConfig.isSupabaseActive) {
      try {
        final updates = <String, dynamic>{};
        if (name != null) updates['name'] = name;
        if (email != null) updates['email'] = email;
        if (phone != null) updates['phone'] = phone;
        if (isProvider != null) updates['is_provider'] = isProvider;
        if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

        if (updates.isNotEmpty) {
          await Supabase.instance.client
              .from('profiles')
              .update(updates)
              .eq('id', _currentUser!.uid);
        }

        _currentUser = updated;
        return AuthResult(success: true, user: updated);
      } catch (e) {
        return AuthResult(success: false, message: e.toString());
      }
    }

    // Local SharedPreferences Fallback
    final users = await _loadAllUsers();
    final idx = users.indexWhere((u) => u.uid == updated.uid);
    if (idx != -1) {
      users[idx] = updated;
      await _saveAllUsers(users);
    }

    _currentUser = updated;
    return AuthResult(success: true, user: updated);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Change Password
  // ─────────────────────────────────────────────────────────────────────────

  static Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      return const AuthResult(success: false, message: 'Not logged in.');
    }

    if (newPassword.length < 6) {
      return const AuthResult(success: false, message: 'New password must be at least 6 characters.');
    }

    if (SupabaseConfig.isSupabaseActive) {
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: newPassword),
        );
        return const AuthResult(success: true, message: 'Password updated successfully.');
      } catch (e) {
        return AuthResult(success: false, message: e.toString());
      }
    }

    // Local SharedPreferences Fallback
    if (_currentUser!.passwordHash != _hashPassword(currentPassword)) {
      return const AuthResult(success: false, message: 'Current password is incorrect.');
    }

    final users = await _loadAllUsers();
    final idx = users.indexWhere((u) => u.uid == _currentUser!.uid);
    if (idx != -1) {
      users[idx] = AppUser(
        uid: _currentUser!.uid,
        name: _currentUser!.name,
        email: _currentUser!.email,
        passwordHash: _hashPassword(newPassword),
        phone: _currentUser!.phone,
        isProvider: _currentUser!.isProvider,
        createdAt: _currentUser!.createdAt,
        avatarUrl: _currentUser!.avatarUrl,
      );
      await _saveAllUsers(users);
      _currentUser = users[idx];
    }

    return const AuthResult(success: true, message: 'Password updated successfully.');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'hh_salt_2026'); // simple salt
    return sha256.convert(bytes).toString();
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }

  static Future<List<AppUser>> _loadAllUsers() async {
    final jsonStr = StorageService.getData(_usersKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => AppUser.fromJson(e)).toList();
  }

  static Future<void> _saveAllUsers(List<AppUser> users) async {
    final jsonStr = jsonEncode(users.map((u) => u.toJson()).toList());
    await StorageService.saveData(_usersKey, jsonStr);
  }

  static Future<void> _writeSession(String uid) async {
    final token = const Uuid().v4();
    await StorageService.saveData(_sessionTokenKey, token);
    await StorageService.saveData(_sessionUidKey, uid);
  }

  static Future<void> _clearSession() async {
    await StorageService.saveData(_sessionTokenKey, '');
    await StorageService.saveData(_sessionUidKey, '');
  }
}
