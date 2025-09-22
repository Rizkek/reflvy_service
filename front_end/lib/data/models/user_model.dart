// Model untuk data pengguna
class UserModel {
  final String id;
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String profileImage;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.profileImage = '',
    required this.createdAt,
    required this.lastLogin,
  });

  // Getter untuk nama lengkap
  String get displayName => '$firstName $lastName'.trim();

  // Konversi dari Map ke UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      profileImage: map['profileImage'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: DateTime.parse(map['lastLogin'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Konversi dari UserModel ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  // Fungsi untuk mendapatkan nama lengkap
  String get fullName => '$firstName $lastName';

  // Fungsi untuk copyWith (membuat salinan dengan perubahan)
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? profileImage,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, fullName: $fullName)';
  }
}