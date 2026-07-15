import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'data/services/language_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await L10n.init();
  // TODO AdMob: await AdService.init();
  runApp(const IslamicAiApp());
}

class IslamicAiApp extends StatefulWidget {
  const IslamicAiApp({super.key});
  @override State<IslamicAiApp> createState() => _IslamicAiAppState();
}

class _IslamicAiAppState extends State<IslamicAiApp> {
  bool _showOnboarding = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final show = await OnboardingScreen.shouldShow();
    if (!mounted) return;
    setState(() { _showOnboarding = show; _checked = true; });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tefsir AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: L10n.locale,
      supportedLocales: const [
        Locale('tr'), Locale('en'), Locale('ar'), Locale('fa'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: L10n.direction,
          child: child!,
        );
      },
      home: _checked
          ? (_showOnboarding ? const OnboardingScreen() : const HomeScreen())
          : const _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
    );
  }
}
