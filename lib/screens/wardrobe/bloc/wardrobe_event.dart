import 'dart:io';

abstract class WardrobeEvent {}

class AddWardrobeItemEvent extends WardrobeEvent {
  final String name;
  final String category;
  final String color;
  final File imageFile; // Changed from String imageUrl to File imageFile
  final List<String> weatherTags;
  final String? occasion;

  AddWardrobeItemEvent({
    required this.name,
    required this.category,
    required this.color,
    required this.imageFile, // Updated parameter
    required this.weatherTags,
    this.occasion,
  });
}

class FetchWardrobeItemsEvent extends WardrobeEvent {}

class UpdateWardrobeItemEvent extends WardrobeEvent {
  final String itemId;
  final String? name;
  final String? category;
  final String? color;
  final String? imageUrl;
  final File? imageFile; // Add support for new image file
  final List<String>? weatherTags;
  final String? occasion;

  UpdateWardrobeItemEvent({
    required this.itemId,
    this.name,
    this.category,
    this.color,
    this.imageUrl,
    this.imageFile, // Add new parameter
    this.weatherTags,
    this.occasion,
  });
}

class DeleteWardrobeItemEvent extends WardrobeEvent {
  final String itemId;

  DeleteWardrobeItemEvent({required this.itemId});
}
