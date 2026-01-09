import 'package:equatable/equatable.dart';
import '../../domain/entities/feed_entity.dart';

abstract class FeedState extends Equatable {
  const FeedState();
  
  @override
  List<Object> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<FeedEntity> feed;

  const FeedLoaded(this.feed);

  @override
  List<Object> get props => [feed];
}

class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);

  @override
  List<Object> get props => [message];
}
