import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../feed/presentation/bloc/feed_bloc.dart';
import '../../../feed/presentation/bloc/feed_state.dart';
import '../../../feed/presentation/bloc/feed_event.dart'; 
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

class AdminFeedList extends StatefulWidget {
  const AdminFeedList({super.key});

  @override
  State<AdminFeedList> createState() => _AdminFeedListState();
}

class _AdminFeedListState extends State<AdminFeedList> {
  @override
  void initState() {
    super.initState();
    // Ensure Feed is loaded
    context.read<FeedBloc>().add(LoadFeed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state is FeedLoading) {
          return const Center(child: CircularProgressIndicator(color: LustrousTheme.lustrousGold));
        } else if (state is FeedError) {
          return Text('Hata: ${state.message}', style: const TextStyle(color: Colors.red));
        } else if (state is FeedLoaded) {
          if (state.feed.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Akış boş.', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.feed.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              final item = state.feed[index];
              return ListTile(
                leading: item.imageUrl.isNotEmpty
                    ? Image.network(item.imageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image, color: LustrousTheme.lustrousGold))
                    : const Icon(Icons.image, color: LustrousTheme.lustrousGold),
                title: Text(item.title, style: const TextStyle(color: Colors.white)),
                subtitle: Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: const Text('Sil?', style: TextStyle(color: Colors.white)),
                        content: Text('"${item.title}" akıştan silinecek. Emin misin?', style: const TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AdminBloc>().add(DeleteFeedItemEvent(item.id));
                            },
                            child: const Text('SİL', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink(); 
      },
    );
  }
}
