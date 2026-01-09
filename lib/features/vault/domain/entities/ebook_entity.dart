import 'package:equatable/equatable.dart';

class EbookEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String pdfUrl;
  final String description;
  final bool isLocked;
  final double price; // 0.0 if free/included

  const EbookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.pdfUrl,
    required this.description,
    this.isLocked = true,
    this.price = 0.0,
  });

  @override
  List<Object?> get props => [id, title, author, coverUrl, pdfUrl, description, isLocked, price];
}
