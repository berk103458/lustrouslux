import 'package:equatable/equatable.dart';

class FeedEntity extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final String description; // The status/caption
  final String? externalUrl; // Optional link to Instagram/Article
  final DateTime timestamp;
  final int likes;

  const FeedEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.timestamp,
    this.externalUrl,
    this.likes = 0,
  });

  @override
  List<Object?> get props => [id, title, imageUrl, description, externalUrl, timestamp, likes];
}
