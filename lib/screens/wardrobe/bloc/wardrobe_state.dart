import 'package:smart_fit/models/wardrobe_item.dart';

abstract class WardrobeState {}

class WardrobeInitial extends WardrobeState {}

class WardrobeLoading extends WardrobeState {}

class WardrobeItemAdded extends WardrobeState {
  final WardrobeItem item;

  WardrobeItemAdded({required this.item});
}

class WardrobeItemUpdated extends WardrobeState {
  final WardrobeItem item;

  WardrobeItemUpdated({required this.item});
}

class WardrobeItemUpdateSuccess extends WardrobeState {
  final String message;

  WardrobeItemUpdateSuccess({required this.message});
}

class WardrobeItemDeleted extends WardrobeState {
  final String message;

  WardrobeItemDeleted({required this.message});
}

class WardrobeItemsLoaded extends WardrobeState {
  final List<WardrobeItem> items;

  WardrobeItemsLoaded({required this.items});
}

class WardrobeError extends WardrobeState {
  final String message;

  WardrobeError({required this.message});
}
