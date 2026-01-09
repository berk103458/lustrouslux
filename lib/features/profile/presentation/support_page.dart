import 'package:flutter/material.dart';
import '../../../../injection_container.dart';
import '../../../../core/theme/theme.dart';
import '../../auth/domain/usecases/create_ticket.dart';
import '../../auth/domain/usecases/get_user_tickets.dart';
import 'support_chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  void _showCreateTicketModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LustrousTheme.midnightBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "New Support Ticket",
              style: TextStyle(color: LustrousTheme.lustrousGold, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
             TextField(
              controller: _subjectController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Subject",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Message",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  await _submitTicket(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LustrousTheme.lustrousGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("SEND", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTicket(BuildContext modalContext) async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (subject.isEmpty || message.isEmpty || user == null) {
      ScaffoldMessenger.of(modalContext).showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    // Set loading state in the main page state if we want, or just handle async
    // Since modal is separate config, we might need a StatefulBuilder or just simple async structure.
    // For simplicity, let's close modal on success or assume quick operation.
    
    // Actually we can't easily update modal UI state from here without StatefulBuilder in modal.
    // Let's just run it.
    Navigator.pop(modalContext); // Close modal first to indicate processing started or wait?
    // Better UX: Show loading in modal. But for MVP, let's close and show snackbar in main page.
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sending ticket...")));

    final result = await sl<CreateTicket>().call(user.uid, user.email ?? 'no-email', subject, message);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${failure.message}"))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket created successfully."), backgroundColor: Colors.green));
        _subjectController.clear();
        _messageController.clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: LustrousTheme.midnightBlack,
      appBar: AppBar(
        title: const Text("ACCESS"), // Or SUPPORT
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTicketModal,
        backgroundColor: LustrousTheme.lustrousGold,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: user == null
          ? const Center(child: Text("You need to login.", style: TextStyle(color: Colors.white)))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: sl<GetUserTickets>().call(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: LustrousTheme.lustrousGold));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                }

                final tickets = snapshot.data ?? [];

                if (tickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.support_agent, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text("No support tickets yet.", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _showCreateTicketModal,
                          child: const Text("Create New Ticket", style: TextStyle(color: LustrousTheme.lustrousGold)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    final status = ticket['status'] ?? 'open';
                    final subject = ticket['subject'] ?? 'Ticket';
                    final lastUpdatedDesc = ticket['lastUpdated'];
                    
                    DateTime date;
                    if (lastUpdatedDesc is Timestamp) {
                      date = lastUpdatedDesc.toDate();
                    } else if (lastUpdatedDesc is String) {
                      date = DateTime.tryParse(lastUpdatedDesc) ?? DateTime.now();
                    } else {
                      date = DateTime.now();
                    }

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
                               subject: subject,
                               isAdmin: false,
                             )));
                           },
                           borderRadius: BorderRadius.circular(12),
                           child: Padding(
                             padding: const EdgeInsets.all(16),
                             child: Row(
                               children: [
                                 Container(
                                   padding: const EdgeInsets.all(10),
                                   decoration: BoxDecoration(
                                     color: status == 'resolved' ? Colors.green.withOpacity(0.2) : (status == 'closed' ? Colors.red.withOpacity(0.2) : Colors.orange.withOpacity(0.2)),
                                     shape: BoxShape.circle,
                                   ),
                                   child: Icon(
                                     status == 'resolved' ? Icons.check : (status == 'closed' ? Icons.lock : Icons.timelapse),
                                     color: status == 'resolved' ? Colors.green : (status == 'closed' ? Colors.red : Colors.orange),
                                     size: 20,
                                   ),
                                 ),
                                 const SizedBox(width: 16),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         subject,
                                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                       ),
                                       const SizedBox(height: 4),
                                       Text(
                                         DateFormat('dd MMM HH:mm').format(date),
                                         style: const TextStyle(color: Colors.grey, fontSize: 12),
                                       ),
                                     ],
                                   ),
                                 ),
                                 const Icon(Icons.chevron_right, color: Colors.grey),
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
