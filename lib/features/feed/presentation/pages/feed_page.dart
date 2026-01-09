import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/secure_image.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../../domain/entities/feed_entity.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/feed_item_widget.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<FeedBloc>(context).add(LoadFeed());
  }

  @override
  Widget build(BuildContext context) {
    // Get Current User Info
    final authState = context.watch<AuthBloc>().state;
    String uid = '';
    String username = 'User';
    
    if (authState is AuthAuthenticated) {
      uid = authState.user.uid;
      username = authState.user.email.split('@')[0]; // Simple username from email
    }

    return Scaffold(
      backgroundColor: LustrousTheme.midnightBlack,
      appBar: AppBar(
        title: const Text('LUSTROUS FEED'),
        centerTitle: true,
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          if (state is FeedLoading) {
            return const Center(child: CircularProgressIndicator(color: LustrousTheme.lustrousGold));
          } else if (state is FeedError) {
             return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          } else if (state is FeedLoaded) {
             if (state.feed.isEmpty) {
               return const Center(child: Text("No posts found.", style: TextStyle(color: Colors.white)));
             }
             
             return ListView.builder(
               itemCount: state.feed.length,
               itemBuilder: (context, index) {
                 return FeedItemWidget(
                   post: state.feed[index],
                   currentUid: uid,
                   currentUsername: username,
                 );
               },
             );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
