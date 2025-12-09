import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/admin_service.dart';

class AdminLoungesScreen extends StatefulWidget {
  final AdminService adminService;

  const AdminLoungesScreen({Key? key, required this.adminService}) : super(key: key);

  @override
  State<AdminLoungesScreen> createState() => _AdminLoungesScreenState();
}

class _AdminLoungesScreenState extends State<AdminLoungesScreen> {
  List<dynamic> _lounges = [];
  bool _isLoading = true;
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _loadLounges();
  }

  Future<void> _loadLounges() async {
    try {
      setState(() => _isLoading = true);
      final response = await widget.adminService.getLounges(
        status: _selectedStatus,
        page: 1,
        limit: 50,
      );
      setState(() {
        _lounges = response['data'];
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

  Future<void> _approveLounge(String loungeId, bool isApproved) async {
    try {
      await widget.adminService.approveLounge(loungeId, isApproved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lounge ${isApproved ? 'approved' : 'rejected'}'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      _loadLounges();
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
          child: Row(
            children: [
              Expanded(child: Text('Lounges', style: AppTheme.heading2)),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'pending', label: Text('Pending')),
                  ButtonSegment(value: 'approved', label: Text('Approved')),
                ],
                selected: {_selectedStatus},
                onSelectionChanged: (Set<String> selection) {
                  setState(() => _selectedStatus = selection.first);
                  _loadLounges();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadLounges,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _lounges.length,
                    itemBuilder: (context, index) => _buildLoungeCard(_lounges[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLoungeCard(Map<String, dynamic> lounge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, size: 40, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lounge['name'], style: AppTheme.heading3),
                      Text(lounge['owner']?['name'] ?? 'Unknown', style: AppTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (lounge['description'] != null)
              Text(lounge['description'], style: AppTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.school, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(lounge['university']?['name'] ?? 'N/A', style: AppTheme.bodySmall),
              ],
            ),
            if (_selectedStatus == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
                    onPressed: () => _approveLounge(lounge['id'], false),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    onPressed: () => _approveLounge(lounge['id'], true),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
