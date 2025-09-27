import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/repositories/health_analysis_report_entity.dart';
import 'package:project/screens/mock_user_entity.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  static const Color _backgroundColor = Color(0xFF0A0E1A);
  static const Color _primaryColor = Color(0xFF00D4FF);
  static const Color _accentColor = Color(0xFF7C3AED);
  static const Color _cardColor = Color(0xFF1A1F2E);
  static const Color _surfaceColor = Color(0xFF252B3D);

  /// Enhanced AI analysis using the Python model
  Future<HealthAnalysisReport> _analyzeHealthDataWithAI(List<HealthEntry> data) async {
    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 2));

    // Get AI predictions for all entries
    final predictions = await HealthcareAIService.predictBatch(data);

    // Enhanced data with AI predictions
    List<HealthEntry> enhancedData = [];
    for (int i = 0; i < data.length; i++) {
      final prediction = predictions[i];
      enhancedData.add(HealthEntry(
        date: data[i].date,
        systolic: data[i].systolic,
        diastolic: data[i].diastolic,
        bloodSugar: data[i].bloodSugar,
        age: data[i].age,
        notes: data[i].notes,
        predictedRiskLevel: prediction['predicted_class'],
        confidence: prediction['confidence'],
        riskCategory: prediction['risk_category'],
      ));
    }

    // Calculate traditional metrics
    final double avgSystolic = data.map((e) => e.systolic).reduce((a, b) => a + b) / data.length;
    final double avgDiastolic = data.map((e) => e.diastolic).reduce((a, b) => a + b) / data.length;
    final double avgBloodSugar = data.map((e) => e.bloodSugar).reduce((a, b) => a + b) / data.length;

    final maxSystolicEntry = data.reduce((a, b) => a.systolic > b.systolic ? a : b);
    final minSystolicEntry = data.reduce((a, b) => a.systolic < b.systolic ? a : b);
    final maxSugarEntry = data.reduce((a, b) => a.bloodSugar > b.bloodSugar ? a : b);
    final minSugarEntry = data.reduce((a, b) => a.bloodSugar < b.bloodSugar ? a : b);

    // AI-enhanced categorization
    String bpCategory;
    Color bpCategoryColor;
    if (avgSystolic < 120 && avgDiastolic < 80) {
      bpCategory = "Normal";
      bpCategoryColor = Colors.green.shade400;
    } else if (avgSystolic >= 120 && avgSystolic <= 129 && avgDiastolic < 80) {
      bpCategory = "Elevated";
      bpCategoryColor = Colors.yellow.shade600;
    } else if ((avgSystolic >= 130 && avgSystolic <= 139) || (avgDiastolic >= 80 && avgDiastolic <= 89)) {
      bpCategory = "Hypertension Stage 1";
      bpCategoryColor = Colors.orange.shade600;
    } else {
      bpCategory = "Hypertension Stage 2";
      bpCategoryColor = Colors.red.shade500;
    }

    String sugarCategory;
    Color sugarCategoryColor;
    if (avgBloodSugar < 100) {
      sugarCategory = "Normal";
      sugarCategoryColor = Colors.green.shade400;
    } else if (avgBloodSugar >= 100 && avgBloodSugar <= 125) {
      sugarCategory = "Prediabetes";
      sugarCategoryColor = Colors.orange.shade600;
    } else {
      sugarCategory = "High (Diabetes Range)";
      sugarCategoryColor = Colors.red.shade500;
    }

    // AI-generated insights
    final riskLevels = enhancedData.map((e) => e.predictedRiskLevel ?? 0).toList();
    final avgRiskScore = riskLevels.reduce((a, b) => a + b) / riskLevels.length;

    // Risk distribution
    Map<String, double> riskDistribution = {
      'Normal': riskLevels.where((r) => r == 0).length / riskLevels.length,
      'Moderate': riskLevels.where((r) => r == 1).length / riskLevels.length,
      'High': riskLevels.where((r) => r == 2).length / riskLevels.length,
      'Critical': riskLevels.where((r) => r == 3).length / riskLevels.length,
    };

    // Risk trend analysis
    String riskTrend = "Stable";
    if (riskLevels.length >= 3) {
      final recent = riskLevels.sublist(riskLevels.length - 3);
      final earlier = riskLevels.sublist(0, 3);
      final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
      final earlierAvg = earlier.reduce((a, b) => a + b) / earlier.length;

      if (recentAvg > earlierAvg + 0.5) {
        riskTrend = "Increasing";
      } else if (recentAvg < earlierAvg - 0.5) {
        riskTrend = "Improving";
      }
    }

    // AI-generated recommendations based on model predictions
    List<String> aiRecommendations = _generateAIRecommendations(enhancedData, avgRiskScore, riskTrend);

    // AI insights
    List<String> aiInsights = [
      "AI model analyzed ${data.length} health entries with average confidence of ${(enhancedData.map((e) => e.confidence ?? 0.0).reduce((a, b) => a + b) / enhancedData.length * 100).toStringAsFixed(1)}%",
      "Risk pattern shows ${riskTrend.toLowerCase()} trend over time",
      "Highest risk factors detected: ${_identifyRiskFactors(enhancedData)}",
    ];

    return HealthAnalysisReport(
      avgSystolic: avgSystolic,
      avgDiastolic: avgDiastolic,
      avgBloodSugar: avgBloodSugar,
      maxSystolicEntry: maxSystolicEntry,
      minSystolicEntry: minSystolicEntry,
      maxSugarEntry: maxSugarEntry,
      minSugarEntry: minSugarEntry,
      bpCategory: bpCategory,
      bpCategoryColor: bpCategoryColor,
      sugarCategory: sugarCategory,
      sugarCategoryColor: sugarCategoryColor,
      recommendations: aiRecommendations,
      overallRiskScore: avgRiskScore,
      riskTrend: riskTrend,
      aiInsights: aiInsights,
      riskDistribution: riskDistribution,
    );
  }

  List<String> _generateAIRecommendations(List<HealthEntry> data, double avgRiskScore, String riskTrend) {
    List<String> recommendations = [];

    if (avgRiskScore >= 2.5) {
      recommendations.add("URGENT: AI model indicates critical risk level. Immediate medical consultation required.");
      recommendations.add("Monitor vitals daily and maintain detailed health log.");
    } else if (avgRiskScore >= 1.5) {
      recommendations.add("AI analysis suggests elevated health risk. Schedule medical appointment within 1-2 weeks.");
      recommendations.add("Implement lifestyle modifications focusing on diet and exercise.");
    } else if (avgRiskScore >= 0.5) {
      recommendations.add("Moderate risk detected. Consider preventive measures and regular monitoring.");
      recommendations.add("Focus on maintaining current healthy habits and gradual improvements.");
    } else {
      recommendations.add("AI model indicates low risk. Continue maintaining excellent health practices.");
    }

    if (riskTrend == "Increasing") {
      recommendations.add("⚠️ Risk trend is increasing. Review recent lifestyle changes and consult healthcare provider.");
    } else if (riskTrend == "Improving") {
      recommendations.add("✅ Positive trend detected! Your health improvements are working.");
    }

    // Specific recommendations based on data patterns
    final highBP = data.where((e) => e.systolic >= 140 || e.diastolic >= 90).length;
    final highSugar = data.where((e) => e.bloodSugar >= 126).length;

    if (highBP > data.length * 0.3) {
      recommendations.add("Blood pressure management: Reduce sodium, increase potassium-rich foods, regular cardio exercise.");
    }

    if (highSugar > data.length * 0.3) {
      recommendations.add("Blood sugar control: Monitor carbohydrate intake, consider continuous glucose monitoring.");
    }

    recommendations.add("Always consult healthcare professionals for medical decisions and treatment plans.");

    return recommendations;
  }

  String _identifyRiskFactors(List<HealthEntry> data) {
    List<String> factors = [];

    final avgSystolic = data.map((e) => e.systolic).reduce((a, b) => a + b) / data.length;
    final avgDiastolic = data.map((e) => e.diastolic).reduce((a, b) => a + b) / data.length;
    final avgSugar = data.map((e) => e.bloodSugar).reduce((a, b) => a + b) / data.length;

    if (avgSystolic >= 140) factors.add("Systolic Hypertension");
    if (avgDiastolic >= 90) factors.add("Diastolic Hypertension");
    if (avgSugar >= 126) factors.add("Diabetes Range Glucose");
    if (avgSugar >= 100 && avgSugar < 126) factors.add("Prediabetes");

    return factors.isEmpty ? "None identified" : factors.join(", ");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use actual health data provider instead of mock data
    final healthData = ref.watch(healthDataProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.8, -0.6),
            radius: 1.5,
            colors: [
              _primaryColor.withOpacity(0.1),
              _backgroundColor,
              _accentColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAIHeader(context),
              Expanded(
                child: healthData.length < 3
                    ? _buildInsufficientDataState()
                    : FutureBuilder<HealthAnalysisReport>(
                  future: _analyzeHealthDataWithAI(healthData),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState();
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade400, size: 60),
                            const SizedBox(height: 16),
                            Text('AI Analysis Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => (() {}),
                              child: const Text('Retry Analysis'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      return _buildEnhancedReport(context, snapshot.data!, healthData);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedReport(BuildContext context, HealthAnalysisReport report, List<HealthEntry> healthData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Risk Score Card
          _buildRiskScoreCard(report),
          const SizedBox(height: 16),

          // Traditional Metrics
          _buildMetricAnalysisCard(
            'Blood Pressure',
            '${report.avgSystolic.toStringAsFixed(0)}/${report.avgDiastolic.toStringAsFixed(0)}',
            'mmHg',
            report.bpCategory,
            report.bpCategoryColor,
            report.minSystolicEntry.systolic,
            report.maxSystolicEntry.systolic,
          ),
          const SizedBox(height: 16),
          _buildMetricAnalysisCard(
            'Blood Sugar',
            report.avgBloodSugar.toStringAsFixed(0),
            'mg/dL',
            report.sugarCategory,
            report.sugarCategoryColor,
            report.minSugarEntry.bloodSugar,
            report.maxSugarEntry.bloodSugar,
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("AI Risk Distribution"),
          const SizedBox(height: 16),
          _buildRiskDistributionChart(report.riskDistribution),

          const SizedBox(height: 24),
          _buildSectionHeader("Vitals Trend Analysis"),
          const SizedBox(height: 16),
          _buildEnhancedTrendChart(context, healthData),

          const SizedBox(height: 24),
          _buildSectionHeader("AI Insights"),
          const SizedBox(height: 16),
          _buildInsightsCard(report.aiInsights),

          const SizedBox(height: 24),
          _buildSectionHeader("AI-Powered Recommendations"),
          const SizedBox(height: 16),
          _buildRecommendationsCard(report.recommendations),
        ],
      ),
    );
  }

  Widget _buildRiskScoreCard(HealthAnalysisReport report) {
    Color riskColor;
    String riskLabel;

    if (report.overallRiskScore >= 2.5) {
      riskColor = Colors.red.shade500;
      riskLabel = "Critical Risk";
    } else if (report.overallRiskScore >= 1.5) {
      riskColor = Colors.orange.shade500;
      riskLabel = "High Risk";
    } else if (report.overallRiskScore >= 0.5) {
      riskColor = Colors.yellow.shade600;
      riskLabel = "Moderate Risk";
    } else {
      riskColor = Colors.green.shade400;
      riskLabel = "Low Risk";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: _primaryColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'AI Risk Assessment',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: riskColor.withOpacity(0.5)),
                ),
                child: Text(
                  report.riskTrend,
                  style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      report.overallRiskScore.toStringAsFixed(1),
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      riskLabel,
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildRiskIndicator("Critical", report.riskDistribution['Critical']!, Colors.red.shade500),
                    _buildRiskIndicator("High", report.riskDistribution['High']!, Colors.orange.shade500),
                    _buildRiskIndicator("Moderate", report.riskDistribution['Moderate']!, Colors.yellow.shade600),
                    _buildRiskIndicator("Normal", report.riskDistribution['Normal']!, Colors.green.shade400),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(String label, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
          ),
          const Spacer(),
          Text(
            '${(percentage * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskDistributionChart(Map<String, double> riskDistribution) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withOpacity(0.1)),
      ),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: riskDistribution['Normal']! * 100,
              color: Colors.green.shade400,
              title: '${(riskDistribution['Normal']! * 100).toStringAsFixed(0)}%',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: riskDistribution['Moderate']! * 100,
              color: Colors.yellow.shade600,
              title: '${(riskDistribution['Moderate']! * 100).toStringAsFixed(0)}%',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: riskDistribution['High']! * 100,
              color: Colors.orange.shade500,
              title: '${(riskDistribution['High']! * 100).toStringAsFixed(0)}%',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: riskDistribution['Critical']! * 100,
              color: Colors.red.shade500,
              title: '${(riskDistribution['Critical']! * 100).toStringAsFixed(0)}%',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildInsightsCard(List<String> insights) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: insights.map((insight) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(Icons.lightbulb, color: _primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // Rest of the existing methods remain the same...
  Widget _buildAIHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: _primaryColor),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryColor.withOpacity(0.1),
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: const Icon(Icons.auto_awesome, color: _primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'ML-Powered Health Assessment',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              strokeWidth: 5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI is analyzing your health data...',
            style: TextStyle(color: _primaryColor, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Running neural network predictions and generating personalized insights.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInsufficientDataState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange.shade400),
            const SizedBox(height: 20),
            const Text(
              'Insufficient Data for AI Analysis',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'The AI model needs at least 3 health entries to generate accurate predictions and insights. Keep logging your vitals!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMetricAnalysisCard(String title, String avgValue, String unit, String category,
      Color categoryColor, int min, int max) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(avgValue, style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(unit, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: categoryColor.withOpacity(0.5)),
                ),
                child: Text(category, style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: _primaryColor.withOpacity(0.1)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Range:', style: TextStyle(color: Colors.white.withOpacity(0.6))),
              Text('$min - $max $unit', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTrendChart(BuildContext context, List<HealthEntry> data) {
    // Sort data by date
    data.sort((a, b) => a.date.compareTo(b.date));

    final List<FlSpot> systolicSpots = [];
    final List<FlSpot> diastolicSpots = [];
    final List<FlSpot> sugarSpots = [];
    final List<FlSpot> riskSpots = []; // New: AI risk level trend

    for (int i = 0; i < data.length; i++) {
      systolicSpots.add(FlSpot(i.toDouble(), data[i].systolic.toDouble()));
      diastolicSpots.add(FlSpot(i.toDouble(), data[i].diastolic.toDouble()));
      sugarSpots.add(FlSpot(i.toDouble(), data[i].bloodSugar.toDouble()));

      // Add risk level trend (scaled for visibility)
      final riskLevel = data[i].predictedRiskLevel ?? 0;
      riskSpots.add(FlSpot(i.toDouble(), (riskLevel * 30 + 80).toDouble())); // Scale risk 0-3 to 80-170 range
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryColor.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Systolic', _primaryColor),
                _buildLegendItem('Diastolic', _accentColor),
                _buildLegendItem('Blood Sugar', Colors.orange.shade400),
                _buildLegendItem('AI Risk', Colors.red.shade400),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(color: _primaryColor.withOpacity(0.1), strokeWidth: 1),
                    getDrawingVerticalLine: (value) => FlLine(color: _primaryColor.withOpacity(0.1), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final date = data[index].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    _createLineBarData(systolicSpots, _primaryColor, 'Systolic'),
                    _createLineBarData(diastolicSpots, _accentColor, 'Diastolic'),
                    _createLineBarData(sugarSpots, Colors.orange.shade400, 'Blood Sugar'),
                    _createLineBarData(riskSpots, Colors.red.shade400, 'AI Risk Level'),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      // tooltipBgColor: _surfaceColor,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          String label = '';
                          String value = '';

                          if (spot.barIndex == 0) {
                            label = 'Systolic';
                            value = '${spot.y.toInt()} mmHg';
                          } else if (spot.barIndex == 1) {
                            label = 'Diastolic';
                            value = '${spot.y.toInt()} mmHg';
                          } else if (spot.barIndex == 2) {
                            label = 'Blood Sugar';
                            value = '${spot.y.toInt()} mg/dL';
                          } else if (spot.barIndex == 3) {
                            label = 'AI Risk';
                            final riskLevel = ((spot.y - 80) / 30).round();
                            final riskLabels = ['Low', 'Moderate', 'High', 'Critical'];
                            value = riskLabels[riskLevel.clamp(0, 3)];
                          }

                          return LineTooltipItem(
                            '$label: $value',
                            TextStyle(color: spot.bar.color, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  LineChartBarData _createLineBarData(List<FlSpot> spots, Color color, String id) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeWidth: 2,
          strokeColor: _cardColor,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(List<String> recommendations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: recommendations.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(
                  rec.startsWith('URGENT') || rec.startsWith('⚠️')
                      ? Icons.warning
                      : rec.startsWith('✅')
                      ? Icons.check_circle
                      : Icons.health_and_safety,
                  color: rec.startsWith('URGENT') || rec.startsWith('⚠️')
                      ? Colors.red.shade400
                      : rec.startsWith('✅')
                      ? Colors.green.shade400
                      : _accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rec,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                    fontWeight: rec.startsWith('URGENT') ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}