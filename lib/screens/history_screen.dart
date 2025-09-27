import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/screens/mock_user_entity.dart';

final _backgroundColor = const Color(0xFF0A0E1A); // Dark navy background
final _primaryColor = const Color(0xFF00D4FF); // Cyan blue
final _accentColor = const Color(0xFF7C3AED); // Purple
final _cardColor = const Color(0xFF1A1F2E); // Dark card background

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: healthData.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      itemCount: healthData.length,
                      itemBuilder: (context, index) {
                        final entry = healthData[index];
                        // Adding a simple fade-in animation for each card
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Padding(
                                padding: EdgeInsets.only(top: value * 16),
                                child: child,
                              ),
                            );
                          },
                          child: _buildHistoryCard(entry),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header consistent with the AI theme.
  Widget _buildAIHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: _primaryColor),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryColor.withOpacity(0.1),
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: Icon(Icons.history_edu, color: _primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health History Log',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Review Past Entries',
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

  /// A styled card to display a single health data entry.
  Widget _buildHistoryCard(HealthEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(entry),
            const SizedBox(height: 12),
            Divider(color: _primaryColor.withOpacity(0.2), thickness: 1),
            const SizedBox(height: 12),
            _buildCardBody(entry),
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildNotesSection(entry),
            ],
          ],
        ),
      ),
    );
  }

  /// The top section of the card showing date and time.
  Widget _buildCardHeader(HealthEntry entry) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, color: _primaryColor, size: 16),
            const SizedBox(width: 8),
            Text(
              '${entry.date.day}/${entry.date.month}/${entry.date.year}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          '${entry.date.hour}:${entry.date.minute.toString().padLeft(2, '0')}',
          style: TextStyle(color: _primaryColor.withOpacity(0.7), fontSize: 14),
        ),
      ],
    );
  }

  /// The main content area of the card with vital signs.
  Widget _buildCardBody(HealthEntry entry) {
    return Row(
      children: [
        Expanded(
          child: _buildVitalInfo(
            icon: Icons.favorite,
            iconColor: Colors.red.shade400,
            label: 'Blood Pressure',
            value: '${entry.systolic}/${entry.diastolic} mmHg',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildVitalInfo(
            icon: Icons.water_drop,
            iconColor: Colors.orange.shade400,
            label: 'Blood Sugar',
            value: '${entry.bloodSugar} mg/dL',
          ),
        ),
      ],
    );
  }

  /// A reusable widget for displaying a single vital sign.
  Widget _buildVitalInfo({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// The notes section, displayed conditionally.
  Widget _buildNotesSection(HealthEntry entry) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology, color: _accentColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${entry.notes}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The widget to display when there is no health data.
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 80, color: _primaryColor.withOpacity(0.5)),
        const SizedBox(height: 20),
        const Text(
          'No Health Data Found',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your recorded history will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
