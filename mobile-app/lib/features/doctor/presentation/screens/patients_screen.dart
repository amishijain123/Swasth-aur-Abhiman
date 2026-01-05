import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/doctor_provider.dart';
import '../../repositories/doctor_repository.dart';
import '../../../chat/providers/chat_provider.dart';
import '../../../chat/presentation/screens/chat_room_screen.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  String? _selectedBlock;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doctorProvider.notifier).loadPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorProvider);
    final patients = doctorState.patients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (block) {
              setState(() => _selectedBlock = block == 'All' ? null : block);
              ref.read(doctorProvider.notifier).loadPatients(block: _selectedBlock);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'All', child: Text('All Blocks')),
              PopupMenuItem(value: 'VIKASNAGAR', child: Text('Vikasnagar')),
              PopupMenuItem(value: 'DOIWALA', child: Text('Doiwala')),
              PopupMenuItem(value: 'SAHASPUR', child: Text('Sahaspur')),
            ],
          ),
        ],
      ),
      body: doctorState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
              ? _buildEmptyState()
              : _buildPatientsList(patients),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No patients found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Patients who submit prescriptions will appear here',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList(List<PatientInfo> patients) {
    return RefreshIndicator(
      onRefresh: () => ref.read(doctorProvider.notifier).loadPatients(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return _PatientCard(
            patient: patient,
            onTap: () => _showPatientDetails(patient),
          );
        },
      ),
    );
  }

  void _showPatientDetails(PatientInfo patient) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.green[100],
                  child: Text(
                    patient.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${patient.age} years, ${patient.gender}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(Icons.phone, 'Phone', patient.phone),
            if (patient.block != null)
              _buildDetailRow(Icons.apartment, 'Block', patient.block!),
            _buildDetailRow(
              Icons.receipt_long,
              'Prescriptions',
              '${patient.prescriptionCount} uploaded',
            ),
            if (patient.lastVisit != null)
              _buildDetailRow(
                Icons.calendar_today,
                'Last Visit',
                '${patient.lastVisit!.day}/${patient.lastVisit!.month}/${patient.lastVisit!.year}',
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _openChatWithPatient(patient);
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: View patient prescriptions
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('History'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openChatWithPatient(PatientInfo patient) async {
    try {
      // Create or get existing chat room with patient
      final room = await ref
          .read(chatProvider.notifier)
          .createDirectChat(patient.id, patient.name);
      
      if (room != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(room: room),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open chat with patient'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening chat: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class _PatientCard extends StatelessWidget {
  final PatientInfo patient;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Text(
            patient.name[0].toUpperCase(),
            style: TextStyle(color: Colors.green[700]),
          ),
        ),
        title: Text(patient.name),
        subtitle: Row(
          children: [
            Text('${patient.age} yrs, ${patient.gender}'),
            if (patient.block != null) ...[
              const Text(' • '),
              Text(patient.block!),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${patient.prescriptionCount}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'prescriptions',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
