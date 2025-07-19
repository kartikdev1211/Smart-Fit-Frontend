import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fit/models/wardrobe_item.dart';

class ApiServices {
  static const String baseUrl = "https://smart-fit-backend.onrender.com/";

  static Future<Map<String, dynamic>> signupUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("${baseUrl}auth/signup");
    debugPrint("🔸 Sending signup request to: $url");

    try {
      final requestBody = jsonEncode({
        "full_name": fullName,
        "email": email,
        "password": password,
      });

      debugPrint("📤 Request body: $requestBody");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      debugPrint("📥 Raw response: ${response.toString()}");
      debugPrint("📥 Response body: ${response.body}");
      debugPrint("📥 Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ Signup successful: $data");
        return {"success": true, "data": data};
      } else {
        final error = jsonDecode(response.body);
        debugPrint("❌ Signup failed: ${error['detail']}");
        return {
          "success": false,
          "message": error['detail'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      debugPrint("❗ Exception during signup: $e");
      return {"success": false, "message": "Something went wrong. Try again."};
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required email,
    required password,
  }) async {
    final url = Uri.parse("${baseUrl}auth/login");
    try {
      debugPrint("🔸 Sending login request to: $url");
      debugPrint(
        "📤 Request body: ${jsonEncode({"email": email, "password": password})}",
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );

      debugPrint("📥 Raw response: $response");
      debugPrint("📥 Response body: ${response.body}");
      debugPrint("📥 Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access_token']);

        debugPrint("✅ Token saved: ${data['access_token']}");

        return {"success": true, "data": data};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? 'Login failed'};
      }
    } catch (e) {
      debugPrint("❌ Login error: $e");
      return {"success": false, "message": "Something went wrong. Try again."};
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    final url = Uri.parse("${baseUrl}user/profile");
    debugPrint("🔸 Sending profile request to: $url");

    try {
      // Get stored token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        debugPrint("❌ No access token found");
        return {
          "success": false,
          "message": "No access token found. Please login again.",
        };
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("📥 Raw response: ${response.toString()}");
      debugPrint("📥 Response body: ${response.body}");
      debugPrint("📥 Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ Profile fetched successfully: $data");
        return {"success": true, "data": data};
      } else {
        final error = jsonDecode(response.body);
        debugPrint("❌ Profile fetch failed: ${error['detail']}");
        return {
          "success": false,
          "message": error['detail'] ?? 'Failed to fetch profile',
        };
      }
    } catch (e) {
      debugPrint("❗ Exception during profile fetch: $e");
      return {"success": false, "message": "Something went wrong. Try again."};
    }
  }

