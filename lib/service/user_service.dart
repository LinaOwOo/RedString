import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> findUserIdByEmail(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();
    return snapshot.docs.isEmpty ? null : snapshot.docs.first.id;
  }

  Future<void> linkWithPartner(String partnerEmail) async {
    final currentUserId = _auth.currentUser!.uid;
    final partnerId = await findUserIdByEmail(partnerEmail);

    if (partnerId == null) throw Exception('Пользователь не найден');
    if (partnerId == currentUserId)
      throw Exception('Нельзя подключиться к себе');

    final currentUserDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get();
    final partnerDoc = await _firestore
        .collection('users')
        .doc(partnerId)
        .get();

    if (currentUserDoc.data()?['partnerId'] != null)
      throw Exception('Вы уже подключены');
    if (partnerDoc.data()?['partnerId'] != null)
      throw Exception('Партнёр уже подключён');

    await _firestore.collection('users').doc(currentUserId).update({
      'partnerId': partnerId,
    });
    await _firestore.collection('users').doc(partnerId).update({
      'partnerId': currentUserId,
    });
  }

  Stream<Map<String, dynamic>?> userStream() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.exists ? snapshot.data() : null);
  }
}
