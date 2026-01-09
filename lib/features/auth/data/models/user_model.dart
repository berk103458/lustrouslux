import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.role = 'user',
    super.isApproved = false,
    super.isPremium = false,
    super.isBanned = false,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserModel(
      uid: snap.id,
      email: snapshot['email'],
      role: snapshot['role'] ?? 'user',
      isApproved: snapshot['isApproved'] ?? false,
      isPremium: snapshot['isPremium'] ?? false,
      isBanned: snapshot['isBanned'] ?? false,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      "email": email,
      "role": role,
      "isApproved": isApproved,
      "isPremium": isPremium,
      "isBanned": isBanned,
    };
  }

  // Also support fromJson for general purpose
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      role: json['role'] ?? 'user',
      isApproved: json['isApproved'] ?? false,
      isPremium: json['isPremium'] ?? false,
      isBanned: json['isBanned'] ?? false,
    );
  }
}
