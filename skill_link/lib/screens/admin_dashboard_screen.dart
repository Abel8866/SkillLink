import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../services/admin_service.dart';
import '../theme/app_colors.dart';
import '../widgets/profile_image.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<Map<String, dynamic>>> _registrations;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _registrations = AdminService.instance.listRegistrations();
    });
  }

  Future<void> _review(
    Map<String, dynamic> registration,
    String decision,
  ) async {
    String? reason;
    if (decision == 'rejected') {
      reason = await _rejectionReason();
      if (reason == null) return;
    }
    try {
      await AdminService.instance.review(
        registrationId: registration['id'] as String,
        decision: decision,
        rejectionReason: reason,
      );
      if (!mounted) return;
      _refresh();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration $decision.')));
    } on FirebaseFunctionsException catch (error, stackTrace) {
      debugPrint(
        '[AdminDashboard] Review failed (code=${error.code}): '
        '${error.message ?? error}',
      );
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The registration could not be reviewed.'),
        ),
      );
    }
  }

  Future<String?> _rejectionReason() async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject registration'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            hintText: 'Share helpful feedback with the applicant',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _registrations,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _message(
              context,
              'Could not load registrations.',
              'Check your administrator access and connection.',
              retry: true,
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final registrations = snapshot.data!;
          final pending = registrations
              .where((item) => item['status'] == 'pending')
              .toList();
          final approved = registrations
              .where((item) => item['status'] == 'approved')
              .length;
          final rejected = registrations
              .where((item) => item['status'] == 'rejected')
              .length;
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _stat('Pending', pending.length, AppColors.warning),
                    const SizedBox(width: 8),
                    _stat('Approved', approved, AppColors.success),
                    const SizedBox(width: 8),
                    _stat('Rejected', rejected, AppColors.error),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Pending applications',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (pending.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('No pending applications.')),
                  )
                else
                  ...pending.map(
                    (registration) => _ApplicationCard(
                      registration: registration,
                      onApprove: () => _review(registration, 'approved'),
                      onReject: () => _review(registration, 'rejected'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _message(
    BuildContext context,
    String title,
    String message, {
    required bool retry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (retry) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.registration,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, dynamic> registration;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final name = registration['fullName'] as String? ?? 'Unnamed applicant';
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileImage(
                  url: registration['profileImageUrl'] as String?,
                  initials: name.isEmpty ? '?' : name[0].toUpperCase(),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(registration['professionalTitle'] as String? ?? ''),
            Text(
              '${registration['category'] ?? ''} • ${registration['location'] ?? ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              registration['description'] as String? ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onApprove,
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
