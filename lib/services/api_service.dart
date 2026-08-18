import 'dart:convert';
import 'package:ecommerce/models/order.dart';
import 'package:ecommerce/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

abstract class APIService {
  static final Map<String, String> header = {
    'ngrok-skip-browser-warning': 'true', // Bypasses the HTML warning page
    'Accept': 'application/json',
    'Connection': 'close',
  };
  static String? _apiURL;

  static Future<String?> get url async => _apiURL ?? dotenv.env['BASE_API_URL'];

  static Future<Map<String, dynamic>> createPaymentIntent({
    required String uid,
    required List<Map<String, dynamic>> items,
    String currency = 'pkr',
  }) async {
    String? api = await url;
    if (api == null) throw Exception('Empty URL');

    final apiURL = Uri.parse('$api/api/create-payment-intent');

    try {
      final response = await http.post(
        apiURL,
        headers: {...header, 'Content-Type': 'application/json'},
        body: jsonEncode({'userId': uid, 'items': items, 'currency': currency}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return responseData;
        } else {
          throw Exception(
            responseData['message'] ?? 'Failed to create payment intent',
          );
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Payment Intent Error: $e');
      rethrow;
    }
  }

  static Future<List<Product>> fetchProducts() async {
    String? api = await url;
    if (api == null) {
      throw Exception('Empty URL');
    }

    final apiURL = Uri.parse('$api/api/products');

    try {
      final response = await http.get(apiURL, headers: header);

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
      final response = await http.delete(apiURL, headers: header);

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
    required String category,
    XFile? newImage,
  }) async {
    String? api = await url;
    if (api == null) {
      throw Exception('Empty URL');
    }

    final apiURL = Uri.parse('$api/api/products/$productId');

    try {
      var request = http.MultipartRequest('PUT', apiURL);
      request.headers.addAll(header);

      request.fields['name'] = name;
      request.fields['desc'] = desc;
      request.fields['price'] = price;
      request.fields['category'] = category;

      if (newImage != null) {
        final bytes = await newImage.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('image', bytes, filename: newImage.name),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        debugPrint(
          'Update rejected by server status code: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Network failure modifying record item: $e');
      return false;
    }
  }

    static Future<List<Order>> fetchOrders(String uid) async {
    String? api = await url;
    if (api == null) {
      throw Exception('Empty URL');
    }

    final apiURL = Uri.parse('$api/api/orders/$uid');

    try {
      final response = await http.get(apiURL, headers: header);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> dataList = responseData['data'];
          return dataList
              .map((jsonItem) => Order.fromJson(jsonItem))
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

}
