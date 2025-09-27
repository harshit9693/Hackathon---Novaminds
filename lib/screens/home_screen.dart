import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/screens/data_entry_screen.dart';
import 'package:project/screens/helath_analytical_screen.dart';
import 'package:project/screens/history_screen.dart';
import 'package:project/screens/mock_user_entity.dart';
import 'package:project/screens/prescription_verification_screen.dart';


class HomeScreen extends ConsumerWidget {
  final MockUser user;
  const HomeScreen({required this.user, Key? key}) : super(key: key);

  static const Color _backgroundColor = Color(0xFF0A0E1A); // Dark navy
  static const Color _primaryColor = Color(0xFF00D4FF); // Cyan blue
  static const Color _accentColor = Color(0xFF7C3AED); // Purple
  static const Color _cardColor = Color(0xFF1A1F2E); // Dark card background
  static const Color _surfaceColor = Color(0xFF252B3D); // Lighter surface

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- IMPLEMENTATION LOGIC (UNCHANGED) ---
    final repo = ref.read(authRepositoryProvider);
    final userName = user.email.split('@')[0];
    final currentHour = DateTime.now().hour;
    String greeting = currentHour < 12
        ? 'Good Morning'
        : currentHour < 17
        ? 'Good Afternoon'
        : 'Good Evening';
    // --- END OF IMPLEMENTATION LOGIC ---

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Themed SliverAppBar with AI aesthetic
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: _backgroundColor.withOpacity(0.8), // Semi-transparent when scrolling
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.8, -1.5),
                    radius: 2.0,
                    colors: [
                      _primaryColor.withOpacity(0.15),
                      _backgroundColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'HealthAI Guardian',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Your Intelligent Companion',
                              style: TextStyle(
                                fontSize: 14,
                                color: _primaryColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: _primaryColor, size: 24),
                          tooltip: 'Logout',
                          style: IconButton.styleFrom(
                            backgroundColor: _surfaceColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: _primaryColor.withOpacity(0.3)),
                            ),
                          ),
                          onPressed: () async {
                            await repo.signOut();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content Area
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Themed Welcome Card with neon gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    margin: const EdgeInsets.only(bottom: 28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primaryColor, _accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$greeting,',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                userName.substring(0, 1).toUpperCase() + userName.substring(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.health_and_safety,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Themed Stats Cards
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildThemedStatCard(
                            icon: Icons.favorite_rounded,
                            title: 'BP Logs',
                            value: '12', // This value should come from a provider
                            color: Colors.red.shade400,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildThemedStatCard(
                            icon: Icons.water_drop_rounded,
                            title: 'Sugar Logs',
                            value: '8', // This value should come from a provider
                            color: Colors.orange.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Themed Section Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_primaryColor, _accentColor],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Health Actions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Themed Action Cards
                  _buildThemedActionCard(
                    context: context,
                    icon: Icons.add_chart_rounded,
                    title: 'Log Vitals',
                    subtitle: 'Record your latest readings',
                    color: _primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DataEntryScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildThemedActionCard(
                    context: context,
                    icon: Icons.history_rounded,
                    title: 'View History',
                    subtitle: 'Check your health trends',
                    color: _accentColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildThemedActionCard(
                    context: context,
                    icon: Icons.analytics_rounded,
                    title: 'Health Analytics',
                    subtitle: 'AI-powered insights',
                    color: Colors.tealAccent.shade400,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> AnalyticsScreen())
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  _buildThemedActionCard(
                    context: context,
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Verify Prescription',
                    subtitle: 'Upload and verify your prescription',
                    color: Colors.greenAccent.shade400,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrescriptionVerificationScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Themed Health Tip Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _accentColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.psychology, color: _accentColor, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'AI Health Insight',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Regular monitoring helps our AI detect patterns. Try to log your readings at the same time each day for the most accurate insights and trends.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildThemedStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemedActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

