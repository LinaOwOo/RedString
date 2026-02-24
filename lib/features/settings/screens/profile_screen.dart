import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redstring/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading && auth.userData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Данные пользователя
        final displayName = auth.displayName ?? 'Пользователь';
        final email = auth.email ?? '';
        final photoUrl = auth.photoUrl;
        final isLinked = auth.isPartnerLinked;
        final partnerId = auth.partnerId;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Профиль'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => auth.logout(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 👤 Аватар + имя
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    // Кнопка смены фото (вызов ImagePicker + upload)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () => _pickImage(auth),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(email, style: TextStyle(color: Colors.grey[600])),

                const SizedBox(height: 32),

                // 💕 Секция партнёра
                _buildPartnerSection(auth, partnerId),

                const SizedBox(height: 24),

                // ⚙️ Кнопки действий
                ElevatedButton.icon(
                  onPressed: () => _editProfile(auth),
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать профиль'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPartnerSection(AuthProvider auth, String? partnerId) {
    if (partnerId == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.favorite_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text('Партнёр не подключён'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Переход на PartnerLinkingScreen
                  Navigator.pushNamed(context, '/partner-linking');
                },
                child: const Text('Подключить партнёра'),
              ),
            ],
          ),
        ),
      );
    }

    // Если партнёр подключён — загружаем его данные через Stream
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(partnerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final partner = snapshot.data!.data() as Map<String, dynamic>?;
        return Card(
          color: Colors.pink[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: partner?['photoUrl'] != null
                          ? NetworkImage(partner!['photoUrl'])
                          : null,
                      child: partner?['photoUrl'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        partner?['displayName'] ?? 'Партнёр',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Chip(
                      label: Text('Подключено', style: TextStyle(fontSize: 12)),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _confirmUnlink(auth, partnerId),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Отключиться'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmUnlink(AuthProvider auth, String partnerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Отключить партнёра?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Отключить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Обновляем оба документа: убираем partnerId
        final batch = FirebaseFirestore.instance.batch();
        final myRef = FirebaseFirestore.instance
            .collection('users')
            .doc(auth.userId);
        final partnerRef = FirebaseFirestore.instance
            .collection('users')
            .doc(partnerId);

        batch.update(myRef, {'partnerId': FieldValue.delete()});
        batch.update(partnerRef, {'partnerId': FieldValue.delete()});

        await batch.commit();
        // await auth._loadUserData();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Партнёр отключён')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
        }
      }
    }
  }

  Future<void> _pickImage(AuthProvider auth) async {
    // TODO: Реализовать выбор фото через image_picker + загрузку в Firebase Storage
    // После загрузки: await auth.updateProfile(photoUrl: downloadedUrl);
  }

  Future<void> _editProfile(AuthProvider auth) async {
    // TODO: Диалог редактирования displayName
  }
}
