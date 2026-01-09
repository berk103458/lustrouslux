import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/get_comments.dart';
import 'package:intl/intl.dart';

class CommentsSheet extends StatefulWidget {
  final String feedId;
  final String currentUid;
  final String currentUsername;

  const CommentsSheet({
    super.key,
    required this.feedId,
    required this.currentUid,
    required this.currentUsername,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  late Stream<List<Map<String, dynamic>>> _commentsStream;

  @override
  void initState() {
    super.initState();
    _commentsStream = sl<GetComments>().call(widget.feedId);
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      context.read<FeedBloc>().add(AddCommentEvent(
            feedId: widget.feedId,
            uid: widget.currentUid,
            username: widget.currentUsername,
            text: text,
          ));
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Yorumlar",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _commentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: LustrousTheme.lustrousGold));
                }
                
                final comments = snapshot.data ?? [];
                
                if (comments.isEmpty) {
                  return const Center(child: Text("Henüz yorum yok. İlk yorumu sen yap!", style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final timestamp = (comment['timestamp'] as dynamic); // Could be Timestamp or null
                    final date = timestamp != null 
                        ? (timestamp is DateTime ? timestamp : timestamp.toDate()) 
                        : DateTime.now();

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: LustrousTheme.lustrousGold,
                        radius: 16,
                        child: Icon(Icons.person, color: Colors.black, size: 16),
                      ),
                      title: Text(
                        comment['username'] ?? 'User',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment['text'] ?? '', style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMd().add_Hm().format(date),
                            style: TextStyle(color: Colors.grey[600], fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          const Divider(color: Colors.grey),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 16,
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Yorum yap...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.black,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              IconButton(
                onPressed: _submitComment,
                icon: const Icon(Icons.send, color: LustrousTheme.lustrousGold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
