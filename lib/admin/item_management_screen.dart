import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemManagementScreen extends StatefulWidget {
  const ItemManagementScreen({super.key});

  @override
  State<ItemManagementScreen> createState() => _ItemManagementScreenState();
}

class _ItemManagementScreenState extends State<ItemManagementScreen> {
  final itemCollection = FirebaseFirestore.instance.collection('admin_config').doc('items').collection('list');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void showItemDialog({DocumentSnapshot? existingItem}) {
    final isEditing = existingItem != null;

    if (isEditing) {
      nameController.text = existingItem['name'];
      caloriesController.text = existingItem['calories'].toString();
      priceController.text = existingItem['price'].toString();
    } else {
      nameController.clear();
      caloriesController.clear();
      priceController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Edit Item' : 'Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: caloriesController, decoration: const InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final calories = int.tryParse(caloriesController.text.trim()) ?? 0;
              final price = int.tryParse(priceController.text.trim()) ?? 0;

              if (name.isEmpty || calories <= 0 || price <= 0) return;

              if (isEditing) {
                await existingItem!.reference.update({
                  'name': name,
                  'calories': calories,
                  'price': price,
                });
              } else {
                await itemCollection.add({
                  'name': name,
                  'calories': calories,
                  'price': price,
                });
              }

              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Items")),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!.docs;

          if (items.isEmpty) return const Center(child: Text("No items added yet."));

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text("Calories: ${item['calories']} | Price: ₹${item['price']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => showItemDialog(existingItem: item)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => item.reference.delete(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showItemDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
