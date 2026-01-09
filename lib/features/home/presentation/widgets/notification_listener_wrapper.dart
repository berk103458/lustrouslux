import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../injection_container.dart';

class NotificationListenerWrapper extends StatefulWidget {
  final Widget child;

  const NotificationListenerWrapper({super.key, required this.child});

  @override
  State<NotificationListenerWrapper> createState() => _NotificationListenerWrapperState();
}

class _NotificationListenerWrapperState extends State<NotificationListenerWrapper> {
  StreamSubscription? _subscription;
  String? _currentUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAuth();
  }

  void _checkAuth() {
    final state = context.watch<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      if (_currentUid != state.user.uid) {
        _currentUid = state.user.uid;
        _startListening(_currentUid!);
      }
    } else {
      _stopListening();
      _currentUid = null;
    }
  }

  void _startListening(String uid) {
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false) // Only unread
        .limit(1) // Just listen for existence of unread
        // Actually, to notify on *arrival*, we want a stream of additions.
        // Better: Listen to the collection ordered by time, get changes.
        .snapshots()
        .listen((snapshot) {
           for (var change in snapshot.docChanges) {
             if (change.type == DocumentChangeType.added) {
               final data = change.doc.data();
               // Check if it's recent (optional, to avoid notifying on old unread on app start)
               // For MVP, just notify.
               if (data != null) {
                 final title = data['title'] ?? 'Notification';
                 final body = data['body'] ?? '';
                 
                 sl<NotificationService>().showVipNotification(
                   title: title,
                   body: body,
                 );
                 
                 // Mark as read immediately to avoid re-notify?
                 // Or better, let user click it. For now, we leave it.
                 // Ideally mark as read when viewed.
                 // To prevent loop on restart, we might mark it here or check timestamp.
                 // We will mark it 'delivered' or similar. 
                 // For this MVP, we just show it.
                 
                 // Auto-mark read to prevent spam on next boot?
                 change.doc.reference.update({'isRead': true});
               }
             }
           }
        });
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
