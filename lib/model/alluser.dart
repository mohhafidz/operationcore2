class alluser {
  final String userId;
  final String name;
  final String role;

  alluser({required this.userId, required this.name, required this.role});

  factory alluser.fromFirestore(String docId, Map<String, dynamic> data) {
    return alluser(
      userId: data['userId'] ?? docId,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
    );
  }
}
