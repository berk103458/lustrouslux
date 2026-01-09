import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../auth/presentation/bloc/auth_event.dart'; // For Logout
import 'widgets/vip_card_widget.dart';
import 'favorites_page.dart';
import 'settings_page.dart';
import 'support_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user from Bloc
    final authState = context.watch<AuthBloc>().state;
    
    // Safety check (should generally be authenticated here)
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;

    return Scaffold(
      backgroundColor: LustrousTheme.midnightBlack,
      appBar: AppBar(
        title: Text("MY PROFILE", style: GoogleFonts.cinzel(color: LustrousTheme.lustrousGold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. VIP Card
            Hero(
              tag: 'profile_icon', // Hero transition from Home AppBar
              child: Material(
                 color: Colors.transparent,
                 child: VipCardWidget(user: user),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 2. Settings / Menu Items
            _buildMenuItem(context, 
              icon: Icons.favorite, 
              title: "Favorites", 
              subtitle: "Your liked feed posts",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage())),
            ),
             _buildMenuItem(context, 
              icon: Icons.settings, 
              title: "Settings", 
              subtitle: "Privacy, Security, Password",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
            ),
            _buildMenuItem(context, 
              icon: Icons.help_outline, 
              title: "Support", 
              subtitle: "Contact Concierge",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportPage())),
            ),

            const SizedBox(height: 40),
            
            // 3. Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                   context.read<AuthBloc>().add(LoggedOut());
                   Navigator.of(context).pop(); // Close profile page, AuthBloc listener will likely redirect to login
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("SIGN OUT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
             const SizedBox(height: 16),
             const Text("LustrousLux v1.1.0", style: TextStyle(color: Colors.white24, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white30, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}
