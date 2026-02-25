import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redstring/features/auth/intro_screen_1.dart';
import 'package:redstring/home/screens/home_screen.dart';
import 'package:redstring/providers/auth_provider.dart';
import 'features/heart_beat/onboarding/heart_onboarding_screen.dart';
import 'features/heart_beat/screen.dart' as heart;
import 'features/game/onboarding/game_onboarding_screen.dart';
import 'features/game/screen.dart' as game;
import 'features/adventure/onboarding/adventure_onboarding_screen.dart';
import 'features/adventure/screen.dart' as adventure;
import 'package:redstring/features/memory/screen.dart' as memory;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RedString',
      theme: ThemeData(useMaterial3: true),

      routes: {
        '/auth/intro': (context) => const IntroScreen1(),
        '/memory_main': (context) => const memory.MemoryScreen(),
        '/heart_onboarding': (context) => const HeartOnboardingScreen(),
        '/heart_main': (context) => const heart.HeartbeatScreen(),
        '/game_onboarding': (context) => const GameOnboardingScreen(),
        '/game_main': (context) => const game.GameScreen(),
        '/adventure_onboarding': (context) => const AdventureOnboardingScreen(),
        '/adventure_main': (context) => const adventure.AdventureScreen(),
      },

      home: _AuthWrapper(),
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (authProvider.user != null) {
          return const HomeScreen();
        } else {
          return const IntroScreen1();
        }
      },
    );
  }
}
