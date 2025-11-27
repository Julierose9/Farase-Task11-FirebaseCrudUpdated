import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'crud_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CrudService service = CrudService();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();

  bool showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    showFavoritesOnly = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Firebase Farase',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink[900],
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: Icon(
              showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                showFavoritesOnly = !showFavoritesOnly;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink[600],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _openAddDialog(context),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: showFavoritesOnly
            ? service.getFavoriteItems()
            : service.getItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No items found", style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var item = docs[index];

              final data = item.data() as Map<String, dynamic>;
              final bool isFavorite = data['favorite'] == true;
              final imageUrl = data ['image_url'];
              
              
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  leading: imageUrl != null
                  ? ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                  : null,
                  title: Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Quantity ${data['quantity'] ?? 0}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          service.toggleFavorite(item.id, !isFavorite);
                        },
                      ),
                      
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _openEditDialog(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // DELETE UI
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              service.deleteItem(id);
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed:() => Navigator.pop(context),
            ),

        ],
      ),
    );
  }

  // ADD UI
  void _openAddDialog(BuildContext context) {
    nameCtrl.clear();
    qtyCtrl.clear();

    File?  selectedImageFile;
    String? selectedImageUrl;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder : (context, setState) => AlertDialog(
        title: const Text("Add item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            TextField(
              controller: qtyCtrl,
              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            if (selectedImageFile != null)
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(8),
              child: Image.file(
                selectedImageFile!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label:  const Text('upload image'),
              onPressed: () async {
                final pickedFile = await service.pickImageForAddItem();
                if (pickedFile != null) {
                  setState(() {
                    selectedImageFile = pickedFile.file;
                    selectedImageUrl = pickedFile.url;
                  });
                }
              },

            )
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Save"),
            onPressed: ()  async {
              if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) {
                await service.addItemwithImage(
                  nameCtrl.text,
                  int.parse(qtyCtrl.text),
                  selectedImageUrl,
                );
              Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      )
    );
  }

  // EDIT UI
  void _openEditDialog(BuildContext context, DocumentSnapshot item) {
    var data = item.data() as Map<String, dynamic>;

    nameCtrl.text = data['name'];
    qtyCtrl.text = data['quantity'].toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Update"),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) {
                service.updateItem(
                  item.id,
                  nameCtrl.text,
                  int.parse(qtyCtrl.text),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
