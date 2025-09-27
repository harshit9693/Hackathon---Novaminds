import 'package:flutter/services.dart';
import 'package:project/screens/mock_user_entity.dart';

class HealthcareAIService {
  static const MethodChannel _channel = MethodChannel('healthcare_ai');

  // Singleton pattern
  static final HealthcareAIService _instance = HealthcareAIService._internal();
  factory HealthcareAIService() => _instance;
  HealthcareAIService._internal();

  bool _isModelLoaded = false;

  /// Initialize the AI model
  Future<bool> initializeModel() async {
    try {
      final result = await _channel.invokeMethod('initializeModel');
      _isModelLoaded = result['success'] ?? false;
      return _isModelLoaded;
    } on PlatformException catch (e) {
      print('Failed to initialize AI model: ${e.message}');
      return false;
    }
  }

  /// Check if model is ready
  bool get isModelLoaded => _isModelLoaded;

  /// Predict health risk for a single patient
  Future<HealthRiskPrediction> predictHealthRisk(HealthEntry entry) async {
    if (!_isModelLoaded) {
      // Use fallback prediction if model not loaded
      return _fallbackPrediction(entry);
    }

    try {
      final result = await _channel.invokeMethod('predictHealth', {
        'systolic_bp': entry.systolic,
        'diastolic_bp': entry.diastolic,
        'blood_sugar': entry.bloodSugar,
        'age': entry.age,
      });

      return HealthRiskPrediction.fromJson(result);
    } on PlatformException catch (e) {
      print('AI prediction failed: ${e.message}');
      return _fallbackPrediction(entry);
    }
  }

  /// Batch prediction for multiple entries
  Future<List<HealthRiskPrediction>> predictBatch(List<HealthEntry> entries) async {
    List<HealthRiskPrediction> predictions = [];

    if (!_isModelLoaded) {
      // Use fallback for all entries
      for (var entry in entries) {
        predictions.add(_fallbackPrediction(entry));
      }
      return predictions;
    }

    try {
      final batchData = entries.map((entry) => {
        'systolic_bp': entry.systolic,
        'diastolic_bp': entry.diastolic,
        'blood_sugar': entry.bloodSugar,
        'age': entry.age,
      }).toList();

      final result = await _channel.invokeMethod('predictBatch', {
        'batch_data': batchData,
      });

      final List<dynamic> resultList = result['predictions'];
      return resultList.map((pred) => HealthRiskPrediction.fromJson(pred)).toList();
    } on PlatformException catch (e) {
      print('Batch prediction failed: ${e.message}');
      // Fallback to individual predictions
      for (var entry in entries) {
        predictions.add(_fallbackPrediction(entry));
      }
      return predictions;
    }
  }

  /// Get detailed health recommendations
  Future<HealthRecommendations> getRecommendations(HealthEntry entry, HealthRiskPrediction prediction) async {
    try {
      final result = await _channel.invokeMethod('getRecommendations', {
        'systolic_bp': entry.systolic,
        'diastolic_bp': entry.diastolic,
        'blood_sugar': entry.bloodSugar,
        'age': entry.age,
        'risk_level': prediction.riskLevel,
        'confidence': prediction.confidence,
      });

      return HealthRecommendations.fromJson(result);
    } on PlatformException catch (e) {
      print('Recommendations failed: ${e.message}');
      return _fallbackRecommendations(entry, prediction);
    }
  }

  /// Fallback rule-based prediction (mirrors Python model logic)
  HealthRiskPrediction _fallbackPrediction(HealthEntry entry) {
    int riskLevel = 0;
    String riskCategory = "Normal/Low Risk";
    double confidence = 0.85;
    List<String> riskFactors = [];

    // Blood pressure assessment
    if (entry.systolic >= 140 || entry.diastolic >= 90) {
      riskFactors.add("Hypertension");
    }

    // Blood sugar assessment
    if (entry.bloodSugar >= 126) {
      riskFactors.add("Diabetes");
    } else if (entry.bloodSugar >= 100) {
      riskFactors.add("Prediabetes");
    }

    // Age factor
    if (entry.age >= 65) {
      riskFactors.add("Advanced Age");
    }

    // Determine risk level (matching Python model logic)
    if ((entry.systolic >= 140 || entry.diastolic >= 90) && entry.bloodSugar >= 126) {
      riskLevel = 3; // Critical
      riskCategory = "Critical Risk";
      confidence = 0.92;
    } else if (entry.systolic >= 140 || entry.diastolic >= 90) {
      riskLevel = 2; // High risk
      riskCategory = "High Risk";
      confidence = 0.88;
    } else if (entry.bloodSugar >= 126) {
      riskLevel = 2; // High risk
      riskCategory = "High Risk";
      confidence = 0.87;
    } else if ((100 <= entry.bloodSugar && entry.bloodSugar <= 125) ||
        (130 <= entry.systolic && entry.systolic <= 139) ||
        (80 <= entry.diastolic && entry.diastolic <= 89)) {
      riskLevel = 1; // Moderate risk
      riskCategory = "Moderate Risk";
      confidence = 0.82;
    }

    return HealthRiskPrediction(
      riskLevel: riskLevel,
      confidence: confidence,
      riskCategory: riskCategory,
      riskFactors: riskFactors,
      isFromFallback: true,
    );
  }

