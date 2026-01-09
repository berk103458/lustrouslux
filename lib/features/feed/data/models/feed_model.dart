import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/feed_entity.dart';

class FeedModel extends FeedEntity {
  const FeedModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.description,
    required super.timestamp,
    super.externalUrl,
    super.likes,
  });

  factory FeedModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return FeedModel(
      id: snap.id,
      title: snapshot['title'] ?? '',
      imageUrl: snapshot['imageUrl'] ?? '',
      description: snapshot['content'] ?? snapshot['description'] ?? '', // Fallback to description if exists
      externalUrl: snapshot['externalUrl'],
      likes: snapshot['likes'] ?? 0,
      timestamp: snapshot['createdAt'] != null 
          ? (snapshot['createdAt'] as Timestamp).toDate() 
          : DateTime.now(), // Handle potential null during server write
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      "title": title,
      "imageUrl": imageUrl,
      "description": description,
      "externalUrl": externalUrl,
      "likes": likes,
      "timestamp": timestamp,
    };
  }
}