  static Future<Map<String, dynamic>> addWardrobeItem({
    required String name,
    required String category,
    required String color,
    required String imageUrl,
    required List<String> weatherTags,
    String? occasion,
  }) async {
    final url = Uri.parse("${baseUrl}wardrobe/");
    debugPrint("🔸 Sending add wardrobe item request to: $url");

    try {
      // Get stored token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        debugPrint("❌ No access token found");
        return {
          "success": false,
          "message": "No access token found. Please login again.",
        };
      }

      final requestBody = jsonEncode({
        "name": name,
        "category": category,
        "color": color,
        "image_url": imageUrl,
        "weather_tags": weatherTags,
        "occasion": occasion,
      });

      debugPrint("📤 Request body: $requestBody");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      debugPrint("📥 Raw response: ${response.toString()}");
      debugPrint("📥 Response body: ${response.body}");
      debugPrint("📥 Status code: ${response.statusCode}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ Wardrobe item added successfully: $data");
        return {"success": true, "data": data};
      } else {
        final error = jsonDecode(response.body);
        debugPrint("❌ Add wardrobe item failed: ${error['detail']}");
        return {
          "success": false,
          "message": error['detail'] ?? 'Failed to add wardrobe item',
        };
      }
    } catch (e) {
      debugPrint("❗ Exception during add wardrobe item: $e");
      return {"success": false, "message": "Something went wrong. Try again."};
    }
  }

  static Future<Map<String, dynamic>> getWardrobeItems() async {
    final url = Uri.parse("${baseUrl}wardrobe/");
    debugPrint("🔸 Sending get wardrobe items request to: $url");

    try {
      // Get stored token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        debugPrint("❌ No access token found");
        return {
          "success": false,
          "message": "No access token found. Please login again.",
        };
      }

      debugPrint("🔑 Using token: $token");
      debugPrint("🔑 Full token length: ${token.length}");

      // Decode token to check user info
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final resp = utf8.decode(base64Url.decode(normalized));
          final payloadMap = jsonDecode(resp);
          debugPrint("🔑 Token payload: $payloadMap");
          debugPrint("🔑 User email from token: ${payloadMap['sub']}");
        }
      } catch (e) {
        debugPrint("🔑 Could not decode token: $e");
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("📥 Raw response: ${response.toString()}");
      debugPrint("📥 Response body: ${response.body}");
      debugPrint("📥 Status code: ${response.statusCode}");
      debugPrint("📥 Response headers: ${response.headers}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ Wardrobe items fetched successfully: $data");

        // Parse the response into WardrobeItem objects
        List<WardrobeItem> wardrobeItems = [];
        if (data is List) {
          for (var item in data) {
            try {
              wardrobeItems.add(WardrobeItem.fromJson(item));
            } catch (e) {
              debugPrint("❌ Error parsing wardrobe item: $e");
            }
          }
        }

        debugPrint("✅ Parsed ${wardrobeItems.length} wardrobe items");
        return {"success": true, "data": wardrobeItems};
      } else {
        final error = jsonDecode(response.body);
        debugPrint("❌ Get wardrobe items failed: ${error['detail']}");
        return {
          "success": false,
          "message": error['detail'] ?? 'Failed to fetch wardrobe items',
        };
      }
    } catch (e) {
      debugPrint("❗ Exception during get wardrobe items: $e");
      return {"success": false, "message": "Something went wrong. Try again."};
    }
  }

  static Future<Map<String, dynamic>> updateWardrobeItem({
    required String itemId,
    String? name,
    String? category,
    String? color,
    String? imageUrl,
    List<String>? weatherTags,
    String? occasion,
  }) async {
    final url = Uri.parse("${baseUrl}wardrobe/$itemId");
    debugPrint("🔸 Sending update wardrobe item request to: $url");
    debugPrint("🔸 Item ID: $itemId");
    debugPrint(
      "🔸 Update parameters - name: $name, category: $category, color: $color, occasion: $occasion",
    );

    try {
      // Get stored token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        debugPrint("❌ No access token found");
        return {
          "success": false,
          "message": "No access token found. Please login again.",
        };
      }

      // Build request body with all fields (API might require all fields)
      final Map<String, dynamic> requestBody = {
        'name': name ?? '',
        'category': category ?? '',
        'color': color ?? '',
        'image_url': imageUrl ?? '',
        'weather_tags': weatherTags ?? [],
        'occasion': occasion,
      };

      debugPrint("📤 Request body: ${jsonEncode(requestBody)}");

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint("📥 Raw response: ${response.toString()}");
      debugPrint("📥 Response body: ${response.body}");
      debugPrint("📥 Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ Wardrobe item updated successfully: $data");
        return {"success": true, "data": data};
      } else {
        final error = jsonDecode(response.body);
        debugPrint("❌ Update wardrobe item failed: ${error['detail']}");
        return {
          "success": false,
          "message": error['detail'] ?? 'Failed to update wardrobe item',
        };
      }
    } catch (e) {
      debugPrint("❗ Exception during update wardrobe item: $e");
      return {"success": false, "message": "Something went wrong. Try again."};
    }
  }

  static Future<Map<String, dynamic>> deleteWardrobeItem({
    required String itemId,
  }) async {
    final url = Uri.parse("${baseUrl}wardrobe/$itemId");
    debugPrint("🔸 Sending delete wardrobe item request to: $url");

    try {
      // Get stored token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        debugPrint("❌ No access token found");
        return {
          "success": false,
          "message": "No access token found. Please login again.",
        };
      }

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("📥 Raw response: ${response.toString()}");
      debugPrint("📥 Response body: ${response.body}");
      debugPrint("📥 Status code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("✅ Wardrobe item deleted successfully");
        return {"success": true, "message": "Item deleted successfully"};
      } else {
        final error = jsonDecode(response.body);
        debugPrint("❌ Delete wardrobe item failed: ${error['detail']}");
        return {
          "success": false,
          "message": error['detail'] ?? 'Failed to delete wardrobe item',
        };
      }
    } catch (e) {
      debugPrint("❗ Exception during delete wardrobe item: $e");
      return {"success": false, "message": "Something went wrong. Try again."};
    }
  }
}
