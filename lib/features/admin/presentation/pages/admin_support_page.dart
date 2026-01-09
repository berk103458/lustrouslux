import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/get_support_tickets.dart';
import '../../domain/usecases/reply_to_ticket.dart';
import '../../domain/usecases/delete_ticket.dart';
import '../../../../core/theme/theme.dart';
import '../../../profile/presentation/support_chat_page.dart';

class AdminSupportPage extends StatelessWidget {
  const AdminSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LustrousTheme.midnightBlack,
      appBar: AppBar(
        title: const Text("GELEN TALEPLER"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: sl<GetSupportTickets>().call(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: LustrousTheme.lustrousGold));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return const Center(child: Text("Henüz talep yok.", style: TextStyle(color: Colors.grey)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final timestamp = (ticket['timestamp'] as dynamic);
              final date = timestamp != null 
                  ? (timestamp is DateTime ? timestamp : timestamp.toDate()) 
                  : DateTime.now();

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SupportChatPage(
                        ticketId: ticket['id'],
                        subject: ticket['subject'] ?? 'Talep',
                        isAdmin: true,
                        userUid: ticket['uid'],
                      )));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ticket['subject'] ?? 'No Subject',
                                  style: const TextStyle(color: LustrousTheme.lustrousGold, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      DateFormat('dd MMM HH:mm').format(date),
                                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: Colors.grey[900],
                                          title: const Text("Talebi Sil", style: TextStyle(color: Colors.white)),
                                          content: const Text("Bu destek talebini silmek istediğine emin misin? Bu işlem geri alınamaz.", style: TextStyle(color: Colors.white70)),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İPTAL", style: TextStyle(color: Colors.grey))),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.pop(ctx);
                                                try {
                                                  await sl<DeleteTicket>().call(ticket['id']);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Talep silindi."), backgroundColor: Colors.redAccent));
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
                                                }
                                              },
                                              child: const Text("SİL", style: TextStyle(color: Colors.redAccent)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ticket['email'] ?? 'No Email',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const Divider(color: Colors.white10),
                          // Indicate last message if available, else just a prompt to open
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text("Sohbeti Görüntüle >", style: TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


