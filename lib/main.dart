import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/screens/auth_screen.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/mock_user_entity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: GuardianApp()));
}

class GuardianApp extends ConsumerWidget {
  const GuardianApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardian',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: authState.when(
        data: (user) {
          if (user != null) return HomeScreen(user: user);
          return const AuthScreen();
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}

