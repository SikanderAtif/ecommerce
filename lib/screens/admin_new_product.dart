import 'dart:io';
import 'package:ecommerce/models/category.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AdminNewProduct extends StatefulWidget {
  const AdminNewProduct({super.key});

  @override
  State<AdminNewProduct> createState() => _AdminNewProductState();
}

class _AdminNewProductState extends State<AdminNewProduct> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  Category? _selectedCategory;
  XFile? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  final String _baseURL = dotenv.env["BASE_API_URL"]!;

  @override
  void dispose() {
    _descController.dispose();
    _priceController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _uploadImages() async {
    final String name = _nameController.text.trim();
    final String desc = _descController.text.trim();
    final String price = _priceController.text.trim();

    if (name.isEmpty ||
        desc.isEmpty ||
        price.isEmpty ||
        _selectedCategory == null ||
        _selectedImage == null) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    _showLoadingDialog('Uploading');
    try {
      final String apiURL = "$_baseURL/api/upload";
      final Map<String, String> header = {
        'ngrok-skip-browser-warning': 'true', // Bypasses the HTML warning page
        'Accept': 'application/json',
        'Connnection': 'close',
      };

      debugPrint("Sending request to target: $apiURL");

      var request = http.MultipartRequest('POST', Uri.parse(apiURL));
      request.headers.addAll(header);

        final bytes = await _selectedImage!.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('image', bytes, filename: _selectedImage!.name),
      );

      request.fields['name'] = name;
      request.fields['desc'] = desc;
      request.fields['price'] = price;
      request.fields['category'] = _selectedCategory!.label;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _showSnackBar('Upload successful!');
        if (mounted && context.canPop()) {
          Navigator.pop(context);
        }

        if (mounted && context.canPop()) {
          context.pop();
        }
      } else {
        _showSnackBar('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error occured: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
      if (mounted && context.canPop()) {
        Navigator.pop(context);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('New Product'), scrolledUnderElevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Product Name',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 0,
                  top: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.secondary.withValues(alpha: 0.2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(color: color.primary),
                        decoration: InputDecoration(
                          hint: Text(
                            'Apple',
                            style: TextStyle(color: color.secondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              Text(
                'Product Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 0,
                  top: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.secondary.withValues(alpha: 0.2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _descController,
                        style: TextStyle(color: color.primary),
                        maxLines: 4,
                        decoration: InputDecoration(
                          hint: Text(
                            'A fresh juicy apple.',
                            style: TextStyle(color: color.secondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              Text(
                'Product Price',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 0,
                  top: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.secondary.withValues(alpha: 0.2),
                ),
                child: Row(
                  children: [
                    Text('PKR  ', style: TextStyle(color: color.primary)),
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        style: TextStyle(color: color.primary),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hint: Text(
                            '50',
                            style: TextStyle(color: color.secondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              Text(
                'Product Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Category.values.length,
                  itemBuilder: (BuildContext context, int index) {
                    final category = Category.values[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: category.color.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: _selectedCategory == category
                                      ? category.color
                                      : category.color.withValues(alpha: 0.1),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: category.icon,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.label,
                              style: TextStyle(
                                color: _selectedCategory == category
                                    ? category.color
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Text(
                'Product Images',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              _selectedImage != null
                  ? kIsWeb
                        ? Image.network(
                            _selectedImage!.path,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_selectedImage!.path),
                            height: 250,
                            width: 250,
                            fit: BoxFit.cover,
                          )
                  : Icon(Icons.image, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo_library),
                    label: Text('Gallery'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text('Camera'),
                  ),
                ],
              ),
              SizedBox(height: 30),

              _isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _selectedImage == null ? null : _uploadImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Upload'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
