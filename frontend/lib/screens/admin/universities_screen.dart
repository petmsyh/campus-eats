import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/admin_service.dart';

class AdminUniversitiesScreen extends StatefulWidget {
  final AdminService adminService;

  const AdminUniversitiesScreen({Key? key, required this.adminService}) : super(key: key);

  @override
  State<AdminUniversitiesScreen> createState() => _AdminUniversitiesScreenState();
}

class _AdminUniversitiesScreenState extends State<AdminUniversitiesScreen> {
  List<dynamic> _universities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      setState(() => _isLoading = true);
      final universities = await widget.adminService.getUniversities();
      setState(() {
        _universities = universities;
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
              Expanded(child: Text('Universities', style: AppTheme.heading2)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add University'),
                onPressed: _showAddDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadUniversities,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _universities.length,
                    itemBuilder: (context, index) {
                      final uni = _universities[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.school, color: AppTheme.primaryColor),
                          title: Text(uni['name']),
                          subtitle: Text('${uni['city']} - ${uni['code']}'),
                          trailing: Text('${uni['_count']?['users'] ?? 0} users'),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final cityController = TextEditingController();
    final regionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add University'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: regionController,
                decoration: const InputDecoration(labelText: 'Region'),
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
                await widget.adminService.createUniversity(
                  name: nameController.text,
                  code: codeController.text,
                  city: cityController.text,
                  region: regionController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('University created'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                  _loadUniversities();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
