import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:project/screens/mock_user_entity.dart';

class HealthAnalysisReport {
  final double avgSystolic;
  final double avgDiastolic;
  final double avgBloodSugar;
  final HealthEntry maxSystolicEntry;
  final HealthEntry minSystolicEntry;
  final HealthEntry maxSugarEntry;
  final HealthEntry minSugarEntry;
  final String bpCategory;
  final Color bpCategoryColor;
  final String sugarCategory;
  final Color sugarCategoryColor;
  final List<String> recommendations;

  // Enhanced AI predictions
  final double overallRiskScore;
  final String riskTrend;
  final List<String> aiInsights;
  final Map<String, double> riskDistribution;

  HealthAnalysisReport({
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.avgBloodSugar,
    required this.maxSystolicEntry,
    required this.minSystolicEntry,
    required this.maxSugarEntry,
    required this.minSugarEntry,
    required this.bpCategory,
    required this.bpCategoryColor,
    required this.sugarCategory,
    required this.sugarCategoryColor,
    required this.recommendations,
    required this.overallRiskScore,
    required this.riskTrend,
    required this.aiInsights,
    required this.riskDistribution,
  });
}

class HealthcareAIService {
  static const _channel = MethodChannel('healthcare_ai');

  // Method to call Python AI model (you'll need to implement the platform channel)
  static Future<Map<String, dynamic>> predictHealthRisk(HealthEntry entry) async {
    try {
      final result = await _channel.invokeMethod('predictHealth', entry.toJson());
      return Map<String, dynamic>.from(result);
    } catch (e) {
      // Fallback to rule-based prediction if Python model unavailable
      return _fallbackPrediction(entry);
    }
  }

  // Fallback rule-based prediction mimicking the Python model logic
  static Map<String, dynamic> _fallbackPrediction(HealthEntry entry) {
    int riskLevel = 0;
    String riskCategory = "Normal/Low Risk";
    double confidence = 0.85;

    // Mimic Python model logic
    if ((entry.systolic >= 140 || entry.diastolic >= 90) && entry.bloodSugar >= 126) {
      riskLevel = 3;
      riskCategory = "Critical Risk";
      confidence = 0.92;
    } else if (entry.systolic >= 140 || entry.diastolic >= 90) {
      riskLevel = 2;
      riskCategory = "High Risk";
      confidence = 0.88;
    } else if (entry.bloodSugar >= 126) {
      riskLevel = 2;
      riskCategory = "High Risk";
      confidence = 0.87;
    } else if ((100 <= entry.bloodSugar && entry.bloodSugar <= 125) ||
        (130 <= entry.systolic && entry.systolic <= 139) ||
        (80 <= entry.diastolic && entry.diastolic <= 89)) {
      riskLevel = 1;
      riskCategory = "Moderate Risk";
      confidence = 0.82;
    }

    return {
      'predicted_class': riskLevel,
      'confidence': confidence,
      'risk_category': riskCategory,
    };
  }

  // Batch prediction for multiple entries
  static Future<List<Map<String, dynamic>>> predictBatch(List<HealthEntry> entries) async {
    List<Map<String, dynamic>> predictions = [];
    for (var entry in entries) {
      final prediction = await predictHealthRisk(entry);
      predictions.add(prediction);
    }
    return predictions;
  }
}