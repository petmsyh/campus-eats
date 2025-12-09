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
  final Map<String, List<dynamic>> _campusesByUniversity = {};
  final Set<String> _campusLoading = <String>{};
  final Map<String, String?> _campusErrors = {};

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      setState(() => _isLoading = true);
      final universities = await widget.adminService.getUniversities();
      if (!mounted) return;
      setState(() {
        _universities = universities;
        final validIds = universities
            .map<String>((uni) => uni['id'] as String)
            .toSet();
        _campusesByUniversity.removeWhere((key, _) => !validIds.contains(key));
        _campusErrors.removeWhere((key, _) => !validIds.contains(key));
        _campusLoading.removeWhere((key) => !validIds.contains(key));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
                      final universityId = uni['id'] as String;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          key: PageStorageKey(universityId),
                          leading: const Icon(Icons.school, color: AppTheme.primaryColor),
                          title: Text(uni['name'] ?? 'University'),
                          subtitle: Text('${uni['city'] ?? 'Unknown City'} - ${uni['code'] ?? ''}'),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildCountBadge('Users', uni['_count']?['users'] ?? 0),
                              const SizedBox(height: 4),
                              _buildCountBadge('Campuses', uni['_count']?['campuses'] ?? 0),
                            ],
                          ),
                          onExpansionChanged: (expanded) {
                            if (expanded) {
                              _maybeLoadCampuses(universityId);
                            }
                          },
                          children: [
                            const Divider(height: 1),
                            _buildCampusSection(uni),
                          ],
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

  void _maybeLoadCampuses(String universityId) {
    if (_campusesByUniversity.containsKey(universityId) || _campusLoading.contains(universityId)) {
      return;
    }
    _fetchCampuses(universityId);
  }

  Future<void> _fetchCampuses(String universityId) async {
    setState(() {
      _campusLoading.add(universityId);
      _campusErrors.remove(universityId);
    });
    try {
      final campuses = await widget.adminService.getCampuses(universityId: universityId);
      if (!mounted) return;
      setState(() {
        _campusesByUniversity[universityId] = List<dynamic>.from(campuses);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _campusErrors[universityId] = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _campusLoading.remove(universityId);
      });
    }
  }

  void _showAddCampusDialog(Map<String, dynamic> university) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => _AddCampusDialog(
        university: university,
        adminService: widget.adminService,
        onCampusCreated: (campus) {
          _handleCampusCreated(university['id'] as String, campus);
        },
      ),
    ).then((created) {
      if (created == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campus added successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    });
  }

  void _handleCampusCreated(String universityId, dynamic campus) {
    setState(() {
      final currentCampuses = List<dynamic>.from(_campusesByUniversity[universityId] ?? []);
      currentCampuses.add(campus);
      currentCampuses.sort((a, b) =>
          (a['name'] ?? '').toString().toLowerCase().compareTo((b['name'] ?? '').toString().toLowerCase()));
      _campusesByUniversity[universityId] = currentCampuses;

      final updatedUniversities = List<dynamic>.from(_universities);
      final index = updatedUniversities.indexWhere((uni) => uni['id'] == universityId);
      if (index != -1) {
        final updated = Map<String, dynamic>.from(updatedUniversities[index] as Map);
        final dynamic existingCount = updated['_count'];
        final countMap = existingCount is Map
            ? Map<String, dynamic>.from(existingCount as Map)
            : <String, dynamic>{};
        countMap['campuses'] = (countMap['campuses'] ?? 0) + 1;
        updated['_count'] = countMap;
        updatedUniversities[index] = updated;
        _universities = updatedUniversities;
      }
    });
  }

  Widget _buildCampusSection(Map<String, dynamic> university) {
    final universityId = university['id'] as String;
    final campuses = _campusesByUniversity[universityId];
    final isLoading = _campusLoading.contains(universityId);
    final error = _campusErrors[universityId];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip(Icons.groups, '${university['_count']?['users'] ?? 0} Users'),
              _buildStatChip(Icons.maps_home_work, '${university['_count']?['campuses'] ?? 0} Campuses'),
              _buildStatChip(Icons.restaurant, '${university['_count']?['lounges'] ?? 0} Lounges'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Add Campus'),
                onPressed: () => _showAddCampusDialog(university),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Campuses'),
                onPressed: () => _fetchCampuses(universityId),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else if (error != null)
            Text('Failed to load campuses: $error', style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorColor))
          else if (campuses == null)
            Text('Expand to load campuses for this university.', style: AppTheme.bodyMedium)
          else if (campuses.isEmpty)
            Text('No campuses added yet. Use the button above to create one.', style: AppTheme.bodyMedium)
          else
            ListView.separated(
              key: PageStorageKey('campus-list-$universityId'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: campuses.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final campus = campuses[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_city, color: AppTheme.primaryColor),
                  title: Text(campus['name'] ?? 'Campus'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((campus['address'] ?? '').toString().isNotEmpty)
                        Text(campus['address'].toString()),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildStatChip(Icons.groups, '${campus['_count']?['users'] ?? 0} Users'),
                          _buildStatChip(Icons.restaurant, '${campus['_count']?['lounges'] ?? 0} Lounges'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$count $label', style: AppTheme.bodySmall),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppTheme.primaryColor),
      label: Text(label),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
      labelStyle: AppTheme.bodySmall,
    );
  }
}

class _AddCampusDialog extends StatefulWidget {
  const _AddCampusDialog({
    Key? key,
    required this.university,
    required this.adminService,
    required this.onCampusCreated,
  }) : super(key: key);

  final Map<String, dynamic> university;
  final AdminService adminService;
  final void Function(dynamic campus) onCampusCreated;

  @override
  State<_AddCampusDialog> createState() => _AddCampusDialogState();
}

class _AddCampusDialogState extends State<_AddCampusDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final response = await widget.adminService.createCampus(
        name: _nameController.text.trim(),
        universityId: widget.university['id'] as String,
        address: _addressController.text.trim(),
      );
      widget.onCampusCreated(response['data']);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add campus: $error'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Campus – ${widget.university['name']}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Campus Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Campus name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address / Description'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save),
          label: Text(_isSubmitting ? 'Saving...' : 'Save'),
          onPressed: _isSubmitting ? null : _submit,
        ),
      ],
    );
  }
}
