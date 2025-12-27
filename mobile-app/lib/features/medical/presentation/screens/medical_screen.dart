import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/health_models.dart';
import '../../providers/health_provider.dart';
import '../widgets/bp_chart.dart';
import '../widgets/sugar_chart.dart';
import '../widgets/bmi_card.dart';
import '../widgets/herbal_remedies_section.dart';
import '../widgets/add_reading_dialogs.dart';

class MedicalScreen extends ConsumerWidget {
  const MedicalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medical Dashboard'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.favorite), text: 'Blood Pressure'),
              Tab(icon: Icon(Icons.water_drop), text: 'Blood Sugar'),
              Tab(icon: Icon(Icons.monitor_weight), text: 'BMI'),
              Tab(icon: Icon(Icons.local_florist), text: 'Herbal Remedies'),
            ],
          ),
        ),
        body: healthState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Blood Pressure Tab
                  _BPTab(readings: healthState.metrics.bpHistory),
                  // Blood Sugar Tab
                  _SugarTab(readings: healthState.metrics.sugarHistory),
                  // BMI Tab
                  _BMITab(readings: healthState.metrics.bmiHistory),
                  // Herbal Remedies Tab
                  const HerbalRemediesSection(),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddReadingOptions(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddReadingOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: const Text('Add Blood Pressure Reading'),
              onTap: () {
                Navigator.pop(context);
                showAddBPDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.water_drop, color: Colors.blue),
              title: const Text('Add Blood Sugar Reading'),
              onTap: () {
                Navigator.pop(context);
                showAddSugarDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.monitor_weight, color: Colors.green),
              title: const Text('Add Weight/BMI Reading'),
              onTap: () {
                Navigator.pop(context);
                showAddBMIDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BPTab extends StatelessWidget {
  final List<BPReading> readings;

  const _BPTab({required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No blood pressure readings yet'),
            Text('Tap + to add your first reading'),
          ],
        ),
      );
    }

    final latestReading = readings.last;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Latest Reading Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Latest Reading',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricDisplay(
                        value: '${latestReading.systolic}',
                        label: 'Systolic',
                        unit: 'mmHg',
                        color: Colors.red,
                      ),
                      _MetricDisplay(
                        value: '${latestReading.diastolic}',
                        label: 'Diastolic',
                        unit: 'mmHg',
                        color: Colors.blue,
                      ),
                      if (latestReading.pulse != null)
                        _MetricDisplay(
                          value: '${latestReading.pulse}',
                          label: 'Pulse',
                          unit: 'bpm',
                          color: Colors.green,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(latestReading.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      latestReading.status,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Chart
          const Text(
            'Blood Pressure History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BPChart(readings: readings),
          ),
          
          const SizedBox(height: 24),
          
          // History List
          const Text(
            'Recent Readings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...readings.reversed.take(10).map((reading) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.favorite, color: _getStatusColor(reading.status)),
              title: Text('${reading.systolic}/${reading.diastolic} mmHg'),
              subtitle: Text(_formatDate(reading.date)),
              trailing: Chip(
                label: Text(reading.status, style: const TextStyle(fontSize: 12)),
                backgroundColor: _getStatusColor(reading.status).withOpacity(0.2),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return Colors.green;
      case 'Elevated':
        return Colors.orange;
      case 'High BP Stage 1':
        return Colors.deepOrange;
      case 'High BP Stage 2':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _SugarTab extends StatelessWidget {
  final List<SugarReading> readings;

  const _SugarTab({required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No blood sugar readings yet'),
            Text('Tap + to add your first reading'),
          ],
        ),
      );
    }

    final latestReading = readings.last;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Latest Reading Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Latest Reading',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MetricDisplay(
                        value: latestReading.level.toStringAsFixed(1),
                        label: latestReading.type.replaceAll('_', ' '),
                        unit: 'mg/dL',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(latestReading.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        latestReading.status,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Chart
          const Text(
            'Blood Sugar History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: SugarChart(readings: readings),
          ),
          
          const SizedBox(height: 24),
          
          // History List
          const Text(
            'Recent Readings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...readings.reversed.take(10).map((reading) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.water_drop, color: _getStatusColor(reading.status)),
              title: Text('${reading.level.toStringAsFixed(1)} mg/dL'),
              subtitle: Text('${reading.type.replaceAll('_', ' ')} - ${_formatDate(reading.date)}'),
              trailing: Chip(
                label: Text(reading.status, style: const TextStyle(fontSize: 12)),
                backgroundColor: _getStatusColor(reading.status).withOpacity(0.2),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return Colors.green;
      case 'Pre-diabetic':
        return Colors.orange;
      case 'Diabetic':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _BMITab extends StatelessWidget {
  final List<BMIReading> readings;

  const _BMITab({required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_weight_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No BMI readings yet'),
            Text('Tap + to add your weight and height'),
          ],
        ),
      );
    }

    final latestReading = readings.last;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BMICard(reading: latestReading),
          const SizedBox(height: 24),
          
          // History List
          const Text(
            'Weight History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...readings.reversed.take(10).map((reading) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                Icons.monitor_weight,
                color: _getStatusColor(reading.status),
              ),
              title: Text('${reading.weight.toStringAsFixed(1)} kg'),
              subtitle: Text('BMI: ${reading.bmi.toStringAsFixed(1)} - ${_formatDate(reading.date)}'),
              trailing: Chip(
                label: Text(reading.status, style: const TextStyle(fontSize: 12)),
                backgroundColor: _getStatusColor(reading.status).withOpacity(0.2),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return Colors.green;
      case 'Underweight':
        return Colors.orange;
      case 'Overweight':
        return Colors.deepOrange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MetricDisplay extends StatelessWidget {
  final String value;
  final String label;
  final String unit;
  final Color color;

  const _MetricDisplay({
    required this.value,
    required this.label,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
