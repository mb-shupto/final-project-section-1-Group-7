import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'product_list_screen.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Inventory Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              // AuthWrapper will automatically navigate to LoginScreen
            },
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, child) {
          if (inventoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalProducts = inventoryProvider.totalProducts;
          final lowStock = inventoryProvider.lowStockCount;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2,
                                size: 40,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Total Products',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '$totalProducts',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        elevation: 4,
                        color: lowStock > 0 ? Colors.red[50] : null,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                size: 40,
                                color: lowStock > 0
                                    ? Colors.red[700]
                                    : Colors.green[700],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Low Stock Items',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '$lowStock',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: lowStock > 0
                                      ? Colors.red[700]
                                      : Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Preview of Products
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductListScreen(),
                          ),
                        );
                      },
                      child: const Text('View All →'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: inventoryProvider.filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No products yet',
                                style: TextStyle(fontSize: 18),
                              ),
                              const Text(
                                'Tap the + button to add your first item',
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: inventoryProvider.filteredProducts.length
                              .clamp(0, 5), // Show max 5
                          itemBuilder: (context, index) {
                            final product =
                                inventoryProvider.filteredProducts[index];
                            return Card(
                              child: ListTile(
                                leading:
                                    product.imageUrl != null &&
                                        product.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        product.imageUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.inventory_2, size: 40),
                                title: Text(product.name),
                                subtitle: Text(
                                  '${product.quantity} in stock • ${product.category}',
                                ),
                                trailing: product.quantity < 10
                                    ? const Icon(
                                        Icons.warning,
                                        color: Colors.red,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),

      // Floating Action Button to Add Product
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ProductListScreen(), // We'll go to list screen for adding
            ),
          );
        },
        child: const Icon(Icons.inventory),
        tooltip: 'Add Product',
      ),
    );
  }
}
