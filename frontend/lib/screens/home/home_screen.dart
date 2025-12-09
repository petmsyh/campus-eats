import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/food.dart';
import '../../models/lounge.dart';
import '../../services/api_client.dart';
import '../order/orders_screen.dart';
import '../order/cart_screen.dart';
import '../lounge/lounge_details_screen.dart';
import '../food/food_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiClient apiClient;

  const HomeScreen({Key? key, required this.apiClient}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Lounge> _lounges = [];
  List<Food> _foods = [];
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final profileResponse = await widget.apiClient.get('/users/profile');
      final profileData = Map<String, dynamic>.from(profileResponse['data'] as Map);

      final loungeQuery = <String, dynamic>{};
      final universityId = profileData['universityId'];
      final campusId = profileData['campusId'];
      if (universityId != null) loungeQuery['universityId'] = universityId;
      if (campusId != null) loungeQuery['campusId'] = campusId;

      final loungeResponse = await widget.apiClient.get(
        '/lounges',
        queryParams: loungeQuery.isEmpty ? null : loungeQuery,
      );

      final foodQuery = {
        'available': 'true',
      };
      if (campusId != null) {
        foodQuery['campusId'] = campusId;
      }

      final foodsResponse = await widget.apiClient.get(
        '/foods',
        queryParams: foodQuery,
      );

        final loungeList = (loungeResponse['data'] as List?) ?? [];
        final foodList = (foodsResponse['data'] as List?) ?? [];

        final lounges = loungeList
          .map((lounge) => Lounge.fromJson(Map<String, dynamic>.from(lounge as Map)))
          .toList();

        final foods = foodList
          .map((food) => Food.fromJson(Map<String, dynamic>.from(food as Map)))
          .toList();

      if (!mounted) return;
      setState(() {
        _profile = profileData;
        _lounges = lounges;
        _foods = foods;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load dashboard data.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load dashboard data. Please try again.\n$error'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  List<Lounge> get _visibleLounges {
    if (_searchQuery.isEmpty) {
      return _lounges;
    }

    final query = _searchQuery.toLowerCase();
    return _lounges.where((lounge) {
      final nameMatch = lounge.name.toLowerCase().contains(query);
      final descriptionMatch = (lounge.description ?? '').toLowerCase().contains(query);
      return nameMatch || descriptionMatch;
    }).toList();
  }

  Future<void> _handleRefresh() async {
    await _loadInitialData(showLoader: false);
  }

  Lounge? _findLoungeById(String loungeId) {
    try {
      return _lounges.firstWhere((lounge) => lounge.id == loungeId);
    } catch (_) {
      return null;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Eats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const OrdersScreen();
      case 2:
        return const CartScreen();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for lounges...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 24),
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Lounges', style: AppTheme.heading3),
              TextButton(
                onPressed: () {
                  // TODO: Show all lounges
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lounges List
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMessage!,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorColor),
              ),
            ),
          _visibleLounges.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: _visibleLounges
                      .map((lounge) => _buildLoungeCard(lounge))
                      .toList(),
                ),
          if (_foods.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Popular Dishes', style: AppTheme.heading3),
                TextButton(
                  onPressed: () async => _handleRefresh(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: _foods
                  .take(6)
                  .map((food) => _buildFoodCard(food))
                  .toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
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
              'No Lounges Available',
              style: AppTheme.heading3.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for available lounges',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoungeCard(Lounge lounge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoungeDetailsScreen(lounge: lounge),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lounge.name, style: AppTheme.heading3),
                    const SizedBox(height: 4),
                    Text(
                      lounge.description ?? 'Great food awaits',
                      style: AppTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          lounge.ratingAverage.toStringAsFixed(1),
                          style: AppTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${lounge.opening} - ${lounge.closing}',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodCard(Food food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          final lounge = _findLoungeById(food.loungeId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodDetailScreen(
                food: food,
                lounge: lounge,
              ),
            ),
          );
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fastfood, color: AppTheme.secondaryColor),
        ),
        title: Text(food.name, style: AppTheme.bodyLarge),
        subtitle: Text(
          food.description ?? 'Delicious campus meal',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('ETB ${food.price.toStringAsFixed(2)}', style: AppTheme.bodyMedium),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 2),
                Text(food.ratingAverage.toStringAsFixed(1), style: AppTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Remove the old placeholder tabs
  // Widget _buildOrdersTab() and _buildCartTab() are no longer needed

  Widget _buildProfileTab() {
    if (_isLoading && _profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = _profile;
    if (profile == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 12),
            Text('Unable to load profile information', style: AppTheme.bodyLarge),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    final walletBalance = (profile['walletBalance'] as num?)?.toDouble() ?? 0;
    final phone = profile['phone'] as String? ?? '';
    final email = profile['email'] as String?;
    final university = profile['university'] as Map<String, dynamic>?;
    final campus = profile['campus'] as Map<String, dynamic>?;
    final universityName = university?['name'] as String? ?? 'Not set';
    final campusName = campus?['name'] as String? ?? 'Not set';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile['name'] as String? ?? 'Campus Eats User', style: AppTheme.heading3),
                      const SizedBox(height: 4),
                      Text(phone, style: AppTheme.bodyMedium),
                      if (email != null) ...[
                        const SizedBox(height: 4),
                        Text(email, style: AppTheme.bodySmall),
                      ]
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _handleRefresh,
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          color: AppTheme.primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wallet Balance',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    const Icon(Icons.wallet, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ETB ${walletBalance.toStringAsFixed(2)}',
                  style: AppTheme.heading2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Add Money'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('University'),
                subtitle: Text(universityName),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Campus'),
                subtitle: Text(campusName),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildMenuItem(Icons.receipt_long, 'Order History', () {}),
        _buildMenuItem(Icons.card_membership, 'My Contracts', () {}),
        _buildMenuItem(Icons.settings, 'Settings', () {}),
        _buildMenuItem(Icons.help_outline, 'Help & Support', () {}),
        _buildMenuItem(Icons.info_outline, 'About', () {}),
        const SizedBox(height: 16),
        _buildMenuItem(
          Icons.logout,
          'Logout',
          () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          color: AppTheme.errorColor,
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppTheme.primaryColor),
        title: Text(
          title,
          style: AppTheme.bodyLarge.copyWith(color: color),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
