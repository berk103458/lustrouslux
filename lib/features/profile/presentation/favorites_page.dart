import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../injection_container.dart';
import '../../feed/domain/usecases/get_favorites.dart';
import '../../feed/domain/entities/feed_entity.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../feed/presentation/widgets/feed_item_widget.dart';
import '../../feed/presentation/bloc/feed_bloc.dart'; // Added FeedBloc import
import '../../../../core/theme/theme.dart';

// Creating a mini-bloc or just StreamBuilder for simplicity in this specific page
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String uid = '';
    String username = '';

    if (authState is AuthAuthenticated) {
      uid = authState.user.uid;
      username = authState.user.email;
    } else {
      return const Scaffold(body: Center(child: Text("Please login.")));
    }

    return Scaffold(
      backgroundColor: LustrousTheme.midnightBlack,
      appBar: AppBar(
        title: const Text('FAVORITES'),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (_) => sl<FeedBloc>(),
        child: StreamBuilder<List<FeedEntity>>(
          stream: sl<GetFavorites>().call(uid),
          builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator(color: LustrousTheme.lustrousGold));
             }
             if (snapshot.hasError) {
               return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
             }
             
             final feed = snapshot.data ?? [];
             
             if (feed.isEmpty) {
               return const Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                     SizedBox(height: 16),
                     Text("No favorites yet.", style: TextStyle(color: Colors.grey)),
                   ],
                 ),
               );
             }
             
             return ListView.builder(
                 padding: const EdgeInsets.only(top: 16),
                 itemCount: feed.length,
                 itemBuilder: (context, index) {
                   return FeedItemWidget(
                      post: feed[index],
                      currentUid: uid,
                      currentUsername: username,
                   );
                 },
             );
          },
        ),
      ),
    );
  }
}
