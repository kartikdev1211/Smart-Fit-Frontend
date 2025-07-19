abstract class WardrobeEvent {}

class AddWardrobeItemEvent extends WardrobeEvent {
  final String name;
  final String category;
  final String color;
  final String imageUrl;
  final List<String> weatherTags;
  final String? occasion;

  AddWardrobeItemEvent({
    required this.name,
    required this.category,
    required this.color,
    required this.imageUrl,
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
  final List<String>? weatherTags;
  final String? occasion;

  UpdateWardrobeItemEvent({
    required this.itemId,
    this.name,
    this.category,
    this.color,
    this.imageUrl,
    this.weatherTags,
    this.occasion,
  });
}

class DeleteWardrobeItemEvent extends WardrobeEvent {
  final String itemId;

  DeleteWardrobeItemEvent({required this.itemId});
}
