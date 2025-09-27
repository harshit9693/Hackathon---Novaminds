import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/screens/mock_user_entity.dart';

class HealthDataNotifier extends StateNotifier<List<HealthEntry>> {
  HealthDataNotifier() : super([]);

  void addEntry(HealthEntry entry) {
    state = [...state, entry];
    // Sort by date, newest first
    state.sort((a, b) => b.date.compareTo(a.date));
  }

  void removeEntry(int index) {
    state = [...state]..removeAt(index);
  }
}