import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/food.dart';
import '../../models/lounge.dart';
import '../lounge/lounge_details_screen.dart';
import '../order/cart_screen.dart';

class FoodDetailScreen extends StatefulWidget {
  final Food food;
  final Lounge? lounge;

  const FoodDetailScreen({Key? key, required this.food, this.lounge}) : super(key: key);

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;

  double get _total => widget.food.price * _quantity;

  void _increment() {
    setState(() => _quantity += 1);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity -= 1);
    }
  }

  void _handleOrder() {
    final cartItem = CartItem(
      foodId: widget.food.id,
      foodName: widget.food.name,
      price: widget.food.price,
      quantity: _quantity,
      imageUrl: widget.food.image,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CartScreen(initialItems: [cartItem]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return Scaffold(
      appBar: AppBar(
        title: Text(food.name),
      ),
      body: Column(
        children: [
          _buildHero(food),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(food.name, style: AppTheme.heading2),
                const SizedBox(height: 8),
                Text(
                  'ETB ${food.price.toStringAsFixed(2)}',
                  style: AppTheme.heading3.copyWith(color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 16),
                if (food.description != null)
                  Text(
                    food.description!,
                    style: AppTheme.bodyMedium,
                  ),
                if (widget.lounge != null) ...[
                  const SizedBox(height: 24),
                  _buildLoungeCard(widget.lounge!),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip(Icons.category, food.category),
                    _buildChip(Icons.local_fire_department, food.spicyLevel),
                    if (food.isVegetarian)
                      _buildChip(Icons.eco, 'Vegetarian'),
                    Text(
                      'Preparation time: ${food.estimatedTime} min',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ingredients', style: AppTheme.heading3),
                        const SizedBox(height: 8),
                        if (food.ingredients?.isNotEmpty ?? false)
                          ...food.ingredients!.map(
                            (ingredient) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 16, color: AppTheme.primaryColor),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(ingredient)),
                                ],
                              ),
                            ),
                          )
                        else
                          Text(
                            'No ingredients listed',
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Allergens', style: AppTheme.heading3),
                        const SizedBox(height: 8),
                        if (food.allergens?.isNotEmpty ?? false)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: food.allergens!
                                .map((allergen) => Chip(
                                      label: Text(allergen),
                                      backgroundColor: Colors.red.shade50,
                                      labelStyle: const TextStyle(color: Colors.red),
                                    ))
                                .toList(),
                          )
                        else
                          Text(
                            'No allergens reported',
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          _buildOrderBar(),
        ],
      ),
    );
  }

  Widget _buildHero(Food food) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
      ),
      child: food.image != null
          ? Image.network(food.image!, fit: BoxFit.cover)
          : const Icon(Icons.fastfood, size: 80, color: AppTheme.primaryColor),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }

  Widget _buildOrderBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _decrement,
                  ),
                  Text('$_quantity', style: AppTheme.heading3),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _increment,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total', style: AppTheme.bodySmall),
                  Text(
                    'ETB ${_total.toStringAsFixed(2)}',
                    style: AppTheme.heading3.copyWith(color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _handleOrder,
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Order Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoungeCard(Lounge lounge) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
          child: const Icon(Icons.restaurant, color: AppTheme.primaryColor),
        ),
        title: Text(lounge.name, style: AppTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lounge.description != null)
              Text(
                lounge.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            Text(
              lounge.opening != null && lounge.closing != null
                  ? '${lounge.opening} - ${lounge.closing}'
                  : 'Hours not available',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LoungeDetailsScreen(lounge: lounge),
            ),
          );
        },
      ),
    );
  }
}
