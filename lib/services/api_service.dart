import 'dart:convert';
import 'package:ecommerce/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

abstract class APIService {
  static String? _apiURL;

  static Future<String?> get url async {
    if (_apiURL == null) {
      await dotenv.load();
      _apiURL = dotenv.env['BASE_API_URL'];
    }

    return _apiURL;
  }

  static Future<dynamic> fetchProducts() async {
    String? api = await url;
    if (api == null) {
      throw Exception('Empty URL');
    }

    final apiURL = Uri.parse('$api/api/products');

    try {
      final response = await http.get(apiURL);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> dataList = responseData['data'];
          return dataList
              .map((jsonItem) => Product.fromJson(jsonItem))
              .toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to parse items.');
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
      throw Exception("Connection failed: $e");
    }
  }

  static Future<bool> deleteProduct(int productID) async {
    String? api = await url;
    if (api == null) {
      throw Exception('Empty URL');
    }

    final apiURL = Uri.parse('$api/api/products/$productID');

    try {
      final response = await http.delete(apiURL);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        debugPrint("Server reaction error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Network failure deleting item: $e");
      return false;
    }
  }

  static Future<bool> updateProduct({
    required int productId,
    required String name,
    required String desc,
    required String price,
    XFile? newImage,
  }) async {
    String? api = await url;
    if (api == null) {
      throw Exception('Empty URL');
    }

    final apiURL = Uri.parse('$api/api/products/$productId');

    try {
      var request = http.MultipartRequest('PUT', apiURL);

      request.fields['name'] = name;
      request.fields['desc'] = desc;
      request.fields['price'] = price;

      if (newImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', newImage.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        debugPrint('Update rejected by server status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Network failure modifying record item: $e');
      return false;
    }
  }
}
