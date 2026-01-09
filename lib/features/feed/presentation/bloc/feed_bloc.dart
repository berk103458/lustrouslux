import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/feed_entity.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_feed.dart';
import '../../domain/usecases/toggle_like.dart';
import '../../domain/usecases/add_comment.dart';
import '../../domain/usecases/get_comments.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeed getFeed;
  final ToggleLike toggleLike;
  final AddComment addComment;
  final GetComments getComments;

  StreamSubscription<List<FeedEntity>>? _feedSubscription;
  String? _latestPostId; 

  FeedBloc({
    required this.getFeed,
    required this.toggleLike,
    required this.addComment,
    required this.getComments,
  }) : super(FeedInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<FeedUpdated>(_onFeedUpdated);
    on<ToggleLikeEvent>(_onToggleLike);
    on<AddCommentEvent>(_onAddComment);
    on<FeedErrorEvent>((event, emit) => emit(FeedError(event.message)));
  }

  void _onLoadFeed(LoadFeed event, Emitter<FeedState> emit) {
    emit(FeedLoading());
    _feedSubscription?.cancel();
    _feedSubscription = getFeed().listen(
      (feed) => add(FeedUpdated(feed)),
      onError: (error) => add(FeedErrorEvent(error.toString())),
    );
  }

  void _onFeedUpdated(FeedUpdated event, Emitter<FeedState> emit) {
    if (event.feed.isNotEmpty) {
      final newLatestId = event.feed.first.id;
      
      // Check if this is a new post (not just initial load)
      if (_latestPostId != null && _latestPostId != newLatestId) {
        // Trigger Notification
        sl<NotificationService>().showVipNotification(
          title: 'LUSTROUS FEED',
          body: 'New content arrived: ${event.feed.first.title}',
        );
      }
      _latestPostId = newLatestId;
    }
    
    emit(FeedLoaded(event.feed));
  }

  Future<void> _onToggleLike(ToggleLikeEvent event, Emitter<FeedState> emit) async {
    try {
      await toggleLike(event.feedId, event.uid, event.isLiked);
    } catch (e) {
      // emit(FeedError("Failed to update like: $e")); 
      // Silently fail or show snackbar via listener, skipping full state error for UX smoothness
    }
  }

  Future<void> _onAddComment(AddCommentEvent event, Emitter<FeedState> emit) async {
    try {
      await addComment(event.feedId, event.uid, event.username, event.text);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> close() {
    _feedSubscription?.cancel();
    return super.close();
  }
}
