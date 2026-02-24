// lib/features/settings/screens/partner_linking_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redstring/service/user_service.dart';

class PartnerLinkingScreen extends StatefulWidget {
  const PartnerLinkingScreen({super.key});

  @override
  State<PartnerLinkingScreen> createState() => _PartnerLinkingScreenState();
}

class _PartnerLinkingScreenState extends State<PartnerLinkingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подключиться к партнёру')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email партнёра'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Введите email' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _linkPartner,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Подключить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _linkPartner() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      await userService.linkWithPartner(_emailController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Партнёр подключён! ❤️')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
