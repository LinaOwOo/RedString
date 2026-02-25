import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get userId => _user?.uid;

  String? get displayName => _userData?['displayName'];
  String? get email => _user?.email ?? _userData?['email'];
  String? get photoUrl => _userData?['photoUrl'];
  String? get partnerId => _userData?['partnerId'];
  bool get isPartnerLinked => partnerId != null;

  AuthProvider() {
    print('🔧 [AuthProvider] Constructor called — setting up listener');
    _auth.idTokenChanges().listen((User? user) async {
      print('[AuthProvider] User changed: ${user?.email}');
      _user = user;

      if (user != null) {
        await _loadUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (userId == null) return;

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _userData = doc.data();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки данных пользователя: $e');
    }
  }

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

      await userCredential.user?.updateDisplayName(name);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': name,
        'photoUrl': null,
        'partnerId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadUserData();
    } catch (e) {
      debugPrint('Ошибка регистрации: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Ошибка входа: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (userId == null) throw Exception('Пользователь не авторизован');

    final updates = <String, dynamic>{};
    if (displayName != null) {
      updates['displayName'] = displayName;
      await _user?.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl;
    }
    updates['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(userId).update(updates);
    await _loadUserData();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
