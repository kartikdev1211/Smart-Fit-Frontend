// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_bloc.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_event.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_state.dart';
import 'package:smart_fit/models/wardrobe_item.dart';

class SuggestionScreen extends StatefulWidget {
  const SuggestionScreen({super.key});

  @override
  State<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  // Weather data
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = false;
  String? _weatherError;

  // Occasion selection
  String? _selectedOccasion;
  final List<String> _occasions = [
    'Casual',
    'Party',
    'Formal',
    'Gym',
    'Travel',
    'Wedding',
  ];

  // Suggestions
  List<WardrobeItem> _suggestions = [];
  bool _isLoadingSuggestions = false;
  List<WardrobeItem> _wardrobeItems = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    // Fetch weather and wardrobe items on init
    _fetchWeather();
    context.read<WardrobeBloc>().add(FetchWardrobeItemsEvent());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _weatherError = 'Location permission denied';
            _isLoadingWeather = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _weatherError = 'Location permissions are permanently denied';
          _isLoadingWeather = false;
        });
        return;
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint("🔍 Device Location - Latitude: ${position.latitude}");
      debugPrint("🔍 Device Location - Longitude: ${position.longitude}");
      debugPrint("🔍 Device Location - Accuracy: ${position.accuracy} meters");

      // Fetch weather data (using a free weather API)
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=1b5d7ab255cca9917c062d263b61f487',
      );

      debugPrint("🔍 Weather API URL: $url");

      final response = await http.get(url);

      debugPrint("🔍 Weather API Response Status: ${response.statusCode}");
      debugPrint("🔍 Weather API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("🔍 Weather Data: $data");

        // Debug location information
        debugPrint("🔍 API Location Name: ${data['name']}");
        debugPrint("🔍 API Coordinates: ${data['coord']}");
        debugPrint("🔍 API City ID: ${data['id']}");

        // Note: OpenWeatherMap API returns the nearest city name from their database
        // For more accurate location, you might need to use a different geocoding service

        setState(() {
          _weatherData = data;
          _isLoadingWeather = false;
        });
      } else {
        debugPrint(
          "🔍 Weather API Error: ${response.statusCode} - ${response.body}",
        );
        setState(() {
          _weatherError =
              'Failed to fetch weather data (Status: ${response.statusCode})';
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      debugPrint("🔍 Weather fetch exception: $e");
      setState(() {
        _weatherError = 'Error fetching weather: $e';
        _isLoadingWeather = false;
      });
    }
  }

  void _generateSuggestions() {
    if (_weatherData == null || _selectedOccasion == null) return;

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
    if (_wardrobeItems.isEmpty) {
      return [];
    }

    // Filter items based on occasion only
    List<WardrobeItem> suitableItems = [];

    for (var item in _wardrobeItems) {
      bool occasionSuitable = _isItemSuitableForOccasion(
        item,
        _selectedOccasion!,
      );

      // Only filter by occasion, ignore weather
      bool isSuitable = occasionSuitable;

      if (isSuitable) {
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

    // Only direct match - no category-based matching
    return itemOccasion == occasionLower;
  }

  String _getWeatherIcon(String weatherCondition) {
    switch (weatherCondition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return '☀️';
      case 'clouds':
      case 'cloudy':
        return '☁️';
      case 'rain':
      case 'rainy':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'thunderstorm':
        return '⛈️';
      case 'drizzle':
        return '🌦️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
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
          "Smart Suggestions",
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _fetchWeather,
            icon: const Icon(Icons.refresh, color: Color(0xFF111827)),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: BlocConsumer<WardrobeBloc, WardrobeState>(
          listener: (context, state) {
            if (state is WardrobeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is WardrobeItemsLoaded) {
              setState(() {
                _wardrobeItems = state.items;
              });
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weather Section
                  _buildWeatherSection(),
                  const SizedBox(height: 24),

                  // Occasion Selection
                  _buildOccasionSection(),
                  const SizedBox(height: 24),

                  // Suggestions Section
                  if (_weatherData != null && _selectedOccasion != null)
                    _buildSuggestionsSection(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeatherSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF5A4FCF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Current Weather',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingWeather)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF5A4FCF)),
            )
          else if (_weatherError != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _weatherError!,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  ),
                ],
              ),
            )
          else if (_weatherData != null)
            Row(
              children: [
                Text(
                  _getWeatherIcon(_weatherData!['weather'][0]['main']),
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _weatherData!['weather'][0]['main'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(_weatherData!['main']['temp'] - 273.15).round()}°C',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _weatherData!['name'] ?? 'Unknown Location',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOccasionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Occasion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
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
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF5A4FCF) : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF5A4FCF)
                        : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  occasion,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(WardrobeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Suggested Outfits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            TextButton.icon(
              onPressed: _suggestions.isNotEmpty ? _generateSuggestions : null,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try Another'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5A4FCF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingSuggestions)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF5A4FCF)),
          )
        else if (_suggestions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No suitable outfits found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try selecting a different occasion or add more items to your wardrobe',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return _buildSuggestionCard(suggestion);
            },
          ),
      ],
    );
  }

  Widget _buildSuggestionCard(WardrobeItem suggestion) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
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
                top: Radius.circular(16),
              ),
              child: suggestion.imageUrl.isNotEmpty
                  ? Image.network(
                      suggestion.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.checkroom,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF5A4FCF),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.checkroom,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
          ),
          // Content
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    suggestion.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    suggestion.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
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
