import 'package:flutter/material.dart';

import '../data/sample_providers.dart';
import '../screens/provider_details_screen.dart';

/// A compact card representing a service category. Tapping it opens the
/// explore screen pre-filtered to that category.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final ProviderCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                color: theme.colorScheme.primary,
                size: 26,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  category.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience helper used by the app shell to push an explore view
/// filtered to a single category.
void openCategory(BuildContext context, String categoryName) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) {
        final provider = sampleProviders.firstWhere(
          (p) => p.category == categoryName,
          orElse: () => sampleProviders.first,
        );
        return ProviderDetailsScreen(provider: provider);
      },
    ),
  );
}
