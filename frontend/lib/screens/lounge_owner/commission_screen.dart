import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/lounge_service.dart';

class LoungeCommissionScreen extends StatefulWidget {
  final LoungeService loungeService;

  const LoungeCommissionScreen({Key? key, required this.loungeService}) : super(key: key);

  @override
  State<LoungeCommissionScreen> createState() => _LoungeCommissionScreenState();
}

class _LoungeCommissionScreenState extends State<LoungeCommissionScreen> {
  List<dynamic> _commissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommissions();
  }

  Future<void> _loadCommissions() async {
    try {
      setState(() => _isLoading = true);
      final response = await widget.loungeService.getCommissions(limit: 50);
      setState(() {
        _commissions = response['data'];
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
          child: Text('Commission History', style: AppTheme.heading2),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _commissions.isEmpty
                  ? Center(child: Text('No commission records', style: AppTheme.heading3))
                  : RefreshIndicator(
                      onRefresh: _loadCommissions,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _commissions.length,
                        itemBuilder: (context, index) {
                          final commission = _commissions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.monetization_on, color: AppTheme.primaryColor),
                              title: Text('ETB ${commission['amount'].toStringAsFixed(2)}'),
                              subtitle: Text('Order Amount: ETB ${commission['orderAmount'].toStringAsFixed(2)}'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: commission['status'] == 'PAID' ? AppTheme.successColor : Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  commission['status'],
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
