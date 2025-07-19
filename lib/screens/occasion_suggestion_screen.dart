import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_bloc.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_event.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_state.dart';
import 'package:smart_fit/models/wardrobe_item.dart';

class OccasionSuggestionScreen extends StatefulWidget {
  const OccasionSuggestionScreen({super.key});

  @override
  State<OccasionSuggestionScreen> createState() =>
      _OccasionSuggestionScreenState();
}

class _OccasionSuggestionScreenState extends State<OccasionSuggestionScreen> {
  String? _selectedOccasion;
  List<WardrobeItem> _suggestions = [];
  bool _isLoadingSuggestions = false;

  final List<String> _occasions = [
    'Casual',
    'Formal',
    'Party',
    'Gym',
    'Travel',
    'Wedding',
    'Business',
    'Date Night',
    'Weekend',
    'Holiday',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch wardrobe items when screen loads
    context.read<WardrobeBloc>().add(FetchWardrobeItemsEvent());
  }

  void _generateSuggestions() {
    if (_selectedOccasion == null) return;

    setState(() {
      _isLoadingSuggestions = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
          _suggestions = _generateSuggestionsFromWardrobe();
        });
      }
    });
  }

  List<WardrobeItem> _generateSuggestionsFromWardrobe() {
    final state = context.read<WardrobeBloc>().state;
    if (state is! WardrobeItemsLoaded) {
      return [];
    }

    final wardrobeItems = state.items;
    if (wardrobeItems.isEmpty) {
      return [];
    }

    // Filter items based on occasion
    List<WardrobeItem> suitableItems = [];

    for (var item in wardrobeItems) {
      if (_isItemSuitableForOccasion(item, _selectedOccasion!)) {
        suitableItems.add(item);
      }
    }

    // Shuffle and limit to 6 items
    suitableItems.shuffle();
    return suitableItems.take(6).toList();
  }

  bool _isItemSuitableForOccasion(WardrobeItem item, String occasion) {
    final itemOccasion = item.occasion?.toLowerCase();
    final occasionLower = occasion.toLowerCase();

    // Direct match
    if (itemOccasion == occasionLower) {
      return true;
    }

    // Category-based matching
    final category = item.category.toLowerCase();

    switch (occasionLower) {
      case 'casual':
        return ['casual', 'tops', 'bottoms', 'outerwear'].contains(category) ||
            itemOccasion == null; // Include items without occasion
      case 'formal':
        return ['formal', 'business', 'dress'].contains(category);
      case 'party':
        return ['party', 'dress', 'formal'].contains(category);
      case 'gym':
        return ['gym', 'sport', 'athletic'].contains(category);
      case 'travel':
        return ['travel', 'casual', 'comfortable'].contains(category);
      case 'wedding':
        return ['wedding', 'formal', 'dress'].contains(category);
      case 'business':
        return ['business', 'formal', 'professional'].contains(category);
      case 'date night':
        return ['dress', 'formal', 'elegant'].contains(category);
      case 'weekend':
        return ['casual', 'comfortable', 'relaxed'].contains(category);
      case 'holiday':
        return ['casual', 'comfortable', 'travel'].contains(category);
      default:
        return true; // Include all items for unknown occasions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Occasion Suggestions",
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<WardrobeBloc, WardrobeState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  "Choose an Occasion",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Get outfit suggestions perfect for your occasion",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Occasion Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Select Occasion:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _occasions.map((occasion) {
                          final isSelected = _selectedOccasion == occasion;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedOccasion = occasion;
                              });
                              _generateSuggestions();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF5A4FCF)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF5A4FCF)
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                occasion,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Suggestions Section
                if (_selectedOccasion != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Suggestions for $_selectedOccasion",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      if (_isLoadingSuggestions)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF5A4FCF),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingSuggestions)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF5A4FCF),
                        ),
                      ),
                    )
                  else if (_suggestions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.checkroom_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No suggestions found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adding more clothes to your wardrobe or selecting a different occasion',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final item = _suggestions[index];
                          return _buildSuggestionCard(item);
                        },
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestionCard(WardrobeItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF5A4FCF),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Details
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
