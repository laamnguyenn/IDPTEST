import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class Order {
  final String item;
  final String itemName;
  final double price;
  final int quantity;
  final String currency;

  Order({
    required this.item,
    required this.itemName,
    required this.price,
    required this.quantity,
    required this.currency,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Orders',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        fontFamily: 'Arial',
      ),
      home: const OrderPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final List<Order> _orders = [
    Order(item: 'A1000', itemName: 'iPhone 15', price: 1200, quantity: 1, currency: 'USD'),
    Order(item: 'A1001', itemName: 'iPhone 16', price: 1500, quantity: 1, currency: 'USD'),
    Order(item: 'A1002', itemName: 'Galaxy S23', price: 1100, quantity: 1, currency: 'USD'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedCurrency = 'USD';
  final _currencies = ['USD', 'VND', 'EUR', 'JPY'];

  void _showAddForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Wrap(
            runSpacing: 16,
            children: [
              Center(
                child: Text(
                  'Add Product',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(labelText: 'Item Code'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                items: _currencies
                    .map((cur) => DropdownMenuItem(value: cur, child: Text(cur)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCurrency = value);
                  }
                },
                decoration: const InputDecoration(labelText: 'Currency'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Save"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _orders.add(Order(
                        item: _itemController.text,
                        itemName: _itemNameController.text,
                        price: double.tryParse(_priceController.text) ?? 0,
                        quantity: int.tryParse(_quantityController.text) ?? 1,
                        currency: _selectedCurrency,
                      ));
                      _itemController.clear();
                      _itemNameController.clear();
                      _priceController.clear();
                      _quantityController.clear();
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '${_orders[index].itemName}'?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
          FilledButton(
            onPressed: () {
              setState(() => _orders.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _itemController.dispose();
    _itemNameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Widget _buildOrderCard(Order o, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal.shade300,
              child: const Icon(Icons.shopping_bag, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${o.quantity} × ${o.currency} ${o.price.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey.shade700)),
                  ]),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(index),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Orders'),
        centerTitle: true,
      ),
      body: _orders.isEmpty
          ? const Center(child: Text('No orders yet. Tap + to add.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (_, i) => _buildOrderCard(_orders[i], i),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddForm,
        icon: const Icon(Icons.add),
        label: const Text("Add"),
      ),
    );
  }
}
