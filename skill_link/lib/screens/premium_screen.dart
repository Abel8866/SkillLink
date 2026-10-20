import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promote Your Services')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 32,
                    color: AppColors.secondaryLight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grow Your Business',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Reach more customers with SkillLink.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Why providers promote',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _Benefit(
            icon: Icons.visibility_outlined,
            text: 'Better visibility in local searches',
          ),
          const _Benefit(
            icon: Icons.star_outline_rounded,
            text: 'Featured placement and badge',
          ),
          const _Benefit(
            icon: Icons.trending_up_rounded,
            text: 'More opportunities to receive booking requests',
          ),
          const _Benefit(
            icon: Icons.language_rounded,
            text: 'A professional online presence',
          ),
          const SizedBox(height: 20),
          Card(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.7),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Professional',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Proposed demonstration plan · ETB 300/month'),
                  const SizedBox(height: 14),
                  const Text(
                    '• Featured listing badge\n• Placement in Featured Professionals\n• Increased visibility',
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Coming soon'),
                        content: const Text(
                          'Provider promotion is a proposed feature for this MVP. Real payments are not available and no charge will be made.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    ),
                    child: const Text('Choose Featured Plan'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Proposed revenue model',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            '1. Paid featured listings\n2. Monthly provider subscriptions\n3. Potential commissions on completed bookings',
          ),
          const SizedBox(height: 16),
          Text(
            'Illustrative example',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            '20 paying providers × ETB 300/month = ETB 6,000 illustrative monthly gross revenue. This is hypothetical, not actual revenue.',
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
