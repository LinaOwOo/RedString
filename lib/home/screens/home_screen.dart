import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redstring/features/adventure/onboarding/adventure_onboarding_screen.dart';
import 'package:redstring/features/game/onboarding/game_onboarding_screen.dart';
import 'package:redstring/features/heart_beat/onboarding/heart_onboarding_screen.dart';
import 'package:redstring/features/heart_beat/screen.dart';
import 'package:redstring/features/memory/onboarding/memory_onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Вспомогательная функция: проверить и открыть игру
  Future<void> _openGame(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('game_onboarding_seen') ?? false;

    if (seen) {
      // Уже прошёл — сразу в игру
      Navigator.pushNamed(context, '/game_main');
    } else {
      // Нужно пройти онбординг
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GameOnboardingScreen()),
      );
    }
  }

  void _openHeartbeat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HeartbeatScreen()),
    );
  }

  // Аналогично для сердца
  Future<void> _openHeart(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('heart_onboarding_seen') ?? false;

    if (seen) {
      Navigator.pushNamed(context, '/heart_main');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HeartOnboardingScreen()),
      );
    }
  }

  // И для приключений
  Future<void> _openAdventure(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('adventure_onboarding_seen') ?? false;

    if (seen) {
      Navigator.pushNamed(context, '/adventure_main');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdventureOnboardingScreen()),
      );
    }
  }

  //Для воспоминаний
  Future<void> _openMemories(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('memories_onboarding_seen') ?? false;

    if (seen) {
      Navigator.pushNamed(context, '/memory_main');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MemoriesOnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC9C7FF), Color(0xFFF5F4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SvgPicture.asset(
                      'assets/heart_placeholder.svg',
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 220,
                  child: GestureDetector(
                    onTap: () => _openGame(context),
                    child: SvgPicture.asset(
                      'assets/game_icon.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 157,
                        child: GestureDetector(
                          onTap: () => _openAdventure(context),
                          child: SvgPicture.asset(
                            'assets/travel.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 157,
                        child: GestureDetector(
                          onTap: () => _openMemories(context),
                          child: SvgPicture.asset(
                            'assets/memory.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 220,
                  child: GestureDetector(
                    onTap: () => _openHeartbeat(context),
                    child: SvgPicture.asset(
                      'assets/heart.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFC9C7FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(26, 0, 0, 0),
              blurRadius: 12,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: SvgPicture.asset('assets/home.svg', width: 32, height: 32),
              onPressed: () {
                // Остаёмся здесь
              },
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/heaart.svg',
                width: 32,
                height: 32,
              ),
              onPressed: () => _openHeart(context),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/gamepad.svg',
                width: 32,
                height: 32,
              ),
              onPressed: () => _openGame(context),
            ),
            IconButton(
              icon: SvgPicture.asset('assets/map.svg', width: 32, height: 32),
              onPressed: () => _openAdventure(context),
            ),
            IconButton(
              icon: SvgPicture.asset('assets/user.svg', width: 32, height: 32),
              onPressed: () {
                // Профиль
              },
            ),
          ],
        ),
      ),
    );
  }
}
