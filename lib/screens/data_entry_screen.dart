import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/screens/mock_user_entity.dart';

final _backgroundColor = const Color(0xFF0A0E1A); // Dark navy background
final _primaryColor = const Color(0xFF00D4FF); // Cyan blue
final _accentColor = const Color(0xFF7C3AED); // Purple
final _cardColor = const Color(0xFF1A1F2E); // Dark card background
final _surfaceColor = const Color(0xFF252B3D); // Lighter surface color

class DataEntryScreen extends ConsumerStatefulWidget {
  const DataEntryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends ConsumerState<DataEntryScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _systolicCtl = TextEditingController();
  final _diastolicCtl = TextEditingController();
  final _sugarCtl = TextEditingController();
  final _notesCtl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _buildAIHeader(),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildVitalSignsSection(),
                            const SizedBox(height: 24),
                            _buildBloodSugarSection(),
                            const SizedBox(height: 24),
                            _buildDateTimeSection(),
                            const SizedBox(height: 24),
                            _buildNotesSection(),
                            const SizedBox(height: 32),
                            _buildAISaveButton(),
                          ],
                        ),
                      ),
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

  Widget _buildAIHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: _primaryColor),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _primaryColor.withOpacity(0.3),
                        _accentColor.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: _primaryColor,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Monitor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Text(
                      'Intelligent Data Collection',
                      style: TextStyle(
                        color: _primaryColor.withOpacity(_glowAnimation.value),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor,
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsSection() {
    return _aiSectionCard(
      title: 'Vital Signs Analysis',
      icon: Icons.favorite,
      iconColor: Colors.red,
      child: Row(
        children: [
          Expanded(
            child: _aiTextFormField(
              controller: _systolicCtl,
              labelText: 'Systolic',
              suffixText: 'mmHg',
              icon: Icons.arrow_upward,
              validator: (v) => (v != null && v.isNotEmpty) ? null : 'Required',
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 2,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _accentColor],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _aiTextFormField(
              controller: _diastolicCtl,
              labelText: 'Diastolic',
              suffixText: 'mmHg',
              icon: Icons.arrow_downward,
              validator: (v) => (v != null && v.isNotEmpty) ? null : 'Required',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodSugarSection() {
    return _aiSectionCard(
      title: 'Glucose Monitoring',
      icon: Icons.water_drop,
      iconColor: Colors.orange,
      child: _aiTextFormField(
        controller: _sugarCtl,
        labelText: 'Blood Sugar Level',
        suffixText: 'mg/dL',
        icon: Icons.analytics,
        validator: (v) => (v != null && v.isNotEmpty) ? null : 'Required',
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return _aiSectionCard(
      title: 'Temporal Data',
      icon: Icons.schedule,
      iconColor: _primaryColor,
      child: Row(
        children: [
          Expanded(
            child: _aiOutlinedButton(
              icon: Icons.calendar_today,
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: _primaryColor,
                          surface: _cardColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              label: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _aiOutlinedButton(
              icon: Icons.access_time,
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: _primaryColor,
                          surface: _cardColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
              label: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _aiSectionCard(
      title: 'AI Insights & Notes',
      icon: Icons.note_alt,
      iconColor: _accentColor,
      child: _aiTextFormField(
        controller: _notesCtl,
        hintText: 'AI will analyze your patterns... (optional notes)',
        maxLines: 3,
        icon: Icons.psychology,
      ),
    );
  }

  Widget _buildAISaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _accentColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.1,
              child: const Icon(Icons.cloud_upload, color: Colors.white),
            );
          },
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Show AI processing animation
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _buildAIProcessingDialog(),
            );

            // Simulate AI processing
            await Future.delayed(const Duration(seconds: 2));

            final entry = HealthEntry(
              date: DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _selectedTime.hour,
                _selectedTime.minute,
              ),
              age: 22,
              systolic: int.parse(_systolicCtl.text),
              diastolic: int.parse(_diastolicCtl.text),
              bloodSugar: int.parse(_sugarCtl.text),
              notes: _notesCtl.text.isEmpty ? null : _notesCtl.text,
            );

            ref.read(healthDataProvider.notifier).addEntry(entry);

            Navigator.of(context).pop(); // Close processing dialog

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: _primaryColor),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Health data processed by AI successfully!',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: _surfaceColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        label: const Text(
          'Process with AI',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _aiSectionCard({
    required String title,
    required Widget child,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _aiTextFormField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? suffixText,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixText: suffixText,
        prefixIcon: icon != null ? Icon(icon, color: _primaryColor, size: 20) : null,
        labelStyle: TextStyle(color: _primaryColor.withOpacity(0.8)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        suffixStyle: TextStyle(color: _primaryColor.withOpacity(0.7)),
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      keyboardType: (labelText?.contains('Sugar') == true ||
          labelText?.contains('Systolic') == true ||
          labelText?.contains('Diastolic') == true)
          ? TextInputType.number
          : TextInputType.text,
      validator: validator,
    );
  }

  Widget _aiOutlinedButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: _primaryColor, size: 20),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: _primaryColor.withOpacity(0.3)),
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
      ),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildAIProcessingDialog() {
    return Dialog(
      backgroundColor: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [_primaryColor, _accentColor],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'AI Processing...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzing your health data',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}