import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/pages/home_page.dart';

import 'package:get_it/get_it.dart';
import '../../../../core/services/update_service.dart';
import '../widgets/update_dialog.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}



class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Start animation and check for updates
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Minimum Splash Screen Duration
    await Future.delayed(const Duration(seconds: 4));

    // 2. Check for Updates
    try {
      final updateService = GetIt.instance<UpdateService>();
      final result = await updateService.checkForUpdate();

      if (mounted && result.hasUpdate) {
        await showDialog(
          context: context,
          barrierDismissible: !result.isForceUpdate,
          builder: (context) => UpdateDialog(
            updateInfo: result,
            onUpdatePressed: () {
              updateService.launchUpdateUrl(result.updateUrl);
            },
          ),
        ).then((_) {
            // Logic to run after dialog calls Navigator.pop or is dismissed
            if (!result.isForceUpdate) {
                 // If the user closed it without updating (and allowed to), 
                 // we assume they want to ignore THIS version.
                 // NOTE: UpdateDialog usually doesn't return value unless designed.
                 // We can simply call ignore logic here blindly if it wasn't forced?
                 // Better: Pass a callback to UpdateDialog's "Later" button if it exists.
                 // But standard BarrierDismissal means "Ignore".
                 updateService.ignoreUpdate(result.latestVersion);
            }
        });
        
        // If force update, don't proceed.
        if (result.isForceUpdate) return;
      }
    } catch (e) {
      // Ignore errors and proceed
    }

    // 3. Navigate
    if (mounted) {
      _checkAuthAndNavigate();
    }
  }

  void _checkAuthAndNavigate() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Animation
            Image.asset(
              'assets/images/logo.png',
              width: 200,
            )
                .animate()
                .fadeIn(duration: 2000.ms, curve: Curves.easeIn)
                .shimmer(duration: 2500.ms, color: const Color(0xFFD4AF37))
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 2000.ms),
            
            const SizedBox(height: 20),

            // Text Animation ("Tracking Out" effect)
            Text(
              'LUSTROUS LUX',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    letterSpacing: 2.0,
                    color: const Color(0xFFD4AF37),
                    fontSize: 24,
                  ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 1500.ms)
                .custom(
                  duration: 3000.ms,
                  builder: (context, value, child) => Text(
                    'LUSTROUS LUX',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          letterSpacing: 2.0 + (value * 8), // Tracking out from 2 to 10
                          color: const Color(0xFFD4AF37),
                          fontSize: 24,
                        ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
