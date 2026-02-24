import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/heartbeat_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/heartbeat_tile.dart';

const Color appGradientColor = Color(0xFFC9C7FF);

class HeartbeatScreen extends StatefulWidget {
  const HeartbeatScreen({super.key});

  @override
  State<HeartbeatScreen> createState() => _HeartbeatScreenState();
}

class _HeartbeatScreenState extends State<HeartbeatScreen> {
  bool _isAnimating = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeHeartbeat();
  }

  Future<void> _initializeHeartbeat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final heartbeatProvider = Provider.of<HeartbeatProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      final user = authProvider.user!;

      heartbeatProvider.setCurrentUser(user.uid, user.displayName ?? 'Вы');

      await heartbeatProvider.loadTodayHeartbeats();
    }
  }

  Future<void> _playHeartbeatHaptic() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('⚠️ Haptic error: $e');
    }
  }

  Future<void> _onHeartPressed() async {
    if (_isAnimating || _isSending) return;

    final heartbeatProvider = Provider.of<HeartbeatProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isAnimating = true;
      _isSending = true;
    });

    try {
      await _playHeartbeatHaptic();
      await heartbeatProvider.sendHeartbeat();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.favorite, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Сердце отправлено!'),
              ],
            ),
            backgroundColor: appGradientColor,
            duration: const Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Ошибка: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Биение сердец'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
          tooltip: 'На главную',
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              appGradientColor.withOpacity(0.3),
              appGradientColor.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Кнопка-сердце (круг с иконкой)
              Expanded(
                flex: 3,
                child: Center(
                  child: GestureDetector(
                    onTap: _isSending ? null : _onHeartPressed,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      transform: Matrix4.identity()
                        ..scale(_isAnimating ? 1.1 : 1.0),
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          // КРУГЛАЯ ФОРМА
                          shape: BoxShape.circle,
                          // БЕЛЫЙ ФОН ВНУТРИ
                          color: Colors.white,
                          // ✅ РАЗМЫТИЕ / СВЕЧЕНИЕ ВОКРУГ
                          boxShadow: [
                            // Внешнее свечение (мягкое)
                            BoxShadow(
                              color: appGradientColor.withOpacity(0.6),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            // Дополнительное свечение (более сильное)
                            BoxShadow(
                              color: appGradientColor.withOpacity(0.4),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                            // Дальнее свечение (для градиента)
                            BoxShadow(
                              color: appGradientColor.withOpacity(0.2),
                              blurRadius: 80,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                        // ✅ ФИОЛЕТОВАЯ ОБОДКА (внутри контейнера)
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: appGradientColor,
                              width: 20,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ИКОНКА СЕРДЦА
                              Icon(
                                Icons.favorite,
                                size: 80,
                                color: appGradientColor,
                              ),
                              const SizedBox(height: 12),
                              // ТЕКСТ
                              const Text(
                                'Нажми!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Нижняя панель со списком
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: appGradientColor.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: HeartbeatList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
