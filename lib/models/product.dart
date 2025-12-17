import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String name;
  final int quantity;
  final String category;
  final String? imageUrl;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.imageUrl,
  });

  // Convert Product to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  // Create Product from Firestore document
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      category: map['category'] ?? 'Uncategorized',
      imageUrl: map['imageUrl'],
    );
  }

  // Helper: Create a copy with updated values (useful for editing)
  Product copyWith({
    String? id,
    String? name,
    int? quantity,
    String? category,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}