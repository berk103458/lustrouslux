import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ebook_entity.dart';

class EbookModel extends EbookEntity {
  const EbookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.coverUrl,
    required super.pdfUrl,
    required super.description,
    super.isLocked = true,
    super.price = 0.0,
  });

  factory EbookModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return EbookModel(
      id: snap.id,
      title: snapshot['title'] ?? 'Untitled',
      author: snapshot['author'] ?? 'Unknown',
      coverUrl: snapshot['coverUrl'] ?? snapshot['imageUrl'] ?? '',
      pdfUrl: snapshot['pdfUrl'] ?? '',
      description: snapshot['description'] ?? '',
      isLocked: snapshot['isLocked'] ?? true,
      price: (snapshot['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      "title": title,
      "author": author,
      "coverUrl": coverUrl,
      "pdfUrl": pdfUrl,
      "description": description,
      "isLocked": isLocked,
      "price": price,
    };
  }
}
