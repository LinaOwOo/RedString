import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDCD6F7), Color(0xFFFFFFFF)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(child: child),
      ),
    );
  }
}
