import 'package:equatable/equatable.dart';
import '../../domain/entities/feed_entity.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

class LoadFeed extends FeedEvent {}

class FeedUpdated extends FeedEvent {
  final List<FeedEntity> feed;
  const FeedUpdated(this.feed);
  @override
  List<Object> get props => [feed];
}

class FeedErrorEvent extends FeedEvent {
  final String message;
  const FeedErrorEvent(this.message);
  @override
  List<Object> get props => [message];
}
class ToggleLikeEvent extends FeedEvent {
  final String feedId;
  final String uid;
  final bool isLiked; // Current state, to toggle

  const ToggleLikeEvent({required this.feedId, required this.uid, required this.isLiked});

  @override
  List<Object> get props => [feedId, uid, isLiked];
}

class AddCommentEvent extends FeedEvent {
  final String feedId;
  final String uid;
  final String username;
  final String text;

  const AddCommentEvent({required this.feedId, required this.uid, required this.username, required this.text});

  @override
  List<Object> get props => [feedId, uid, username, text];
}
