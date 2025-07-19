import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_event.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_state.dart';
import 'package:smart_fit/services/api_services.dart';
import 'package:smart_fit/models/wardrobe_item.dart';

class WardrobeBloc extends Bloc<WardrobeEvent, WardrobeState> {
  WardrobeBloc() : super(WardrobeInitial()) {
    on<AddWardrobeItemEvent>((event, emit) async {
      emit(WardrobeLoading());
      try {
        final result = await ApiServices.addWardrobeItem(
          name: event.name,
          category: event.category,
          color: event.color,
          imageUrl: event.imageUrl,
          weatherTags: event.weatherTags,
          occasion: event.occasion,
        );

        if (result['success']) {
          // Parse the response into WardrobeItem
          final wardrobeItem = WardrobeItem.fromJson(result['data']);
          emit(WardrobeItemAdded(item: wardrobeItem));
        } else {
          emit(WardrobeError(message: result['message']));
        }
      } catch (e) {
        emit(WardrobeError(message: e.toString()));
      }
    });

    on<FetchWardrobeItemsEvent>((event, emit) async {
      emit(WardrobeLoading());
      try {
        final result = await ApiServices.getWardrobeItems();

        if (result['success']) {
          emit(WardrobeItemsLoaded(items: result['data']));
        } else {
          emit(WardrobeError(message: result['message']));
        }
      } catch (e) {
        emit(WardrobeError(message: e.toString()));
      }
    });

    on<UpdateWardrobeItemEvent>((event, emit) async {
      emit(WardrobeLoading());
      try {
        final result = await ApiServices.updateWardrobeItem(
          itemId: event.itemId,
          name: event.name ?? "",
          category: event.category ?? "",
          color: event.color ?? "",
          imageUrl: event.imageUrl ?? "",
          weatherTags: event.weatherTags ?? [],
          occasion: event.occasion ?? "",
        );

        if (result['success']) {
          // Check if the response contains updated item data or just a success message
          if (result['data'] is Map && result['data'].containsKey('msg')) {
            // API returned success message, not updated item data
            emit(WardrobeItemUpdateSuccess(message: result['data']['msg']));
          } else {
            // Parse the response into WardrobeItem
            final wardrobeItem = WardrobeItem.fromJson(result['data']);
            emit(WardrobeItemUpdated(item: wardrobeItem));
          }
        } else {
          emit(WardrobeError(message: result['message']));
        }
      } catch (e) {
        emit(WardrobeError(message: e.toString()));
      }
    });

    on<DeleteWardrobeItemEvent>((event, emit) async {
      debugPrint(
        "🔍 BLoC - DeleteWardrobeItemEvent received for item: ${event.itemId}",
      );
      emit(WardrobeLoading());
      try {
        final result = await ApiServices.deleteWardrobeItem(
          itemId: event.itemId,
        );

        if (result['success']) {
          debugPrint(
            "🔍 BLoC - Delete successful, emitting WardrobeItemDeleted",
          );
          emit(WardrobeItemDeleted(message: result['message']));
        } else {
          debugPrint("🔍 BLoC - Delete failed: ${result['message']}");
          emit(WardrobeError(message: result['message']));
        }
      } catch (e) {
        debugPrint("🔍 BLoC - Delete exception: $e");
        emit(WardrobeError(message: e.toString()));
      }
    });
  }
}
