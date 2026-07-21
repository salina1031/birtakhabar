import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/news_provider.dart';
import 'providers/alerts_provider.dart';
import 'providers/saved_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';

class BirtaKhabarApp extends StatelessWidget {
  const BirtaKhabarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => NotificationService()),
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(
            ctx.read<AuthService>(),
            ctx.read<NotificationService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => NewsProvider(ctx.read<FirestoreService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AlertsProvider(ctx.read<FirestoreService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SavedProvider(ctx.read<FirestoreService>()),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
