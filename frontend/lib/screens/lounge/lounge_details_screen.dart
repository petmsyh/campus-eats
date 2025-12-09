import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/lounge.dart';
import '../../models/food.dart';

class LoungeDetailsScreen extends StatefulWidget {
  final Lounge lounge;

  const LoungeDetailsScreen({
    Key? key,
    required this.lounge,
  }) : super(key: key);

  @override
  State<LoungeDetailsScreen> createState() => _LoungeDetailsScreenState();
}

class _LoungeDetailsScreenState extends State<LoungeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Food> _foods = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'BREAKFAST',
    'LUNCH',
    'DINNER',
    'SNACKS',
    'DRINKS',
    'DESSERT',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFoods();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    // TODO: Implement API call to load foods
    setState(() {
      _isLoading = false;
      // Mock data for now
      _foods = [];
    });
  }

  List<Food> get _filteredFoods {
    if (_selectedCategory == 'All') return _foods;
    return _foods.where((f) => f.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.lounge.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          // Lounge Info
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildLoungeInfo(),
                _buildTabBar(),
              ],
            ),
          ),
          // Tab Content
          _tabController.index == 0
              ? _buildMenuTab()
              : _buildInfoTab(),
        ],
      ),
    );
  }

  Widget _buildLoungeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (widget.lounge.description != null)
            Text(
              widget.lounge.description!,
              style: AppTheme.bodyMedium,
            ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              _buildStat(
                Icons.star,
                widget.lounge.ratingAverage.toStringAsFixed(1),
                '${widget.lounge.ratingCount} ratings',
              ),
              const SizedBox(width: 24),
              _buildStat(
                Icons.access_time,
                '${widget.lounge.opening} - ${widget.lounge.closing}',
                'Opening hours',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTheme.heading3),
            Text(label, style: AppTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Menu'),
          Tab(text: 'Info'),
        ],
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primaryColor,
        onTap: (index) => setState(() {}),
      ),
    );
  }

  Widget _buildMenuTab() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        // Category Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              );
            },
          ),
        ),
        // Food Items
        if (_filteredFoods.isEmpty)
          _buildEmptyMenu()
        else
          ..._filteredFoods.map((food) => _buildFoodCard(food)),
      ]),
    );
  }

  Widget _buildEmptyMenu() {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Food Items',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for menu items',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Food food) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to food details or add to cart
          _showAddToCartDialog(food);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Food Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: food.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          food.image!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.fastfood,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
              ),
              const SizedBox(width: 16),
              // Food Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food.name, style: AppTheme.heading3),
                    const SizedBox(height: 4),
                    if (food.description != null)
                      Text(
                        food.description!,
                        style: AppTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'ETB ${food.price.toStringAsFixed(2)}',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (food.isVegetarian)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'VEG',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Add Button
              IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                color: AppTheme.primaryColor,
                onPressed: () => _showAddToCartDialog(food),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Operating Hours', style: AppTheme.heading3),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  widget.lounge.opening != null && widget.lounge.closing != null
                      ? '${widget.lounge.opening} - ${widget.lounge.closing}'
                      : widget.lounge.opening ?? widget.lounge.closing ?? 'Not provided',
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text('Banking Information', style: AppTheme.heading3),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.account_balance),
                title: Text(widget.lounge.bankName ?? 'Not provided'),
                subtitle: Text(widget.lounge.accountNumber ?? 'Not provided'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(widget.lounge.accountHolderName ?? 'Not provided'),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text('Rating', style: AppTheme.heading3),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    widget.lounge.ratingAverage.toStringAsFixed(1),
                    style: AppTheme.heading2,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${widget.lounge.ratingCount} ratings)',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  void _showAddToCartDialog(Food food) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(food.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ETB ${food.price.toStringAsFixed(2)} each'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: quantity > 1
                        ? () => setState(() => quantity--)
                        : null,
                  ),
                  Text(
                    quantity.toString(),
                    style: AppTheme.heading2,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => quantity++),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ETB ${(food.price * quantity).toStringAsFixed(2)}',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Add to cart
                Navigator.of(context).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Added $quantity x ${food.name} to cart'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
