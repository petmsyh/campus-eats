import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/admin_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  final AdminService adminService;

  const AdminOrdersScreen({Key? key, required this.adminService}) : super(key: key);

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _selectedStatus;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() => _isLoading = true);
      final response = await widget.adminService.getOrders(
        status: _selectedStatus,
        page: _currentPage,
        limit: 20,
      );
      setState(() {
        _orders = response['data'];
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
              Expanded(child: Text('Orders Overview', style: AppTheme.heading2)),
              DropdownButton<String>(
                value: _selectedStatus,
                hint: const Text('All Status'),
                items: ['All', 'PENDING', 'PREPARING', 'READY', 'DELIVERED', 'CANCELLED'].map((status) {
                  return DropdownMenuItem(value: status == 'All' ? null : status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                  _loadOrders();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long, size: 64, color: AppTheme.primaryColor),
                          const SizedBox(height: 16),
                          Text('No orders found', style: AppTheme.heading3),
                          const SizedBox(height: 8),
                          Text(
                            'Orders will appear here',
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${order['id'].substring(0, 8)}', style: AppTheme.heading3),
                      Text(order['user']?['name'] ?? 'Unknown', style: AppTheme.bodyMedium),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Lounge: ${order['lounge']?['name'] ?? 'N/A'}', style: AppTheme.bodySmall),
            const SizedBox(height: 4),
            Text('Total: ETB ${order['totalPrice'].toStringAsFixed(2)}', style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'PREPARING':
        return Colors.blue;
      case 'READY':
        return Colors.green;
      case 'DELIVERED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
