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
        // First, upload the image
        final uploadResult = await ApiServices.uploadImage(event.imageFile);

        if (!uploadResult['success']) {
          emit(WardrobeError(message: uploadResult['message']));
          return;
        }

        // Get the uploaded image URL from the response
        final imageUrl =
            uploadResult['data']['url']; // Using 'url' from your FastAPI response

        if (imageUrl == null) {
          emit(WardrobeError(message: 'Failed to get uploaded image URL'));
          return;
        }

        // Now add the wardrobe item with the uploaded image URL
        final result = await ApiServices.addWardrobeItem(
          name: event.name,
          category: event.category,
          color: event.color,
          imageUrl: imageUrl, // Use the uploaded image URL
          weatherTags: event.weatherTags,
          occasion: event.occasion,
        );

        debugPrint("🔍 API result structure: $result");
        debugPrint("🔍 result['success']: ${result['success']}");
        debugPrint("🔍 result['data']: ${result['data']}");

        if (result['success'] == true) {
          // Parse the response into WardrobeItem
          debugPrint(
            "🔍 Parsing wardrobe item from response: ${result['data']}",
          );
          final wardrobeItem = WardrobeItem.fromJson(result['data']);
          debugPrint("✅ Successfully parsed wardrobe item: $wardrobeItem");
          emit(WardrobeItemAdded(item: wardrobeItem));
        } else if (result['data'] != null) {
          // Fallback: if data exists but success is not true, try to parse anyway
          debugPrint(
            "🔍 Fallback: Parsing wardrobe item from response: ${result['data']}",
          );
          final wardrobeItem = WardrobeItem.fromJson(result['data']);
          debugPrint(
            "✅ Successfully parsed wardrobe item (fallback): $wardrobeItem",
          );
          emit(WardrobeItemAdded(item: wardrobeItem));
        } else {
          debugPrint("❌ Failed to add wardrobe item: ${result['message']}");
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
        String? finalImageUrl =
            event.imageUrl; // Use existing image URL by default

        // If a new image file is provided, upload it first
        if (event.imageFile != null) {
          final uploadResult = await ApiServices.uploadImage(event.imageFile!);

          if (!uploadResult['success']) {
            emit(WardrobeError(message: uploadResult['message']));
            return;
          }

          // Get the uploaded image URL from the response
          finalImageUrl =
              uploadResult['data']['url']; // Using 'url' from your FastAPI response

          if (finalImageUrl == null) {
            emit(WardrobeError(message: 'Failed to get uploaded image URL'));
            return;
          }
        }

        final result = await ApiServices.updateWardrobeItem(
          itemId: event.itemId,
          name: event.name ?? "",
          category: event.category ?? "",
          color: event.color ?? "",
          imageUrl: finalImageUrl ?? "",
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

        debugPrint("🔍 BLoC - Delete API result: $result");

        if (result['success']) {
          debugPrint(
            "🔍 BLoC - Delete successful, emitting WardrobeItemDeleted",
          );
          emit(WardrobeItemDeleted(message: result['message']));

          // Immediately fetch fresh wardrobe items to update the list
          debugPrint("🔍 BLoC - Fetching fresh wardrobe items after deletion");
          final freshResult = await ApiServices.getWardrobeItems();

          if (freshResult['success']) {
            debugPrint(
              "🔍 BLoC - Fresh items fetched successfully, emitting WardrobeItemsLoaded",
            );
            emit(WardrobeItemsLoaded(items: freshResult['data']));
          } else {
            debugPrint(
              "🔍 BLoC - Failed to fetch fresh items: ${freshResult['message']}",
            );
            emit(WardrobeError(message: freshResult['message']));
          }
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
