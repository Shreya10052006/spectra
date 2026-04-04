import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/wearable_provider.dart';
import 'core/services/auth_service.dart';
import 'widgets/stress_overlay_wrapper.dart';
import 'navigation/bottom_nav.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure UUID is loaded/generated for backend tracking
  await AuthService.initialize();

    // Set preferred orientations and system UI
    await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => WearableProvider()),
      ],
      child: const SpectraApp(),
    ),
  );
}

class SpectraApp extends StatelessWidget {
  const SpectraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPECTRA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return StressOverlayWrapper(child: child!);
      },
      home: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          if (profileProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Colors.blue)),
            );
          }

          if (profileProvider.onboardingComplete) {
            return const BottomNavShell();
          } else {
            return const OnboardingScreen();
          }
        },
      ),
    );
  }
}
