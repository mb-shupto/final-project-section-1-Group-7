import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user UID
  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  // Reference to user's products subcollection
  CollectionReference _userProductsRefFor(String uid) {
    return _db.collection('users').doc(uid).collection('products');
  }

  // Add product
  Future<void> addProduct(Product product) async {
    final uid = _currentUid;
    if (uid == null) throw Exception('User not authenticated');
    await _userProductsRefFor(uid).add(product.toMap());
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    if (product.id == null) throw Exception('Product ID required');
    final uid = _currentUid;
    if (uid == null) throw Exception('User not authenticated');
    await _userProductsRefFor(uid).doc(product.id).set(product.toMap(), SetOptions(merge: true));
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    final uid = _currentUid;
    if (uid == null) throw Exception('User not authenticated');
    await _userProductsRefFor(uid).doc(productId).delete();
  }

  // Real-time stream of user's products (safe for unauthenticated state)
  Stream<List<Product>> getProductsStream() {
    final uid = _currentUid;
    if (uid == null) {
      // Return an immediate empty list stream when not authenticated to avoid permission errors.
      return Stream.value(<Product>[]);
    }

    try {
      return _userProductsRefFor(uid).snapshots().handleError((error) {
        // Log the error; caller (provider) should also handle onError on listen.
        print('Firestore snapshots error: $error');
      }).map((snapshot) {
        return snapshot.docs
            .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      });
    } catch (e) {
      // If anything synchronous goes wrong, return an empty stream instead of throwing.
      print('Error creating products stream: $e');
      return Stream.value(<Product>[]);
    }
  }
}