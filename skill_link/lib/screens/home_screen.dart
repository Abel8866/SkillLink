import 'package:flutter/material.dart';

import '../data/sample_providers.dart';
import '../models/service_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/provider_card.dart';
import 'explore_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<ServiceProvider> _featuredProviders;
  late final List<ProviderCategory> _displayedCategories;

  @override
  void initState() {
    super.initState();
    final providers = List<ServiceProvider>.from(sampleProviders)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    _featuredProviders = providers.take(3).toList();
    _displayedCategories = providerCategories.take(6).toList();
  }

  void _navigateToExplore({String? category}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExploreScreen(initialCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.handyman, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'SkillLink',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Alex!',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'What skill are you looking for today?',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            TextField(
              readOnly: true,
              onTap: () => _navigateToExplore(),
              decoration: InputDecoration(
                hintText: 'Search providers or services…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                color: theme.colorScheme.primaryContainer,
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Get 20% off',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your first booking with\nany verified provider.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.local_offer_rounded,
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _navigateToExplore(),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _displayedCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, index) => CategoryCard(
                  category: _displayedCategories[index],
                  onTap: () =>
                      _navigateToExplore(category: _displayedCategories[index].name),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Featured Providers',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._featuredProviders.map(
              (provider) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProviderCard(provider: provider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
