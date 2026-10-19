import 'package:flutter/material.dart';

import '../data/sample_providers.dart';
import '../models/service_provider.dart';
import '../widgets/provider_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late String? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  List<ServiceProvider> get _results {
    return sampleProviders.where((provider) {
      final matchesCategory = _selectedCategory == null ||
          provider.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          provider.name.toLowerCase().contains(query) ||
          provider.profession.toLowerCase().contains(query) ||
          provider.category.toLowerCase().contains(query) ||
          provider.skills.any((s) => s.toLowerCase().contains(query));
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = _results;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          if (_selectedCategory != null || _searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              tooltip: 'Clear filters',
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search providers, skills, services…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor:
                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: providerCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final category = providerCategories[index];
                final isSelected = category.name == _selectedCategory;
                return FilterChip(
                  selected: isSelected,
                  label: Text(category.name),
                  labelStyle: theme.textTheme.labelMedium,
                  visualDensity: VisualDensity.compact,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory =
                          selected && !isSelected ? category.name : null;
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 56,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No providers found',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try adjusting your search or filters.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) => ProviderCard(
                      provider: results[index],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
