import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class UploadVaultItemEvent extends AdminEvent {
  final String title;
  final String author;
  final String description;
  final double price;
  final bool isPremium;
  final String imageUrl;
  final String pdfUrl;

  const UploadVaultItemEvent({
    required this.title,
    required this.author,
    required this.description,
    required this.price,
    required this.isPremium,
    required this.imageUrl,
    required this.pdfUrl,
  });

  @override
  List<Object> get props => [title, author, description, price, isPremium, imageUrl, pdfUrl];
}

class UploadFeedItemEvent extends AdminEvent {
  final String title;
  final String content;
  final String imageUrl;

  const UploadFeedItemEvent({
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [title, content, imageUrl];
}

class UploadAppUpdateEvent extends AdminEvent {
  final dynamic apkFile;
  final String version;

  const UploadAppUpdateEvent({
    required this.apkFile,
    required this.version,
  });

  @override
  @override
  List<Object> get props => [apkFile, version];
}

class DeleteVaultItemEvent extends AdminEvent {
  final String id;
  const DeleteVaultItemEvent(this.id);
  @override
  List<Object> get props => [id];
}

class DeleteFeedItemEvent extends AdminEvent {
  final String id;
  const DeleteFeedItemEvent(this.id);
  @override
  List<Object> get props => [id];
}

class InitializeSystemEvent extends AdminEvent {}

class FetchUsersEvent extends AdminEvent {}

class UpdateUserStatusEvent extends AdminEvent {
  final String uid;
  final bool? isPremium;
  final bool? isBanned;

  const UpdateUserStatusEvent({
    required this.uid,
    this.isPremium,
    this.isBanned,
  });

  @override
  List<Object> get props => [uid, isPremium ?? false, isBanned ?? false];
}
