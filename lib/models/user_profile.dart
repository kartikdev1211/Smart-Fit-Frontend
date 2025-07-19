class UserProfile {
  final String id;
  final String fullName;
  final String email;

  UserProfile({required this.id, required this.fullName, required this.email});

  // Factory constructor to create UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // Convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {'_id': id, 'full_name': fullName, 'email': email};
  }

  // Create a copy of UserProfile with updated fields
  UserProfile copyWith({String? id, String? fullName, String? email}) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, fullName: $fullName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
