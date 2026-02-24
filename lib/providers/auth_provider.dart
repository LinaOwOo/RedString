import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ← ДОБАВЛЕН ИМПОРТ

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userData; // Данные из Firestore
  bool _isLoading = false;

  // === Getters ===
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get userId => _user?.uid;

  // Удобные геттеры для полей профиля
  String? get displayName => _userData?['displayName'];
  String? get email => _user?.email ?? _userData?['email'];
  String? get photoUrl => _userData?['photoUrl'];
  String? get partnerId => _userData?['partnerId'];
  bool get isPartnerLinked => partnerId != null;

  AuthProvider() {
    print('🔧 [AuthProvider] Constructor called — setting up listener');
    _auth.idTokenChanges().listen((User? user) async {
      print('✅ [AuthProvider] User changed: ${user?.email}');
      _user = user;

      if (user != null) {
        await _loadUserData(); // Загружаем расширенные данные из Firestore
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  // === Загрузка данных пользователя из Firestore ===
  Future<void> _loadUserData() async {
    if (userId == null) return;

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _userData = doc.data();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Ошибка загрузки данных пользователя: $e');
    }
  }

  // === Stream для реактивного обновления профиля ===
  Stream<Map<String, dynamic>?> userDataStream() {
    if (userId == null) return Stream.value(null);

    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        _userData = snapshot.data();
        notifyListeners();
        return _userData;
      }
      return null;
    });
  }

  // === Регистрация (обновлено) ===
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Обновляем displayName в Firebase Auth
      await userCredential.user?.updateDisplayName(name);

      // 🔥 Сохраняем профиль в Firestore с согласованными полями
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': name, // ✅ Согласовано с Firebase Auth
        'photoUrl': null, // ✅ Добавлено для аватара
        'partnerId': null, // ✅ Для связи с партнёром
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadUserData(); // Загружаем только что созданные данные
    } catch (e) {
      debugPrint('❌ Ошибка регистрации: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === Логин (с загрузкой данных) ===
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // _loadUserData() вызывается автоматически через idTokenChanges listener
    } catch (e) {
      debugPrint('❌ Ошибка входа: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === Обновление профиля (НОВОЕ) ===
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (userId == null) throw Exception('Пользователь не авторизован');

    final updates = <String, dynamic>{};
    if (displayName != null) {
      updates['displayName'] = displayName;
      await _user?.updateDisplayName(displayName); // Синхронизируем с Auth
    }
    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl;
    }
    updates['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(userId).update(updates);
    await _loadUserData(); // Обновляем локальное состояние
  }

  // === Выход ===
  Future<void> logout() async {
    await _auth.signOut();
    // _userData очистится автоматически через listener
  }
}
