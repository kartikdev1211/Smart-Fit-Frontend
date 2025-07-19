// ignore_for_file: unused_field, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_bloc.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_event.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_state.dart';

class WardrobeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const WardrobeDetailScreen({super.key, required this.item});

  @override
  State<WardrobeDetailScreen> createState() => _WardrobeDetailScreenState();
}

class _WardrobeDetailScreenState extends State<WardrobeDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _occasionController = TextEditingController();
  String? _selectedCategory;
  List<String> _selectedWeatherTags = [];
  String? _imageUrl;

  // Store the current item data that can be updated
  late Map<String, dynamic> _currentItem;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _currentItem = Map<String, dynamic>.from(widget.item);
    _nameController.text = _currentItem['name'] ?? '';
    _colorController.text = _currentItem['color'] ?? '';
    _occasionController.text = _currentItem['occasion'] ?? '';
    _selectedCategory = _currentItem['category'];
    _imageUrl = _currentItem['image_url'];
    _selectedWeatherTags = List<String>.from(
      _currentItem['weather_tags'] ?? [],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    _occasionController.dispose();
    super.dispose();
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _colorController,
                  decoration: const InputDecoration(
                    labelText: 'Color',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _occasionController,
                  decoration: const InputDecoration(
                    labelText: 'Occasion (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateItem();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _updateItem() {
    final itemId = widget.item['_id'];
    debugPrint("🔍 _updateItem - Item ID: $itemId");
    debugPrint("🔍 _updateItem - Current item: $_currentItem");

    if (itemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Item ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updateData = {
      'name': _nameController.text.isNotEmpty
          ? _nameController.text
          : _currentItem['name'],
      'category': _currentItem['category'],
      'color': _colorController.text.isNotEmpty
          ? _colorController.text
          : _currentItem['color'],
      'image_url': _currentItem['image_url'],
      'weather_tags': List<String>.from(_currentItem['weather_tags'] ?? []),
      'occasion': _occasionController.text.isNotEmpty
          ? _occasionController.text
          : _currentItem['occasion'],
    };

    debugPrint("🔍 _updateItem - Update data: $updateData");

    context.read<WardrobeBloc>().add(
      UpdateWardrobeItemEvent(
        itemId: itemId,
        name: updateData['name'],
        category: updateData['category'],
        color: updateData['color'],
        imageUrl: updateData['image_url'],
        weatherTags: updateData['weather_tags'],
        occasion: updateData['occasion'],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text(
            'Are you sure you want to delete "${_currentItem['name']}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem() {
    final itemId = widget.item['_id'];
    if (itemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Item ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<WardrobeBloc>().add(DeleteWardrobeItemEvent(itemId: itemId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WardrobeBloc, WardrobeState>(
      listener: (context, state) {
        if (state is WardrobeItemUpdated) {
          // Update the current item data with the response
          _currentItem = state.item.toJson();

          // Update the controllers with new data
          _nameController.text = _currentItem['name'] ?? '';
          _colorController.text = _currentItem['color'] ?? '';
          _occasionController.text = _currentItem['occasion'] ?? '';

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Trigger a rebuild to show updated data
          setState(() {});
        } else if (state is WardrobeItemUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is WardrobeItemDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to wardrobe screen with result to trigger refresh
          Navigator.pop(context, true);
        } else if (state is WardrobeError) {
          debugPrint("Error in WardrobeDetailScreen: ${state.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Text(
              _currentItem['name'] ?? 'Item Details',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  _showEditDialog(context);
                },
                icon: const Icon(Icons.edit, color: Color(0xFF111827)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    child: Image.network(
                      _currentItem['image_url'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 80,
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
                              strokeWidth: 3,
                              color: Color(0xFF5A4FCF),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Details Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Name
                      Text(
                        _currentItem['name'] ?? 'Unnamed Item',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A4FCF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF5A4FCF),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _currentItem['category'] ?? 'Uncategorized',
                          style: const TextStyle(
                            color: Color(0xFF5A4FCF),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Details Cards
                      _buildDetailCard(
                        title: 'Color',
                        value: _currentItem['color'] ?? 'Not specified',
                        icon: Icons.palette,
                      ),
                      const SizedBox(height: 16),

                      if (_currentItem['occasion'] != null) ...[
                        _buildDetailCard(
                          title: 'Occasion',
                          value: _currentItem['occasion'],
                          icon: Icons.event,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Weather Tags
                      _buildWeatherTagsSection(),
                      const SizedBox(height: 32),

                      // Delete Button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showDeleteDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.delete, size: 20),
                          label: const Text(
                            'Delete Item',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String value,
    required IconData icon,
    bool isDebug = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF5A4FCF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF5A4FCF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDebug ? Colors.grey[500] : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherTagsSection() {
    final weatherTags = _currentItem['weather_tags'] as List<dynamic>? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A4FCF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wb_sunny,
                  color: Color(0xFF5A4FCF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Weather Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (weatherTags.isEmpty)
            Text(
              'No weather tags specified',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weatherTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A4FCF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
