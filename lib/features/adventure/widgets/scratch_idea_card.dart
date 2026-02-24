// lib/features/adventure/widgets/scratch_idea_card.dart

import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';

class ScratchIdeaCard extends StatefulWidget {
  final String idea;
  final VoidCallback onReveal;

  const ScratchIdeaCard({
    super.key,
    required this.idea,
    required this.onReveal,
  });

  @override
  State<ScratchIdeaCard> createState() => _ScratchIdeaCardState();
}

class _ScratchIdeaCardState extends State<ScratchIdeaCard> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    // Квадрат: 70% от меньшей стороны экрана
    final size = MediaQuery.of(context).size;
    final cardSize = size.shortestSide * 0.7;

    return Center(
      child: SizedBox(
        width: cardSize,
        height: cardSize,
        child: Scratcher(
          brushSize: 35,
          threshold: 50,
          color: const Color(0xFFFFB6C1), // нежно-розовый
          onChange: (progress) {
            if (progress > 0.8 && !_isRevealed) {
              setState(() => _isRevealed = true);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onReveal();
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Фоновая "замазка" с волнистой линией
                if (!_isRevealed)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFFFFB6C1),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(200, 60),
                          painter: WaveOverlayPainter(),
                        ),
                      ),
                    ),
                  ),
                // Текст или подсказка
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _isRevealed
                        ? Text(
                            widget.idea,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            'Проведите пальцем, чтобы раскрыть идею 💖',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Волнистая линия — как на твоём макете
class WaveOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.3,
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height / 2,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
