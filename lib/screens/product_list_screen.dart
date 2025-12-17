import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'default';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Show modal bottom sheet to Add or Edit a product
  void _showAddEditDialog({Product? product}) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final quantityController = TextEditingController(
      text: product?.quantity.toString() ?? '',
    );
    final imageUrlController = TextEditingController(
      text: product?.imageUrl ?? '',
    );
    String selectedCategory = product?.category ?? 'General';

    // Predefined categories to show in the modal
    const List<String> predefinedCategories = [
      'Groceries',
      'Stationery',
      'Beverages',
      'Snacks',
      'Confectionery',
    ];

    final provider = Provider.of<InventoryProvider>(context, listen: false);

    // Merge provider categories (exclude 'All') with predefined set and keep unique
    final mergedSet = <String>{};
    mergedSet.addAll(predefinedCategories);
    mergedSet.addAll(provider.categories.where((c) => c != 'All'));
    final categories = mergedSet.toList()..sort();

    // Ensure selectedCategory exists in the list
    if (!categories.contains(selectedCategory)) {
      categories.insert(0, selectedCategory);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use StatefulBuilder so the dropdown updates visually when changed
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing ? 'Edit Product' : 'Add New Product',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedCategory = value ?? 'General';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL (optional)',
                        hintText: 'https://example.com/image.jpg',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isEmpty ||
                                quantityController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill required fields'),
                                ),
                              );
                              return;
                            }

                            final newProduct = Product(
                              id: isEditing ? product!.id : null,
                              name: nameController.text.trim(),
                              quantity:
                              int.tryParse(quantityController.text) ?? 0,
                              category: selectedCategory,
                              imageUrl: imageUrlController.text.isEmpty
                                  ? null
                                  : imageUrlController.text.trim(),
                            );

                            if (isEditing) {
                              await Provider.of<InventoryProvider>(
                                context,
                                listen: false,
                              ).updateProduct(newProduct);
                            } else {
                              await Provider.of<InventoryProvider>(
                                context,
                                listen: false,
                              ).addProduct(newProduct);
                            }

                            Navigator.pop(context);
                          },
                          child: Text(isEditing ? 'Update' : 'Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final products = inventoryProvider.products ?? [];
    final query = _searchController.text.trim().toLowerCase();
    final selectedCategory = inventoryProvider.selectedCategory;

    final filtered = products.where((p) {
      final matchesSearch = query.isEmpty
          ? true
          : p.name.toLowerCase().contains(query);

      final matchesCategory = (selectedCategory == 'All' || selectedCategory.isEmpty)
          ? true
          : (p.category == selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Replace the search + chips section with this:
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      inventoryProvider.setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          inventoryProvider.setSearchQuery('');
                        },
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: inventoryProvider.selectedCategory,
                  icon: const Icon(Icons.filter_list),
                  underline: Container(height: 2, color: Colors.blue),
                  onChanged: (String? newCategory) {
                    if (newCategory != null) {
                      inventoryProvider.setCategoryFilter(newCategory);
                    }
                  },
                  items: inventoryProvider.categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final p = filtered[index];
                return ListTile(
                  leading: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                      ? Image.network(
                    p.imageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.inventory_2),
                  title: Text(p.name),
                  subtitle: Text(
                    'Qty: ${p.quantity} \u2022 ${p.category ?? ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddEditDialog(product: p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final id = p.id;
                          if (id == null || id.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Cannot delete product: missing id',
                                ),
                              ),
                            );
                            return;
                          }
                          await inventoryProvider.deleteProduct(id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
