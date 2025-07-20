class WardrobeItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final String imageUrl;
  final List<String> weatherTags;
  final String? occasion;

  WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imageUrl,
    required this.weatherTags,
    this.occasion,
  });

  // Factory constructor to create WardrobeItem from JSON
  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id:
          json['_id'] ??
          json['id'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      color: json['color'] ?? '',
      imageUrl: json['image_url'] ?? '',
      weatherTags: List<String>.from(json['weather_tags'] ?? []),
      occasion: json['occasion'],
    );
  }

  // Convert WardrobeItem to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'category': category,
      'color': color,
      'image_url': imageUrl,
      'weather_tags': weatherTags,
      'occasion': occasion,
    };
  }

  // Create a copy of WardrobeItem with updated fields
  WardrobeItem copyWith({
    String? id,
    String? name,
    String? category,
    String? color,
    String? imageUrl,
    List<String>? weatherTags,
    String? occasion,
  }) {
    return WardrobeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      weatherTags: weatherTags ?? this.weatherTags,
      occasion: occasion ?? this.occasion,
    );
  }

  @override
  String toString() {
    return 'WardrobeItem(id: $id, name: $name, category: $category, color: $color, imageUrl: $imageUrl, weatherTags: $weatherTags, occasion: $occasion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WardrobeItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
