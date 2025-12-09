import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/lounge_service.dart';

class LoungeMenuScreen extends StatefulWidget {
  final LoungeService loungeService;
  final String loungeId;

  const LoungeMenuScreen({Key? key, required this.loungeService, required this.loungeId}) : super(key: key);

  @override
  State<LoungeMenuScreen> createState() => _LoungeMenuScreenState();
}

class _LoungeMenuScreenState extends State<LoungeMenuScreen> {
  List<dynamic> _foods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    try {
      setState(() => _isLoading = true);
      final foods = await widget.loungeService.getFoods(widget.loungeId);
      setState(() {
        _foods = foods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: Text('Menu Items', style: AppTheme.heading2)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                onPressed: () => _showAddFoodDialog(),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _foods.isEmpty
                  ? Center(child: Text('No menu items', style: AppTheme.heading3))
                  : RefreshIndicator(
                      onRefresh: _loadFoods,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _foods.length,
                        itemBuilder: (context, index) => _buildFoodCard(_foods[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.fastfood, color: AppTheme.primaryColor, size: 40),
        title: Text(food['name']),
        subtitle: Text('ETB ${food['price'].toStringAsFixed(2)} • ${food['category']}'),
        trailing: Switch(
          value: food['isAvailable'] ?? true,
          onChanged: (value) async {
            try {
              await widget.loungeService.updateFood(foodId: food['id'], isAvailable: value);
              _loadFoods();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
              );
            }
          },
        ),
      ),
    );
  }

  void _showAddFoodDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final timeController = TextEditingController();
    String selectedCategory = 'BREAKFAST';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Menu Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Prep Time (minutes)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACKS', 'DRINKS', 'DESSERT'].map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) => selectedCategory = value!,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await widget.loungeService.createFood(
                  loungeId: widget.loungeId,
                  name: nameController.text,
                  category: selectedCategory,
                  price: double.parse(priceController.text),
                  estimatedTime: int.parse(timeController.text),
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadFoods();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
