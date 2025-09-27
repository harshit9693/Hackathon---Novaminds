import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/screens/mock_user_entity.dart';


class AuthNotifier extends StateNotifier<AsyncValue<MockUser?>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    try {
      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Invalid email format');
      }

      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }

      final user = MockUser(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
      );

      state = AsyncValue.data(user);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
  }) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    try {
      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Invalid email format');
      }

      // Validate password
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Validate name
      if (name.trim().isEmpty) {
        throw Exception('Name cannot be empty');
      }

      if (name.trim().length < 2) {
        throw Exception('Name must be at least 2 characters');
      }

      // Validate age
      if (age < 13 || age > 120) {
        throw Exception('Age must be between 13 and 120');
      }

      final existingEmails = ['test@example.com', 'admin@test.com'];
      if (existingEmails.contains(email.toLowerCase())) {
        throw Exception('An account with this email already exists');
      }

      final user = MockUser(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name.trim(),
        age: age,
      );

      state = AsyncValue.data(user);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 200)); // Brief delay for UX
    state = const AsyncValue.data(null);
  }
}