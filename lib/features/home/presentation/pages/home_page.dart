import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../vault/presentation/pages/vault_page.dart';
import '../../../feed/presentation/pages/feed_page.dart';
import '../../../../features/profile/presentation/profile_page.dart';
import '../../../admin/presentation/pages/admin_page.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/notification_service.dart';

import '../widgets/membership_card.dart';
import '../widgets/latest_feed_item_widget.dart';
import '../widgets/notification_listener_wrapper.dart';

import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Instant Logout Navigation
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          bool isPremium = false;
          bool isAdmin = false;
          String email = 'Loading...';
          
          if (state is AuthAuthenticated) {
            isPremium = state.user.isPremium;
            isAdmin = state.user.isAdmin;
            email = state.user.email.split('@').first;
            
            // Initialize Notifications
            di.sl<NotificationService>().init(state.user.uid);
          }

          final hasVipAccess = isPremium || isAdmin;

          return NotificationListenerWrapper( // Added Wrapper
            child: Scaffold(
            appBar: AppBar(
              title: const Text('LUSTROUS LUX'),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                    },
                    child: Hero(
                      tag: 'profile_icon',
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: LustrousTheme.lustrousGold.withOpacity(0.2),
                        child: const Icon(Icons.person, color: LustrousTheme.lustrousGold, size: 20),
                      ),
                    ),
                  ),
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const AdminPage()),
                      );
                    },
                  ),
              ],
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MembershipCard(
                      memberName: email.toUpperCase(),
                      memberSince: '2024',
                      isPremium: hasVipAccess,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'THE VAULT',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      hasVipAccess ? 'Welcome, VIP Member.' : 'Welcome to Lustrous Lux.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    // VAULT BUTTON (Start of Restriction)
                    ElevatedButton.icon(
                      icon: Icon(Icons.lock_open, color: hasVipAccess ? Colors.black : Colors.grey),
                      label: Text(
                          'OPEN VAULT ${hasVipAccess ? "" : "(VIP ONLY)"}',
                           style: TextStyle(color: hasVipAccess ? Colors.black : Colors.grey),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasVipAccess ? LustrousTheme.lustrousGold : Colors.black,
                        side: BorderSide(color: hasVipAccess ? LustrousTheme.lustrousGold : Colors.grey),
                      ),
                      onPressed: () async {
                        if (!hasVipAccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Access Denied: The Vault is for VIP Members only.')),
                            );
                            return;
                        }
                        
                        final didAuthenticate = await di.sl<BiometricService>().authenticate();
                        if (didAuthenticate && context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const VaultPage()),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Access Denied: Biometric Verification Failed')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // FEED BUTTON (Unlocked for Everyone)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.dynamic_feed, color: Colors.black),
                      label: const Text('LUSTROUS FEED'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LustrousTheme.lustrousGold,
                        side: const BorderSide(color: LustrousTheme.lustrousGold),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const FeedPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const LatestFeedItemWidget(),
                  ],
                ),
              ),
            ),
          ));
        },
      ),
    );
  }
}
