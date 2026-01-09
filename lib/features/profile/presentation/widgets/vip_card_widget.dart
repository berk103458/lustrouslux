import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/domain/entities/user_entity.dart';

class VipCardWidget extends StatelessWidget {
  final UserEntity user;

  const VipCardWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Dark premium gradient background
        gradient: LinearGradient(
          colors: [
            Colors.black,
            Colors.grey[900]!,
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: LustrousTheme.lustrousGold.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          // Decorative Gold Circles/Noise
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LustrousTheme.lustrousGold.withOpacity(0.05),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Logo & Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/logo.png', height: 30, color: LustrousTheme.lustrousGold),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: LustrousTheme.lustrousGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: LustrousTheme.lustrousGold.withOpacity(0.5)),
                      ),
                      child: Text(
                        user.isPremium ? "ELITE MEMBER" : "STANDARD MEMBER",
                        style: GoogleFonts.cinzel(
                          color: LustrousTheme.lustrousGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .shimmer(duration: 2000.ms, color: Colors.white), // Shining effect on badge
                  ],
                ),
                
                const Spacer(),
                
                // User Info
                Row(
                  children: [
                    // Avatar Placeholder
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: LustrousTheme.lustrousGold),
                        image: const DecorationImage(
                          image: NetworkImage("https://wsrv.nl/?url=https://ui-avatars.com/api/?background=D4AF37&color=000&name=User&size=128&bold=true"),
                           // Using generic avatar but could use user photo if available
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.email.split('@')[0].toUpperCase(), // Rough Username
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          user.email,
                          style: GoogleFonts.outfit(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Bottom Decor: Card Number Style
                Text(
                  "UID: ${user.uid.substring(0, 8)} • • • •  • • • •", 
                  style: TextStyle(
                    color: Colors.white30,
                    fontFamily: 'Courier', 
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          
          // Border Shine Animation
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: LustrousTheme.lustrousGold.withOpacity(0.3), width: 1),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .boxShadow(
                  end: BoxShadow(
                    color: LustrousTheme.lustrousGold.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                  duration: 2.seconds,
               ),
            ),
          ),
        ],
      ),
    );
  }
}
