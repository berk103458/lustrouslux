import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MembershipCard extends StatefulWidget {
  final String memberName;
  final String memberSince;
  final bool isPremium;

  const MembershipCard({
    super.key,
    required this.memberName,
    required this.memberSince,
    this.isPremium = false,
  });

  @override
  State<MembershipCard> createState() => _MembershipCardState();
}

class _MembershipCardState extends State<MembershipCard> {
  double _x = 0;
  double _y = 0;

  @override
  void initState() {
    super.initState();
    gyroscopeEvents.listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          _x += event.y * 0.2; // Tilt up/down
          _y += event.x * 0.2; // Tilt left/right
          _x = _x.clamp(-1.0, 1.0);
          _y = _y.clamp(-1.0, 1.0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isPremium ? const Color(0xFFD4AF37) : Colors.grey.shade400;
    final shadowColor = widget.isPremium ? const Color(0xFFD4AF37).withOpacity(0.5) : Colors.black.withOpacity(0.5);
    final labelText = widget.isPremium ? 'GOLD VIP' : 'STANDARD MEMBER';

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: widget.isPremium ? 20 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Metallic/Noise texture (simulated with gradient)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
              ),
            ),
          ),

          // Holographic Shine Effect controlled by Gyroscope
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            left: -100 - (_y * 50),
            top: -100 - (_x * 50),
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  radius: 0.6,
                ),
              ),
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/logo.png', width: 40, height: 40),
                    Text(
                      labelText,
                      style: TextStyle(
                        color: themeColor, 
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.memberName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1.2,
                        fontFamily: 'Courier', // Monospace for card look
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MEMBER SINCE ${widget.memberSince}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
