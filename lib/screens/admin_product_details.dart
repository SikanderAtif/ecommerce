import 'dart:io';
import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/api_service.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AdminProductDetails extends StatefulWidget {
  final Product item;
  const AdminProductDetails({super.key, required this.item});

  @override
  State<AdminProductDetails> createState() => _AdminProductDetailsState();
}

class _AdminProductDetailsState extends State<AdminProductDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  late Category _selectedCategory;
  XFile? _selectedNewImage;
  bool _isLoading = false;

  @override
  void initState() {
    _selectedCategory = widget.item.category;
    super.initState();
    _nameController.text = widget.item.name;
    _priceController.text = widget.item.price.toString();
    _descController.text = widget.item.description;
  }

  @override
  void dispose() {
    _descController.dispose();
    _priceController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _selectedNewImage = image;
      });
    }
  }

  void _deleteItem() async {
    setState(() => _isLoading = true);
    bool success = await APIService.deleteProduct(widget.item.id);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully!')),
        );
        if (context.canPop()) context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete product.')),
        );
      }
    }
  }

  void _updateItem() async {
    final String name = _nameController.text.trim();
    final String desc = _descController.text.trim();
    final String price = _priceController.text.trim();

    if (name.isEmpty || desc.isEmpty || price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all input fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await APIService.updateProduct(
      productId: widget.item.id,
      name: name,
      desc: desc,
      price: price,
      category: _selectedCategory.label,
      newImage: _selectedNewImage,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
        if (context.canPop()) {
          context.pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save product changes.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isLoading ? null : _deleteItem,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _selectedNewImage != null
                          ? kIsWeb
                              ? Image.network(
                                  _selectedNewImage!.path,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedNewImage!.path),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                          : widget.item.imageURL.isNotEmpty
                              ? Image.network(
                                  widget.item.imageURL,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) =>
                                      const Center(
                                    child: Icon(Icons.broken_image, size: 40),
                                  ),
                                )
                              : Container(color: color.secondary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.only(
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
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: "Product Name",
                            ),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.only(
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
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: "Price",
                            ),
                            style: TextStyle(color: color.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.only(
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
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: "Description",
                            ),
                            style: TextStyle(color: color.primary),
                            maxLines: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

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
                                    color: category.color.withValues(
                                      alpha: 0.1,
                                    ),
                                    border: Border.all(
                                      color: _selectedCategory == category
                                          ? category.color
                                          : category.color.withValues(
                                              alpha: 0.1,
                                            ),
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

                  SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _selectImage,
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                      _selectedNewImage != null
                          ? 'Change Chosen Image'
                          : 'Replace Product Image',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateItem,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Update Product Details'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
