class AppUser {
  final String id;
  final String name;
  final String role;
  final String email;

  AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
  });

  factory AppUser.fromFirestore(String id, Map<String, dynamic> data) {
    return AppUser(
      id: data['userId'],
      name: data['name'],
      role: data['role'],
      email: data['email'],
    );
  }
}
