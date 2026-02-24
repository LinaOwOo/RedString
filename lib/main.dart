// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:redstring/providers/heartbeat_provider.dart';
import 'package:redstring/service/user_service.dart';
import 'firebase_options.dart';
import 'package:redstring/app.dart';
import 'package:redstring/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HeartbeatProvider()),
        Provider(create: (_) => UserService()),
      ],
      child: const App(),
    ),
  );
}
