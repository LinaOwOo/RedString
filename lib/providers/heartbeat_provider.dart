import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redstring/features/heart_beat/model/heartbeat_model.dart';

class HeartbeatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<HeartBeat> _heartbeats = [];
  String? _currentUserId;
  String? _currentUserName;
  String? _partnerId;
  StreamSubscription? _subscription;

  List<HeartBeat> get heartbeats => List.unmodifiable(_heartbeats);
  String? get partnerId => _partnerId;
  bool get isConnected => _partnerId != null;

  void setCurrentUser(String userId, String userName) {
    _currentUserId = userId;
    _currentUserName = userName;
  }

  void setPartnerId(String partnerId, String partnerName) {
    _partnerId = partnerId;
    _listenToPartnerHeartbeats(partnerName);
  }

  // Отправка биения
  Future<void> sendHeartbeat() async {
    if (_currentUserId == null ||
        _partnerId == null ||
        _currentUserName == null) {
      throw Exception('Пользователь или партнёр не настроен');
    }

    final heartbeat = HeartBeat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      senderId: _currentUserId!,
      senderName: _currentUserName!,
      receiverId: _partnerId!,
      distance: 50, // TODO: рассчитать реальное расстояние
      isFromPartner: false,
    );

    // Добавляем локально для мгновенного отклика UI
    _addLocally(heartbeat);

    // Сохраняем в Firebase
    try {
      await _firestore.collection('heartbeats').add(heartbeat.toJson());
      debugPrint('✅ Сердце отправлено: ${heartbeat.id}');
    } catch (e) {
      debugPrint('❌ Ошибка отправки: $e');
      // Откат локального изменения при ошибке
      _heartbeats.removeWhere((h) => h.id == heartbeat.id);
      notifyListeners();
      rethrow;
    }
  }

  // Прослушивание биений от партнёра
  void _listenToPartnerHeartbeats(String partnerName) {
    if (_partnerId == null || _currentUserId == null) return;

    _subscription?.cancel();

    _subscription = _firestore
        .collection('heartbeats')
        .where('receiverId', isEqualTo: _currentUserId)
        .where('senderId', isEqualTo: _partnerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docChanges) {
            if (doc.type == DocumentChangeType.added) {
              final heartbeat = HeartBeat.fromJson({
                ...doc.doc.data() as Map<String, dynamic>,
                'id': doc.doc.id,
                'isFromPartner': true,
                'senderName': partnerName,
              });
              _addLocally(heartbeat);
            }
          }
        });
  }

  // Локальное добавление
  void _addLocally(HeartBeat heartbeat) {
    if (!_heartbeats.any((h) => h.id == heartbeat.id)) {
      _heartbeats.insert(0, heartbeat);
      notifyListeners();
    }
  }

  // Загрузка истории за сегодня
  Future<void> loadTodayHeartbeats() async {
    if (_currentUserId == null) return;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final querySnapshot = await _firestore
          .collection('heartbeats')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .where('timestamp', isLessThan: endOfDay.toIso8601String())
          .where(
            (FirebaseFirestore.instance
                .collection('heartbeats')
                .where('receiverId', isEqualTo: _currentUserId)
                .where('senderId', isEqualTo: _partnerId)),
          )
          .orderBy('timestamp', descending: true)
          .get();

      _heartbeats.clear();
      for (var doc in querySnapshot.docs) {
        final heartbeat = HeartBeat.fromJson({
          ...doc.data(),
          'id': doc.id,
          'isFromPartner': doc.data()['senderId'] == _partnerId,
        });
        _heartbeats.add(heartbeat);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Ошибка загрузки истории: $e');
    }
  }

  // Очистка
  void clearHeartbeats() {
    _heartbeats.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
