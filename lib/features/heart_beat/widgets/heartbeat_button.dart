import 'package:flutter/material.dart';

class HeartbeatButton extends StatelessWidget {
  final bool isAnimating;
  final Animation<double> scaleAnimation;
  final VoidCallback onPressed;

  const HeartbeatButton({
    super.key,
    required this.isAnimating,
    required this.scaleAnimation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAnimating ? null : onPressed,
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.shade200.withOpacity(0.4),
                    Colors.purple.shade100.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.shade300.withOpacity(0.5),
                    blurRadius: 50,
                    spreadRadius: 30,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.favorite,
                  size: 120,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.purple.shade400.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
