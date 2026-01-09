import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String role; // 'admin' or 'user'
  final bool isApproved;
  final bool isPremium;
  final bool isBanned;

  const UserEntity({
    required this.uid,
    required this.email,
    this.role = 'user',
    this.isApproved = false,
    this.isPremium = false,
    this.isBanned = false,
  });

  @override
  List<Object?> get props => [uid, email, role, isApproved, isPremium, isBanned];

  bool get isAdmin => role == 'admin' || uid == '2LZOwDBqDWdOafZKSw3femX1zhz1';
  
  // Override isPremium getter if needed, but since it is a final field, we can't easily override it without changing the class structure or ignoring the field.
  // Better approach: Since 'isPremium' is final, we should ensure the source data (Model) sets it true, OR we leverage a new getter 'hasPremiumAccess'.
  // However, the UI uses '.isPremium'. 
  // Let's interpret 'isPremium' field as just the DB value, but create a helper 'hasPremiumAccess' used in UI?
  // UI logic I wrote: "hasVipAccess = authState.user.isPremium || authState.user.isAdmin;"
  // Since 'isAdmin' will now be true for this UID, 'hasVipAccess' will be true.
  // So just fixing 'isAdmin' is enough for UI access!
}
