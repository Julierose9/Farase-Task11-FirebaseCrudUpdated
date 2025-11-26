import 'package:cloud_firestore/cloud_firestore.dart';

class CrudService {
  final CollectionReference items =
      FirebaseFirestore.instance.collection('items');

  // CREATE
  Future<void> addItem(String name, int quantity) {
    return items.add({
      'name': name,
      'quantity': quantity,
      'favorite': false,          
      'createdAt': Timestamp.now(),
    });
  }

  // READ - all items
  Stream<QuerySnapshot> getItems() {
    return items.orderBy('createdAt', descending: true).snapshots();
  }

  // READ - only favorite items
  Stream<QuerySnapshot> getFavoriteItems() {
    return items
        .where('favorite', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // UPDATE item data
  Future<void> updateItem(String id, String name, int quantity) {
    return items.doc(id).update({
      'name': name,
      'quantity': quantity,
    });
  }

  // TOGGLE FAVORITE
  Future<void> toggleFavorite(String id, bool value) {
    return items.doc(id).update({
      'favorite': value,
    });
  }

  // DELETE
  Future<void> deleteItem(String id) {
    return items.doc(id).delete();
  }
}
