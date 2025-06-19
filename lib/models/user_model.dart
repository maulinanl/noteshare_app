import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String bio;
  final String? profileImageUrl;
  final int coins;
  final DateTime createdAt;
  final List<String> favoriteNotes;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    required this.bio,
    this.profileImageUrl,
    required this.coins,
    required this.createdAt,
    required this.favoriteNotes,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      coins: data['coins'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      favoriteNotes: List<String>.from(data['favoriteNotes'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'coins': coins,
      'createdAt': Timestamp.fromDate(createdAt),
      'favoriteNotes': favoriteNotes,
    };
  }
}
