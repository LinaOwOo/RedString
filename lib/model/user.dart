class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? partnerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.partnerId,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map, {required String documentId}) {
    return User(
      id: documentId,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      partnerId: map['partnerId'],
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'partnerId': partnerId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Immutable copyWith для обновления состояния
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? partnerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      partnerId: partnerId ?? this.partnerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
