// lib/features/heart_beat/screen.dart

import 'package:flutter/material.dart';

class MemoryScreen extends StatelessWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Наши воспоминания')),
      body: Center(child: Text('Основной экран — Наши воспоминания')),
    );
  }
}
