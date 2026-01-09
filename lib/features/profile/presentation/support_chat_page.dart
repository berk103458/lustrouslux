import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../injection_container.dart';
import '../../auth/domain/usecases/send_user_message.dart';
import '../../admin/domain/usecases/reply_to_ticket.dart';
import '../../admin/domain/usecases/close_ticket.dart';
import '../../../../core/theme/theme.dart';
import 'package:intl/intl.dart';

class SupportChatPage extends StatefulWidget {
  final String ticketId;
  final String subject;
  // status passed initially, but better to rely on stream for live updates
  final bool isAdmin;
  final String? userUid; // Required if isAdmin is true

  const SupportChatPage({
    super.key,
    required this.ticketId,
    required this.subject,
    this.isAdmin = false,
    this.userUid,
  });

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('support_tickets').doc(widget.ticketId).snapshots(),
      builder: (context, snapshot) {
         final data = snapshot.data?.data() as Map<String, dynamic>?;
         final status = data?['status'] ?? 'open';
         final isClosed = status == 'closed';
         final messages = (data?['messages'] as List<dynamic>?) ?? [];

         // Auto-scroll logic if new messages arrive
         if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                // Determine if we should scroll (e.g. if close to bottom or first load)
                // For simplicity, just jump to bottom for now on every update
                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
              }
            });
         }

        return Scaffold(
          backgroundColor: LustrousTheme.midnightBlack,
          appBar: AppBar(
            title: Column(
              children: [
                Text(widget.subject.toUpperCase(), style: const TextStyle(fontSize: 16)),
                if (isClosed)
                  const Text("(CLOSED)", style: TextStyle(color: Colors.redAccent, fontSize: 10))
                else if (data?['lastUpdated'] != null)
                   // Optionally show last active
                   const SizedBox.shrink(),
              ],
            ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            actions: [
              if (widget.isAdmin && !isClosed)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.redAccent),
                  tooltip: 'Close Ticket',
                  onPressed: () => _confirmCloseTicket(context),
                )
            ],
          ),
          body: Column(
            children: [
              // Chat List
              Expanded(
                child: messages.isEmpty
                    ? const Center(child: Text("No messages yet.", style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isUserSender = msg['sender'] == 'user';
                          final isMe = widget.isAdmin ? !isUserSender : isUserSender;
                          
                          final timestamp = DateTime.tryParse(msg['timestamp'] ?? '') ?? DateTime.now();
                          final timeStr = DateFormat('HH:mm').format(timestamp);

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isMe ? LustrousTheme.lustrousGold : Colors.white10,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                                  bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    msg['message'] ?? '',
                                    style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeStr,
                                    style: TextStyle(color: isMe ? Colors.black54 : Colors.white38, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              // Input Area or Closed Message
              if (isClosed)
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.all(16),
                   color: Colors.white10,
                   child: const Text(
                     "This ticket is closed.",
                     style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                     textAlign: TextAlign.center,
                   ),
                 )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black54,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: widget.isAdmin ? "Reply..." : "Write a message...",
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: LustrousTheme.lustrousGold,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.black, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }
    );
  }

  void _confirmCloseTicket(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Close Ticket", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to close this ticket?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          TextButton(
             onPressed: () async {
               Navigator.pop(ctx);
               try {
                 await sl<CloseTicket>().call(widget.ticketId);
                 if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket closed."), backgroundColor: Colors.redAccent));
                 }
               } catch (e) {
                 if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
               }
             }, 
             child: const Text("CLOSE", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    try {
      if (widget.isAdmin) {
         if (widget.userUid == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No User ID")));
            return;
         }
         await sl<ReplyToTicket>().call(widget.ticketId, widget.userUid!, text);
      } else {
         await sl<SendUserMessage>().call(widget.ticketId, text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }
}
