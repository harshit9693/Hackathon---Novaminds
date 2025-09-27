import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/repositories/auth_notifier.dart';
import 'package:project/repositories/health_data_notifier.dart';
import 'package:project/repositories/mock_auth_repository.dart';

class MockUser {
  final String uid;
  final String email;
  final String? name;
  final int? age;

  MockUser({
    required this.uid,
    required this.email,
    this.name,
    this.age,
  });

  @override
  String toString() {
    return 'MockUser(uid: $uid, email: $email, name: $name, age: $age)';
  }
}
class HealthEntry {
  final DateTime date;
  final int systolic;
  final int diastolic;
  final int bloodSugar;
  final int age;
  final String? notes;

  // AI Model predictions
  final int? predictedRiskLevel;
  final double? confidence;
  final String? riskCategory;

  HealthEntry({
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.bloodSugar,
    required this.age,
    this.notes,
    this.predictedRiskLevel,
    this.confidence,
    this.riskCategory,
  });

  Map<String, dynamic> toJson() => {
    'systolic_bp': systolic,
    'diastolic_bp': diastolic,
    'blood_sugar': bloodSugar,
    'age': age,
  };
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
