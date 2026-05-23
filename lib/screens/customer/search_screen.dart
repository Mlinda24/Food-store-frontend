import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Restaurants', 'Foods'];

  // Sample search results
  final List<Map<String, dynamic>> _searchResults = [
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
  ];

  List<Map<String, dynamic>> get _filteredResults {
    if (_selectedFilter == 'All') {
      return _searchResults;
    } else if (_selectedFilter == 'Restaurants') {
      return _searchResults.where((item) => item['type'] == 'Restaurant').toList();
    } else {
      return _searchResults.where((item) => item['type'] == 'Food').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground, // #0F0A0A
      appBar: AppBar(
        backgroundColor: AppTheme.mainBackground, // #0F0A0A
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText), // #FFFFFF
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackground, // #1A0D0D
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: AppTheme.primaryText), // #FFFFFF
            decoration: InputDecoration(
              hintText: 'Search for sushi, pizza...',
              hintStyle: TextStyle(color: AppTheme.mutedText), // #8A8A8A
              prefixIcon: Icon(Icons.search, color: AppTheme.mutedText), // #8A8A8A
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
                            ? AppTheme.primaryButtonGradient // #FF2E2E → #B11226
                            : null,
                        color: _selectedFilter == filter
                            ? null
                            : AppTheme.secondaryBackground, // #1A0D0D
                        borderRadius: BorderRadius.circular(30),
                        border: _selectedFilter == filter
                            ? null
                            : Border.all(
                                color: AppTheme.mutedText.withOpacity(0.3), // #8A8A8A
                              ),
                      ),
                      child: Text(
                        filter,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedFilter == filter
                              ? Colors.white
                              : AppTheme.secondaryText, // #C9C9C9
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredResults.length,
              itemBuilder: (context, index) {
                final item = _filteredResults[index];
                final isRestaurant = item['type'] == 'Restaurant';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGlowGradient, // #2A0F0F → #7A0C18
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.deepCrimson.withOpacity(0.3), // #B11226
                    ),
                  ),
                  child: Row(
                    children: [
                      // Image/Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.elevatedPanel, // #331313
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isRestaurant ? Icons.restaurant : Icons.fastfood,
                          color: AppTheme.mutedText, // #8A8A8A
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
                                color: AppTheme.primaryText, // #FFFFFF
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isRestaurant 
                                  ? item['cuisine'] 
                                  : item['cuisine'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText, // #C9C9C9
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: AppTheme.yellow, // #FACC15
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item['rating'].toString(),
                                  style: TextStyle(
                                    color: AppTheme.secondaryText, // #C9C9C9
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
                                            color: AppTheme.mutedText, // #8A8A8A
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            item['time'],
                                            style: TextStyle(
                                              color: AppTheme.mutedText, // #8A8A8A
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        item['price'],
                                        style: TextStyle(
                                          color: AppTheme.primaryRed, // #FF2E2E
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
                        color: AppTheme.mutedText, // #8A8A8A
                      ),
                    ],
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