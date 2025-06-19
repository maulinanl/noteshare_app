import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final int likes;
  final int views;
  final bool isMonetized;
  final int coinPrice;
  final String? imageUrl;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.likes,
    required this.views,
    required this.isMonetized,
    required this.coinPrice,
    this.imageUrl,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      likes: data['likes'] ?? 0,
      views: data['views'] ?? 0,
      isMonetized: data['isMonetized'] ?? false,
      coinPrice: data['coinPrice'] ?? 0,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'likes': likes,
      'views': views,
      'isMonetized': isMonetized,
      'coinPrice': coinPrice,
      'imageUrl': imageUrl,
    };
  }
}
