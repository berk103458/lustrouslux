import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/secure_image.dart';
import '../../domain/entities/feed_entity.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../widgets/comments_sheet.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/is_post_liked.dart';

class FeedItemWidget extends StatefulWidget {
  final FeedEntity post;
  final String currentUid;
  final String currentUsername;

  const FeedItemWidget({
    super.key,
    required this.post,
    required this.currentUid,
    required this.currentUsername,
  });

  @override
  State<FeedItemWidget> createState() => _FeedItemWidgetState();
}

class _FeedItemWidgetState extends State<FeedItemWidget> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    final isLiked = await sl<IsPostLiked>().call(widget.post.id, widget.currentUid);
    if (mounted) setState(() => _isLiked = isLiked);
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    
    context.read<FeedBloc>().add(ToggleLikeEvent(
      feedId: widget.post.id,
      uid: widget.currentUid,
      isLiked: !_isLiked, // The OLD state, passed to logic to know action? No, ToggleLikeEvent usually expects "status to set" or "previous status". 
                          // My UseCase logic: `if (isLiked) unlike else like`. 
                          // So I should pass the *current state before toggle* OR simply trigger.
                          // Let's check Bloc logic: `await toggleLike(event.feedId, event.uid, event.isLiked);`
                          // UseCase: `if (isLiked) unlike else like`.
                          // So `event.isLiked` should be the status *before* the click?
                          // Yes. If I was liked, I pass true, so it unlikes.
    ));
    // Wait, let's correct logic: 
    // If I just toggled _isLiked to TRUE, it means previous was FALSE.
    // So I should pass FALSE to the event so the backend knows "It WAS false, so Like it".
    // Alternatively, just pass the *Target State*?
    // Let's rely on standard toggle logic: Pass the state *at the moment of action triggering*.
    // If _isLiked (UI) is now true, it means we WANT to like.
    // My UseCase `call(..., bool isLiked)` checks `if (isLiked) unlike`. 
    // So if I pass `false`, it likes. If I pass `true`, it unlikes.
    // So I should pass the *State I want to move away from* (The state before toggle).
    // Correct.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: LustrousTheme.lustrousGold,
                  radius: 16,
                  child: Icon(Icons.star, color: Colors.black, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  "LUSTROUS OFFICIAL",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat.MMMd().format(widget.post.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          // Image
          GestureDetector(
            onTap: () {
               if (widget.post.externalUrl != null && widget.post.externalUrl!.isNotEmpty) {
                 launchUrl(Uri.parse(widget.post.externalUrl!));
               }
            },
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 200, maxHeight: 500),
              child: SecureImage(
                imageUrl: widget.post.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // LIKE BUTTON
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.white
                      ),
                      onPressed: _toggleLike,
                    ),
                    if (_likeCount > 0)
                      Text("$_likeCount", style: const TextStyle(color: Colors.white)),
                    
                    const SizedBox(width: 16),
                    
                    // COMMENT BUTTON
                    IconButton(
                      icon: const Icon(Icons.comment_outlined, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (c) => Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
                            child: CommentsSheet(
                              feedId: widget.post.id,
                              currentUid: widget.currentUid,
                              currentUsername: widget.currentUsername,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const Spacer(),
                    
                    // SHARE
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.white),
                      onPressed: () {
                         Share.share('${widget.post.title}\n\n${widget.post.description}\n\nCheck it out at LustrousLux app!');
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Caption
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: "${widget.post.title}  ",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextSpan(
                        text: widget.post.description,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF222222)),
        ],
      ),
    );
  }
}
