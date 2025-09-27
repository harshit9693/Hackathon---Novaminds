import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/repositories/auth_notifier.dart';
import 'package:project/repositories/health_data_notifier.dart';
import 'package:project/screens/mock_user_entity.dart';

// class MockAuthRepository {
//   final AuthNotifier _authNotifier;
//
//   MockAuthRepository(this._authNotifier);
//
//   Future<MockUser?> signIn({required String email, required String password}) async {
//     await _authNotifier.signIn(email: email, password: password);
//     return _authNotifier.state.value;
//   }
//
//   Future<MockUser?> signUp({required String email, required String password}) async {
//     await _authNotifier.signUp(email: email, password: password);
//     return _authNotifier.state.value;
//   }
//
//   Future<void> signOut() async {
//     await _authNotifier.signOut();
//   }
// }

class MockAuthRepository {
  final AuthNotifier _authNotifier;

  MockAuthRepository(this._authNotifier);

  Future<MockUser?> signIn({required String email, required String password}) async {
    await _authNotifier.signIn(email: email, password: password);
    return _authNotifier.state.value;
  }

  Future<MockUser?> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
  }) async {
    await _authNotifier.signUp(
      email: email,
      password: password,
      name: name,
      age: age,
    );
    return _authNotifier.state.value;
  }

  Future<void> signOut() async {
    await _authNotifier.signOut();
  }
}



final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<MockUser?>>((ref) {
  return AuthNotifier();
});

final authRepositoryProvider = Provider<MockAuthRepository>((ref) {
  return MockAuthRepository(ref.read(authStateProvider.notifier));
});

final healthDataProvider = StateNotifierProvider<HealthDataNotifier, List<HealthEntry>>((ref) {
  return HealthDataNotifier();
});
