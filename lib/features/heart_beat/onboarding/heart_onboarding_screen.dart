// lib/features/adventure/onboarding/adventure_onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdventureOnboardingScreen extends StatefulWidget {
  const AdventureOnboardingScreen({super.key});

  @override
  State<AdventureOnboardingScreen> createState() =>
      _AdventureOnboardingScreenState();
}

class _AdventureOnboardingScreenState extends State<AdventureOnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adventure_onboarding_seen', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withAlpha(
              200,
            ), // .withValues(alpha: 0.8) → deprecated
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(50),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // 🔝 Заголовок и подзаголовок
              const Text(
                'Новое приключение',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Отправляйтесь в совместное путешествие и создавайте незабываемые моменты вместе.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // 🖼️ SVG
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    'assets/onboarding_adventure_1.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🟣 Кнопка "Поехали" — по центру
              ElevatedButton(
                onPressed: () async {
                  await _markAsSeen();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/adventure_main');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  backgroundColor: const Color(0xFFC9C7FF),
                  foregroundColor: Colors.black,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Поехали', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
