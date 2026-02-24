import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redstring/core/constants/app_colors.dart';
import 'package:redstring/features/auth/intro_screen_2.dart';

class IntroScreen1 extends StatelessWidget {
  const IntroScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            child: SvgPicture.asset('assets/heart_top.svg', width: 350),
          ),

          Positioned(
            bottom: -10,
            right: -40,
            child: SvgPicture.asset('assets/heart_bottom.svg', width: 350),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    'Это приложение посвещается самым милым парам',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const Spacer(flex: 2),
                  FloatingActionButton(
                    backgroundColor: AppColors.background,
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const IntroScreen2()),
                    ),
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
