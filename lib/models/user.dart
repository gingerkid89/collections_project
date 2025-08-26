// lib/models/user.dart

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final AuthProvider? authProvider;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.authProvider,
    required this.createdAt,
    required this.lastActiveAt,
  });

  // Create User from JSON (for API responses)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      authProvider: json['authProvider'] != null 
          ? AuthProvider.values.byName(json['authProvider'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
    );
  }

  // Convert User to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'authProvider': authProvider?.name,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }

  // Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    AuthProvider? authProvider,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, authProvider: $authProvider}';
  }
}

enum AuthProvider {
  email,
  google,
  apple,
}

class AuthCredentials {
  final String? email;
  final String? password;
  final String? idToken;
  final String? accessToken;
  final AuthProvider provider;

  const AuthCredentials({
    this.email,
    this.password,
    this.idToken,
    this.accessToken,
    required this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'idToken': idToken,
      'accessToken': accessToken,
      'provider': provider.name,
    };
  }
}