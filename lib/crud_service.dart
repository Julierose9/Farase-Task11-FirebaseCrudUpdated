import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class PickedImage {
  final File file;
  final String url;
  PickedImage ({required this.file, required this.url});
}

class CrudService {
  final CollectionReference items =
      FirebaseFirestore.instance.collection('items');

  final CloudinaryPublic _cloudinary = CloudinaryPublic('dtb6lzcm3', 'flutter_notes_preset', cache: false);

  
  final ImagePicker _picker = ImagePicker();

  Future <PickedImage?> pickImageForAddItem() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final file = File(pickedFile.path);

    final response = await _cloudinary.uploadFile (
      CloudinaryFile.fromFile(
        file.path,
        resourceType: CloudinaryResourceType.Image
      )
    );
    return PickedImage(file: file, url: response.secureUrl);
  }

  // CREATE
  Future<void> addItemwithImage(String name, int quantity, String? imageUrl) async {
    await items.add(
      {
        'name' : name,
        'quantity' : quantity,
        'image_url' : imageUrl,
        'createdAt' : Timestamp.now()
      }
    );
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
