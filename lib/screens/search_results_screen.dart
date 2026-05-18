import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/data/mock_data.dart';
import '../models/service_provider.dart';
import 'service_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  const SearchResultsScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchController;
  List<ServiceProvider> _results = [];
  bool _hasSearched = false;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Cleaning', 'Repairing', 'Painting', 'Laundry', 'Plumbing', 'Electrician', 'Carpentry', 'Gardening'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) _performSearch(widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _hasSearched = true;
      final q = query.toLowerCase().trim();
      final allProviders = MockData.providers; // Use dynamic mock data
      
      _results = q.isEmpty 
          ? List.from(allProviders) 
          : allProviders.where((p) => 
              p.name.toLowerCase().contains(q) || 
              p.category.toLowerCase().contains(q)
            ).toList();
            
      if (_selectedFilter != 'All') {
        _results = _results.where((p) => p.category == _selectedFilter).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, isDark),
      body: Column(
        children: [
          _buildFilterRow(isDark),
          Expanded(
            child: !_hasSearched
                ? _buildInitialState(isDark)
                : _results.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildResultsList(isDark),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
      elevation: 0,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
        child: Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF262626) : Colors.black.withOpacity(0.05), shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF090909) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(32),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _performSearch,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Search for a service...',
            hintStyle: TextStyle(color: isDark ? Colors.white24 : AppColors.textMutedLight),
            prefixIcon: const Icon(Icons.search, color: AppColors.textMutedLight, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(color: isDark ? const Color(0xFF262626) : AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: const Icon(Icons.tune, color: AppColors.primary, size: 20), onPressed: () {}),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF161616) : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter);
                _performSearch(_searchController.text);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF262626) : AppColors.surfaceLight),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white54 : AppColors.textSecondaryLight), fontWeight: FontWeight.w600),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInitialState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Searches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ['Cleaning', 'Repairing', 'Painting', 'Laundry', 'Plumbing', 'Gardening']
                .map((tag) => GestureDetector(
                  onTap: () {
                    _searchController.text = tag;
                    _performSearch(tag);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161616) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(tag, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildProviderCard(_results[index], isDark),
    );
  }

  Widget _buildProviderCard(ServiceProvider provider, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(provider: provider))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: provider.avatarColor.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
              child: Icon(provider.icon, color: provider.avatarColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 4),
                  Text(provider.category, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(provider.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.primary, size: 12),
                      const SizedBox(width: 4),
                      Text(provider.rating.toString(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No results found', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }
}
