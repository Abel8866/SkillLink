import 'package:flutter/material.dart';

import '../data/sample_providers.dart'
    hide ProviderCategory, providerCategories;
import '../data/service_categories.dart';
import '../models/service_provider.dart';
import '../services/provider_repository.dart';
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
  late String _searchQuery;
  String _sortBy = 'Relevance';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _searchQuery = widget.initialQuery ?? '';
  }

  List<ServiceProvider> _filterProviders(List<ServiceProvider> providers) {
    final query = _searchQuery.trim().toLowerCase();
    final results = providers.where((provider) {
      final matchesCategory =
          _selectedCategory == null ||
          _selectedCategory == 'All' ||
          provider.category == _selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          provider.name.toLowerCase().contains(query) ||
          provider.profession.toLowerCase().contains(query) ||
          provider.category.toLowerCase().contains(query) ||
          provider.location.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    switch (_sortBy) {
      case 'Price: Low to High':
        results.sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        results.sort((a, b) => b.price.compareTo(a.price));
      case 'Rating':
        results.sort((a, b) => b.rating.compareTo(a.rating));
      case 'Relevance':
        results.sort((a, b) {
          if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
          return b.reviewCount.compareTo(a.reviewCount);
        });
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
    final categories = providerCategories
        .where((category) => category.name != 'All')
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
      body: StreamBuilder<List<ServiceProvider>>(
        stream: ProviderRepository.instance.watchApprovedProviders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Services are temporarily unavailable. Please check your connection and try again.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final providers = snapshot.data!.isNotEmpty ? snapshot.data! : sampleProviders;
          final results = _filterProviders(providers);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search providers, skills, services...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
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
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return FilterChip(
                        selected:
                            _selectedCategory == null ||
                            _selectedCategory == 'All',
                        label: const Text('All'),
                        onSelected: (_) =>
                            setState(() => _selectedCategory = null),
                      );
                    }
                    final category = categories[index - 1];
                    final selected = category.name == _selectedCategory;
                    return FilterChip(
                      selected: selected,
                      label: Text(category.name),
                      onSelected: (_) => setState(
                        () =>
                            _selectedCategory = selected ? null : category.name,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      'Sort by:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                          if (value != null) setState(() => _sortBy = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      '${results.length} ${results.length == 1 ? 'provider' : 'providers'} found',
                    ),
                    const Spacer(),
                    if (_selectedCategory != null)
                      Chip(
                        label: Text(_selectedCategory!),
                        onDeleted: () =>
                            setState(() => _selectedCategory = null),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? _emptyState(context)
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) =>
                            ProviderCard(provider: results[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No professionals available yet',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try another search, or be one of the first to offer services on SkillLink.',
              textAlign: TextAlign.center,
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Clear all filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
