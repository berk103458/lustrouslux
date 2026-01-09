import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/secure_image.dart';
import '../../../feed/presentation/bloc/feed_bloc.dart';
import '../../../feed/presentation/bloc/feed_state.dart';
import '../../../feed/presentation/bloc/feed_event.dart'; // Needed for LoadFeed
import '../../../feed/presentation/pages/feed_page.dart';

class LatestFeedItemWidget extends StatefulWidget {
  const LatestFeedItemWidget({super.key});

  @override
  State<LatestFeedItemWidget> createState() => _LatestFeedItemWidgetState();
}

class _LatestFeedItemWidgetState extends State<LatestFeedItemWidget> {
  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(LoadFeed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state is FeedLoaded && state.feed.isNotEmpty) {
          final latestItem = state.feed.first;
          return GestureDetector(
            onTap: () {
               Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FeedPage()),
              );
            },
            child: Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: LustrousTheme.lustrousGold),
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Stack(
                      fit: StackFit.expand,
                      children: [
                        SecureImage(
                          imageUrl: latestItem.imageUrl,
                          fit: BoxFit.cover,
                        ),
                        Container(color: Colors.black.withOpacity(0.4)), // Darken overlay
                      ],
                    ),
                    
                    // Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: LustrousTheme.lustrousGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW CONTENT',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                    // Text Content at Bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              latestItem.title.toUpperCase(),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              latestItem.description,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is FeedLoading) {
           return Container(
             height: 250,
             margin: const EdgeInsets.symmetric(horizontal: 24),
             color: Colors.black,
             child: const Center(child: CircularProgressIndicator(color: LustrousTheme.lustrousGold)),
           );
        } 
        
        // Empty State or Error: Hide or show default static
        return Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border.all(color: LustrousTheme.lustrousGold.withOpacity(0.3)),
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'NO UPDATES YET',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
          );
      },
    );
  }
}
