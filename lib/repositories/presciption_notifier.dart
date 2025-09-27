import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/repositories/presciption_entity.dart';

class PrescriptionNotifier extends StateNotifier<List<Prescription>> {
  PrescriptionNotifier() : super([]);

  void addPrescription(Prescription prescription) {
    state = [...state, prescription];
    // Sort by upload date, newest first
    state.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
  }

  void updatePrescription(String id, Prescription updatedPrescription) {
    state = [
      for (final prescription in state)
        if (prescription.id == id) updatedPrescription else prescription,
    ];
  }

  void removePrescription(String id) {
    state = state.where((prescription) => prescription.id != id).toList();
  }

  List<String> getAllMedications() {
    final allMeds = <String>[];
    for (final prescription in state) {
      allMeds.addAll(prescription.medications);
    }
    return allMeds.toSet().toList(); // Remove duplicates
  }
}

class MockPrescriptionAnalyzer {
  static Future<String> analyzePrescription(String fileName) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock analysis based on common prescription patterns
    final mockAnalyses = [
      "This prescription contains medications for blood pressure management. Take Lisinopril 10mg once daily in the morning. Monitor for side effects like dizziness or dry cough.",
      "Diabetes management prescription detected. Metformin 500mg twice daily with meals. Check blood sugar regularly and maintain a healthy diet.",
      "Antibiotic course identified. Complete the full course of Amoxicillin even if symptoms improve. Take with food to reduce stomach upset.",
      "Pain management medication prescribed. Use Ibuprofen as needed, maximum 3 times daily. Avoid alcohol and monitor for stomach irritation.",
      "Heart medication detected. Atorvastatin for cholesterol management. Take in the evening with or without food. Regular blood tests recommended.",
    ];

    return mockAnalyses[DateTime.now().millisecond % mockAnalyses.length];
  }

  static List<String> extractMedications(String fileName) {
    // Mock medication extraction
    final mockMedications = [
      ["Lisinopril 10mg", "Aspirin 81mg", "Vitamin D3"],
      ["Metformin 500mg", "Insulin Glargine", "Blood Glucose Strips"],
      ["Amoxicillin 500mg", "Probiotics", "Throat Lozenges"],
      ["Ibuprofen 200mg", "Acetaminophen 500mg", "Muscle Relaxant"],
      ["Atorvastatin 20mg", "CoQ10", "Omega-3 Supplements"],
    ];

    return mockMedications[DateTime.now().millisecond % mockMedications.length];
  }
}