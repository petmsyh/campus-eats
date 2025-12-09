import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/admin_service.dart';
import 'users_screen.dart';
import 'lounges_screen.dart';
import 'universities_screen.dart';
import 'orders_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AdminService adminService;

  const AdminDashboardScreen({
    Key? key,
    required this.adminService,
  }) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      setState(() => _isLoading = true);
      final stats = await widget.adminService.getStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading stats: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
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
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 35,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Admin Panel',
                    style: AppTheme.heading3.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('Lounges'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Universities'),
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Orders'),
              selected: _selectedIndex == 4,
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return AdminUsersScreen(adminService: widget.adminService);
      case 2:
        return AdminLoungesScreen(adminService: widget.adminService);
      case 3:
        return AdminUniversitiesScreen(adminService: widget.adminService);
      case 4:
        return AdminOrdersScreen(adminService: widget.adminService);
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text('Failed to load statistics', style: AppTheme.heading3),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: AppTheme.heading2),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            Text('Revenue', style: AppTheme.heading2),
            const SizedBox(height: 16),
            _buildRevenueCard(),
            const SizedBox(height: 24),
            Text('Quick Actions', style: AppTheme.heading2),
            const SizedBox(height: 16),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Users',
          _stats!['users'].toString(),
          Icons.people,
          AppTheme.primaryColor,
        ),
        _buildStatCard(
          'Lounges',
          _stats!['lounges'].toString(),
          Icons.restaurant,
          Colors.orange,
        ),
        _buildStatCard(
          'Total Orders',
          _stats!['orders'].toString(),
          Icons.receipt_long,
          Colors.green,
        ),
        _buildStatCard(
          'Active Orders',
          _stats!['activeOrders'].toString(),
          Icons.schedule,
          Colors.blue,
        ),
        _buildStatCard(
          'Universities',
          _stats!['universities'].toString(),
          Icons.school,
          Colors.purple,
        ),
        _buildStatCard(
          'Campuses',
          _stats!['campuses'].toString(),
          Icons.location_city,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.heading2.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard() {
    final revenue = _stats!['revenue'];
    return Card(
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Revenue Overview',
                  style: AppTheme.heading3.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildRevenueItem(
              'Total Revenue',
              'ETB ${revenue['totalRevenue'].toStringAsFixed(2)}',
            ),
            const Divider(color: Colors.white30, height: 24),
            _buildRevenueItem(
              'Total Commission',
              'ETB ${revenue['totalCommission'].toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyLarge.copyWith(color: Colors.white70),
        ),
        Text(
          value,
          style: AppTheme.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionCard(
          'Pending Lounge Approvals',
          _stats!['pendingLounges'].toString(),
          Icons.pending_actions,
          Colors.orange,
          () => _onItemTapped(2),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Active Orders',
          _stats!['activeOrders'].toString(),
          Icons.local_shipping,
          Colors.blue,
          () => _onItemTapped(4),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String count,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text(
                      '$count pending',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