  /// Fallback recommendations
  HealthRecommendations _fallbackRecommendations(HealthEntry entry, HealthRiskPrediction prediction) {
    List<String> recommendations = [];
    List<String> urgentActions = [];
    List<String> lifestyle = [];
    List<String> monitoring = [];

    if (prediction.riskLevel >= 3) {
      urgentActions.add("Seek immediate medical attention");
      urgentActions.add("Monitor vitals multiple times daily");
      monitoring.add("Daily blood pressure and glucose monitoring required");
    } else if (prediction.riskLevel >= 2) {
      urgentActions.add("Schedule medical appointment within 1-2 weeks");
      monitoring.add("Monitor vitals daily");
    } else if (prediction.riskLevel >= 1) {
      monitoring.add("Monitor vitals 2-3 times per week");
      lifestyle.add("Focus on preventive lifestyle modifications");
    } else {
      lifestyle.add("Maintain current healthy lifestyle");
      monitoring.add("Continue regular health checkups");
    }

    // Blood pressure specific
    if (entry.systolic >= 140 || entry.diastolic >= 90) {
      lifestyle.addAll([
        "Reduce sodium intake to less than 2300mg daily",
        "Engage in regular cardio exercise (30 minutes, 5 days/week)",
        "Maintain healthy weight",
      ]);
    }

    // Blood sugar specific
    if (entry.bloodSugar >= 126) {
      lifestyle.addAll([
        "Monitor carbohydrate intake carefully",
        "Consider continuous glucose monitoring",
        "Follow diabetes management plan",
      ]);
    } else if (entry.bloodSugar >= 100) {
      lifestyle.addAll([
        "Reduce refined sugar and processed foods",
        "Increase fiber intake",
        "Regular physical activity",
      ]);
    }

    // Age-specific recommendations
    if (entry.age >= 65) {
      lifestyle.add("Focus on fall prevention and bone health");
      monitoring.add("Regular comprehensive health screenings");
    }

    recommendations.addAll(urgentActions);
    recommendations.addAll(lifestyle);
    recommendations.addAll(monitoring);
    recommendations.add("Always consult healthcare professionals for medical decisions");

    return HealthRecommendations(
      urgentActions: urgentActions,
      lifestyleRecommendations: lifestyle,
      monitoringGuidance: monitoring,
      allRecommendations: recommendations,
      isFromFallback: true,
    );
  }
}

/// Data class for health risk predictions
class HealthRiskPrediction {
  final int riskLevel; // 0-3: Normal, Moderate, High, Critical
  final double confidence; // 0.0-1.0
  final String riskCategory;
  final List<String> riskFactors;
  final bool isFromFallback;

  HealthRiskPrediction({
    required this.riskLevel,
    required this.confidence,
    required this.riskCategory,
    required this.riskFactors,
    this.isFromFallback = false,
  });

  factory HealthRiskPrediction.fromJson(Map<String, dynamic> json) {
    return HealthRiskPrediction(
      riskLevel: json['predicted_class'] ?? 0,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      riskCategory: json['risk_category'] ?? "Normal/Low Risk",
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
      isFromFallback: json['is_fallback'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'predicted_class': riskLevel,
    'confidence': confidence,
    'risk_category': riskCategory,
    'risk_factors': riskFactors,
    'is_fallback': isFromFallback,
  };

  Color get riskColor {
    switch (riskLevel) {
      case 3: return const Color(0xFFE53E3E); // Red
      case 2: return const Color(0xFFDD6B20); // Orange
      case 1: return const Color(0xFFD69E2E); // Yellow
      default: return const Color(0xFF38A169); // Green
    }
  }
}

/// Data class for health recommendations
class HealthRecommendations {
  final List<String> urgentActions;
  final List<String> lifestyleRecommendations;
  final List<String> monitoringGuidance;
  final List<String> allRecommendations;
  final bool isFromFallback;

  HealthRecommendations({
    required this.urgentActions,
    required this.lifestyleRecommendations,
    required this.monitoringGuidance,
    required this.allRecommendations,
    this.isFromFallback = false,
  });

  factory HealthRecommendations.fromJson(Map<String, dynamic> json) {
    return HealthRecommendations(
      urgentActions: List<String>.from(json['urgent_actions'] ?? []),
      lifestyleRecommendations: List<String>.from(json['lifestyle_recommendations'] ?? []),
      monitoringGuidance: List<String>.from(json['monitoring_guidance'] ?? []),
      allRecommendations: List<String>.from(json['all_recommendations'] ?? []),
      isFromFallback: json['is_fallback'] ?? false,
    );
  }
}

