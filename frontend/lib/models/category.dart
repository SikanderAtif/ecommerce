import 'package:flutter/material.dart';

enum Category {
  vegetable, fruit, beverage, grocery, edibleOil, household, babycare;

  String get label {
    switch (this) {
      case vegetable: return 'Vegetables';
      case fruit: return 'Fruits';
      case beverage: return 'Beverages';
      case grocery: return 'Grocery';
      case edibleOil: return 'Edible oil';
      case household: return 'Household';
      case babycare: return 'Babycare';
    }
  }

  Color get color {
    switch (this) {
      case vegetable: return Colors.green;
      case fruit: return Colors.red;
      case beverage: return const Color.fromARGB(255, 239, 216, 11);
      case grocery: return Colors.purple;
      case edibleOil: return Colors.teal;
      case household: return Colors.pink;
      case babycare: return Colors.blue;
    }
  }

  Icon get icon {
    switch (this) {
      case vegetable: return Icon(Icons.eco, color: color);
      case fruit: return Icon(Icons.apple, color: color);
      case beverage: return Icon(Icons.coffee, color: color);
      case grocery: return Icon(Icons.shopping_basket, color: color);
      case edibleOil: return Icon(Icons.liquor, color: color);
      case household: return Icon(Icons.iron, color: color);
      case babycare: return Icon(Icons.child_care, color: color);
    }
  }
}