import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/theme.dart';
import 'core/services/notification_service.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/vault/presentation/bloc/vault_bloc.dart';
import 'features/feed/presentation/bloc/feed_bloc.dart';
import 'features/core/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Service Locator
  await di.init();

  // Initialize Notifications
  await di.sl<NotificationService>().init(null);

  // Bypass SSL certificate errors
  HttpOverrides.global = MyHttpOverrides();

  runApp(const LustrousLuxApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class LustrousLuxApp extends StatelessWidget {
  const LustrousLuxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(AppStarted()),
        ),
        BlocProvider(
          create: (_) => di.sl<VaultBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<FeedBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'LustrousLux',
        debugShowCheckedModeBanner: false,
        theme: LustrousTheme.darkTheme,
        home: const SplashPage(),
      ),
    );
  }
}


// Keeping PlaceholderHomePage as HomePage for now, moving it to its own file or using the existing one.
// We will use the one created in features/home/presentation/pages/home_page.dart

