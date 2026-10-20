import 'package:flutter/material.dart';

import '../data/sample_providers.dart';
import '../screens/explore_screen.dart';

/// A compact card representing a service category. Tapping it opens the
/// explore screen pre-filtered to that category.
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, required this.onTap});

  final ProviderCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 104,
      height: 108,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(
                      alpha: 0.65,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
      builder: (_) => ExploreScreen(initialCategory: categoryName),
    ),
  );
}
