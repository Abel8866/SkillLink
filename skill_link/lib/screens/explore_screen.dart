/// SkillLink Explore Screen.
/// Provider discovery with search, category filters, and sorting.
library;

import 'package:flutter/material.dart';

import '../data/sample_providers.dart';
import '../models/service_provider.dart';
import '../widgets/provider_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.initialCategory, this.initialQuery});

  final String? initialCategory;
  final String? initialQuery;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late String? _selectedCategory;
  String _searchQuery = '';
  String _sortBy =
      'Relevance'; // Relevance, Price: Low to High, Price: High to Low, Rating

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _searchQuery = widget.initialQuery ?? '';
  }

  List<ServiceProvider> get _filteredProviders {
    var results = sampleProviders.where((provider) {
      final matchesCategory =
          _selectedCategory == null ||
          _selectedCategory == 'All' ||
          provider.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          provider.name.toLowerCase().contains(query) ||
          provider.profession.toLowerCase().contains(query) ||
          provider.category.toLowerCase().contains(query) ||
          provider.location.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'Price: Low to High':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Relevance':
      default:
        // Already sorted by relevance (featured first, then rating)
        results.sort((a, b) {
          if (a.isFeatured != b.isFeatured) {
            return a.isFeatured ? -1 : 1;
          }
          return b.rating.compareTo(a.rating);
        });
        break;
    }

    return results;
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _searchQuery = '';
      _sortBy = 'Relevance';
    });
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _searchQuery.isNotEmpty ||
      _sortBy != 'Relevance';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = _filteredProviders;
    final filterCategories = providerCategories
        .where((c) => c.name != 'All')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Services'),
        actions: [
          if (_hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_rounded),
              tooltip: 'Clear filters',
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search providers, skills, services…',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),

          // Category filters
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: filterCategories.length + 1, // +1 for "All"
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                if (index == 0) {
                  final isSelected =
                      _selectedCategory == null || _selectedCategory == 'All';
                  return FilterChip(
                    selected: isSelected,
                    label: const Text('All'),
                    labelStyle: theme.textTheme.labelMedium,
                    visualDensity: VisualDensity.compact,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? null : null;
                      });
                    },
                  );
                }
                final category = filterCategories[index - 1];
                final isSelected = category.name == _selectedCategory;
                return FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(category.name),
                    ],
                  ),
                  labelStyle: theme.textTheme.labelMedium,
                  visualDensity: VisualDensity.compact,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected && !isSelected
                          ? category.name
                          : null;
                    });
                  },
                );
              },
            ),
          ),

          // Sort control
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Sort by:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(width: 4),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sortBy,
                    isDense: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Relevance',
                        child: Text('Relevance'),
                      ),
                      DropdownMenuItem(
                        value: 'Rating',
                        child: Text('Rating (Highest)'),
                      ),
                      DropdownMenuItem(
                        value: 'Price: Low to High',
                        child: Text('Price: Low to High'),
                      ),
                      DropdownMenuItem(
                        value: 'Price: High to Low',
                        child: Text('Price: High to Low'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sortBy = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              children: [
                Text(
                  '${results.length} ${results.length == 1 ? 'provider' : 'providers'} found',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (_selectedCategory != null)
                  Chip(
                    label: Text(_selectedCategory!),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() => _selectedCategory = null),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    deleteIconColor: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),

          // Results list
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No providers found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Try adjusting your search or filters.'
                                : 'No providers available in this category.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          if (_hasActiveFilters)
                            OutlinedButton.icon(
                              icon: const Icon(
                                Icons.filter_alt_off_rounded,
                                size: 18,
                              ),
                              label: const Text('Clear all filters'),
                              onPressed: _clearFilters,
                            ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) =>
                        ProviderCard(provider: results[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
