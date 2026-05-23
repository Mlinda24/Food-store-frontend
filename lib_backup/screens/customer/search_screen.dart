import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/theme.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _filters = ['All', 'Restaurants', 'Foods'];

  // Sample search results
  final List<Map<String, dynamic>> _allResults = [
    {
      'name': 'Luspernando Food Hub',
      'cuisine': 'Zombo • Chikanda • Ndekhalira',
      'rating': 4.9,
      'time': '10 min',
      'type': 'Restaurant',
    },
    {
      'name': 'BossMan',
      'cuisine': 'Zombo • Chikanda • CHANCO',
      'rating': 4.7,
      'time': '5 min',
      'type': 'Restaurant',
    },
    {
      'name': 'Makawa',
      'cuisine': 'Zombo • Chikanda • Chikanda',
      'rating': 4.5,
      'time': '15 min',
      'type': 'Restaurant',
    },
    {
      'name': 'Salmon Poke Supreme',
      'cuisine': 'Green Garden + 15-20 min',
      'rating': 4.0,
      'price': 'MK4,000',
      'type': 'Food',
    },
    {
      'name': 'Classic Lugga Kaki',
      'cuisine': 'Traditional taste',
      'rating': 4.5,
      'price': 'MK8,000',
      'type': 'Food',
    },
    {
      'name': 'Spicy Chicken Burger',
      'cuisine': 'Grilled chicken + 20 min',
      'rating': 4.3,
      'price': 'MK5,500',
      'type': 'Food',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchQuery = widget.initialQuery!;
      _searchController.text = widget.initialQuery!;
    }
  }

  List<Map<String, dynamic>> get _filteredResults {
    // First filter by search query
    List<Map<String, dynamic>> results = _allResults;

    if (_searchQuery.isNotEmpty) {
      results = results.where((item) {
        return item['name']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (item['cuisine']
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Then filter by type
    if (_selectedFilter == 'Restaurants') {
      return results.where((item) => item['type'] == 'Restaurant').toList();
    } else if (_selectedFilter == 'Foods') {
      return results.where((item) => item['type'] == 'Food').toList();
    }
    return results;
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.mainBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackground,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: AppTheme.primaryText),
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search for sushi, pizza...',
              hintStyle: TextStyle(color: AppTheme.mutedText),
              prefixIcon: Icon(Icons.search, color: AppTheme.mutedText),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear,
                          color: AppTheme.mutedText, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _filters.map((filter) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: _selectedFilter == filter
                            ? AppTheme.primaryButton
                            : null,
                        color: _selectedFilter == filter
                            ? null
                            : AppTheme.secondaryBackground,
                        borderRadius: BorderRadius.circular(30),
                        border: _selectedFilter == filter
                            ? null
                            : Border.all(
                                color: AppTheme.mutedText.withOpacity(0.3),
                              ),
                      ),
                      child: Text(
                        filter,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedFilter == filter
                              ? Colors.white
                              : AppTheme.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_filteredResults.length} results found',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Results
          Expanded(
            child: _filteredResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.mutedText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching for something else',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredResults.length,
                    itemBuilder: (context, index) {
                      final item = _filteredResults[index];
                      final isRestaurant = item['type'] == 'Restaurant';

                      return GestureDetector(
                        onTap: () {
                          if (isRestaurant) {
                            // Navigate to restaurant details
                            context.push('/restaurant-details');
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.deepCrimson.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Image/Icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppTheme.elevatedPanel,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isRestaurant
                                      ? Icons.restaurant
                                      : Icons.fastfood,
                                  color: AppTheme.mutedText,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryText,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isRestaurant
                                          ? item['cuisine']
                                          : item['cuisine'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 12,
                                          color: AppTheme.yellow,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item['rating'].toString(),
                                          style: TextStyle(
                                            color: AppTheme.secondaryText,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        isRestaurant
                                            ? Row(
                                                children: [
                                                  const Icon(
                                                    Icons.access_time,
                                                    size: 12,
                                                    color: AppTheme.mutedText,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    item['time'],
                                                    style: TextStyle(
                                                      color: AppTheme.mutedText,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                item['price'],
                                                style: TextStyle(
                                                  color: AppTheme.primaryRed,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppTheme.mutedText,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
