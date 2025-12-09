import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/lounge_service.dart';

class LoungeOrdersScreen extends StatefulWidget {
  final LoungeService loungeService;
  final String loungeId;

  const LoungeOrdersScreen({Key? key, required this.loungeService, required this.loungeId}) : super(key: key);

  @override
  State<LoungeOrdersScreen> createState() => _LoungeOrdersScreenState();
}

class _LoungeOrdersScreenState extends State<LoungeOrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _selectedStatus = 'PENDING';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() => _isLoading = true);
      final response = await widget.loungeService.getOrders(status: _selectedStatus, limit: 50);
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

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await widget.loungeService.updateOrderStatus(orderId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $status'), backgroundColor: AppTheme.successColor),
      );
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['PENDING', 'PREPARING', 'READY', 'DELIVERED'].map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedStatus = status);
                        _loadOrders();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? Center(child: Text('No $_selectedStatus orders', style: AppTheme.heading3))
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
                Text('ETB ${order['totalPrice'].toStringAsFixed(2)}', style: AppTheme.heading3.copyWith(color: AppTheme.primaryColor)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(order),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(Map<String, dynamic> order) {
    final status = order['status'];
    if (status == 'PENDING') {
      return [
        ElevatedButton(
          onPressed: () => _updateOrderStatus(order['id'], 'PREPARING'),
          child: const Text('Start Preparing'),
        ),
      ];
    } else if (status == 'PREPARING') {
      return [
        ElevatedButton(
          onPressed: () => _updateOrderStatus(order['id'], 'READY'),
          child: const Text('Mark Ready'),
        ),
      ];
    } else if (status == 'READY') {
      return [
        ElevatedButton(
          onPressed: () => _updateOrderStatus(order['id'], 'DELIVERED'),
          child: const Text('Mark Delivered'),
        ),
      ];
    }
    return [];
  }
}
