import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/lounge_service.dart';
import 'orders_screen.dart';
import 'menu_screen.dart';
import 'commission_screen.dart';
import 'qr_scanner_screen.dart';

class LoungeDashboardScreen extends StatefulWidget {
  final LoungeService loungeService;
  final String loungeId;

  const LoungeDashboardScreen({
    Key? key,
    required this.loungeService,
    required this.loungeId,
  }) : super(key: key);

  @override
  State<LoungeDashboardScreen> createState() => _LoungeDashboardScreenState();
}

class _LoungeDashboardScreenState extends State<LoungeDashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _loungeProfile;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isEditingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      setState(() => _isLoading = true);
      final profile = await widget.loungeService.getLoungeProfile(widget.loungeId);
      final ordersResponse = await widget.loungeService.getOrders(limit: 100);
      final orders = ordersResponse['data'] as List;

      final pending = orders.where((o) => o['status'] == 'PENDING').length;
      final preparing = orders.where((o) => o['status'] == 'PREPARING').length;
      final ready = orders.where((o) => o['status'] == 'READY').length;
      final delivered = orders.where((o) => o['status'] == 'DELIVERED').length;

      double totalRevenue = 0;
      for (final order in orders) {
        if (order['status'] == 'DELIVERED') {
          totalRevenue += (order['totalPrice'] ?? 0).toDouble();
        }
      }

      final commissionStats = await widget.loungeService.getCommissionStats();

      setState(() {
        _stats = {
          'pendingOrders': pending,
          'preparingOrders': preparing,
          'readyOrders': ready,
          'totalOrders': orders.length,
          'deliveredOrders': delivered,
          'totalRevenue': totalRevenue,
          'totalCommission': commissionStats['total'],
          'pendingCommission': commissionStats['pending'],
        };
        _loungeProfile = profile;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading stats: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  int get _bottomNavIndex {
    switch (_selectedIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 2;
      case 4:
        return 3;
      default:
        return 0;
    }
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        _onItemTapped(0);
        break;
      case 1:
        _onItemTapped(1);
        break;
      case 2:
        _onItemTapped(2);
        break;
      case 3:
        _onItemTapped(4);
        break;
    }
  }

  Future<void> _openQRScanner() async {
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QRScannerScreen(loungeService: widget.loungeService),
      ),
    );
    if (verified == true && mounted) {
      await _loadStats();
    }
  }

  Future<void> _openEditProfileSheet() async {
    if (_isEditingProfile) return;
    final profile = _loungeProfile;
    if (profile == null) return;

    if (mounted) {
      setState(() => _isEditingProfile = true);
    } else {
      _isEditingProfile = true;
    }

    try {
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (_) => FractionallySizedBox(
          heightFactor: 0.95,
          child: _LoungeProfileEditSheet(
            profile: Map<String, dynamic>.from(profile),
            loungeService: widget.loungeService,
            loungeId: widget.loungeId,
          ),
        ),
      );

      if (result == true) {
        if (!mounted) return;
        await _loadStats();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lounge profile updated successfully')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isEditingProfile = false);
      } else {
        _isEditingProfile = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lounge Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _openQRScanner,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.restaurant, size: 35, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 10),
                Text('Lounge Panel', style: AppTheme.heading3.copyWith(color: Colors.white)),
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
            leading: const Icon(Icons.receipt_long),
            title: const Text('Orders'),
            selected: _selectedIndex == 1,
            onTap: () {
              _onItemTapped(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Menu'),
            selected: _selectedIndex == 2,
            onTap: () {
              _onItemTapped(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Commission'),
            selected: _selectedIndex == 3,
            onTap: () {
              _onItemTapped(3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            selected: _selectedIndex == 4,
            onTap: () {
              _onItemTapped(4);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return LoungeOrdersScreen(loungeService: widget.loungeService, loungeId: widget.loungeId);
      case 2:
        return LoungeMenuScreen(loungeService: widget.loungeService, loungeId: widget.loungeId);
      case 3:
        return LoungeCommissionScreen(loungeService: widget.loungeService);
      case 4:
        return _buildProfileTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text('Failed to load statistics', style: AppTheme.heading3),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadStats, child: const Text('Retry')),
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
            Text('Revenue & Commission', style: AppTheme.heading2),
            const SizedBox(height: 16),
            _buildRevenueCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    if (_isLoading && _loungeProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loungeProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(_errorMessage ?? 'Failed to load lounge profile', style: AppTheme.heading3, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadStats, child: const Text('Retry')),
          ],
        ),
      );
    }

    final profile = _loungeProfile!;
    final bankAccountRaw = profile['bankAccount'];
    final legacyBankAccount = bankAccountRaw is Map
        ? Map<String, dynamic>.from(bankAccountRaw as Map)
        : <String, dynamic>{};
    final bankAccounts = _asMapList(profile['bankAccounts']);
    if (bankAccounts.isEmpty && legacyBankAccount.isNotEmpty) {
      bankAccounts.add(Map<String, dynamic>.from(legacyBankAccount));
    }
    final wallets = _asMapList(profile['wallets']);
    final operatingRaw = profile['operatingHours'];
    final operatingHours = operatingRaw is Map
        ? Map<String, dynamic>.from(operatingRaw as Map)
        : <String, dynamic>{};
    final universityData = profile['university'];
    final university = universityData is Map ? Map<String, dynamic>.from(universityData as Map) : null;
    final campusData = profile['campus'];
    final campus = campusData is Map ? Map<String, dynamic>.from(campusData as Map) : null;
    final logoUrl = profile['logo']?.toString();

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (logoUrl == null || logoUrl.isEmpty)
                            ? const Icon(Icons.restaurant, color: AppTheme.primaryColor, size: 30)
                            : Image.network(
                                logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.restaurant,
                                  color: AppTheme.primaryColor,
                                  size: 30,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile['name'] ?? 'Lounge', style: AppTheme.heading2),
                            const SizedBox(height: 8),
                            Text(
                              profile['description'] ?? 'No description provided',
                              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (logoUrl == null || logoUrl.isEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Add a logo to make your lounge more recognizable. Use the Edit Profile button below to save a logo URL.',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusChip('Approved', profile['isApproved'] == true),
                      _buildStatusChip('Active', profile['isActive'] == true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _openEditProfileSheet,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Location',
            rows: [
              _buildInfoRow('University', university?['name']?.toString() ?? 'N/A'),
              _buildInfoRow('Campus', campus?['name']?.toString() ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Operating Hours',
            rows: [
              _buildInfoRow('Opening', operatingHours['opening']?.toString() ?? '--'),
              _buildInfoRow('Closing', operatingHours['closing']?.toString() ?? '--'),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Bank Accounts',
            rows: [
              if (bankAccounts.isEmpty)
                Text(
                  'No bank accounts added yet',
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                )
              else
                ...bankAccounts.asMap().entries.map((entry) {
                  final account = entry.value;
                  final index = entry.key;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index > 0) const Divider(),
                      Text(
                        'Account ${index + 1}',
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow('Account Holder', (account['accountHolderName'] ?? 'N/A').toString()),
                      _buildInfoRow('Bank Name', (account['bankName'] ?? 'N/A').toString()),
                      _buildInfoRow('Account Number', (account['accountNumber'] ?? 'N/A').toString()),
                    ],
                  );
                }),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Wallets & Mobile Money',
            rows: [
              if (wallets.isEmpty)
                Text(
                  'Add Telebirr or other wallet details to receive digital payments',
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                )
              else
                ...wallets.asMap().entries.map((entry) {
                  final wallet = entry.value;
                  final index = entry.key;
                  final instructions = (wallet['instructions'] ?? '').toString();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index > 0) const Divider(),
                      Text(
                        'Wallet ${index + 1}',
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow('Provider', (wallet['provider'] ?? 'N/A').toString()),
                      _buildInfoRow(
                        'Phone / ID',
                        (wallet['phoneNumber'] ?? wallet['accountNumber'] ?? 'N/A').toString(),
                      ),
                      if ((wallet['accountHolderName'] ?? '').toString().isNotEmpty)
                        _buildInfoRow('Account Holder', wallet['accountHolderName'].toString()),
                      if (instructions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Instructions', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                              const SizedBox(height: 4),
                              Text(instructions, style: AppTheme.bodyLarge),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
              ),
              onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> rows}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.heading3),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _asMapList(dynamic source) {
    if (source is List) {
      return source
          .where((element) => element is Map)
          .map((element) => Map<String, dynamic>.from(element as Map))
          .toList();
    }
    return [];
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive) {
    return Chip(
      avatar: Icon(
        isActive ? Icons.check_circle : Icons.cancel,
        color: isActive ? Colors.green : AppTheme.errorColor,
        size: 18,
      ),
      label: Text(label),
      backgroundColor: isActive ? Colors.green.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isActive ? Colors.green.shade800 : AppTheme.errorColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'Pending',
        'value': _stats!['pendingOrders'].toString(),
        'icon': Icons.pending_actions,
        'color': Colors.orange,
      },
      {
        'title': 'Preparing',
        'value': _stats!['preparingOrders'].toString(),
        'icon': Icons.restaurant,
        'color': Colors.blue,
      },
      {
        'title': 'Ready',
        'value': _stats!['readyOrders'].toString(),
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'Delivered',
        'value': _stats!['deliveredOrders'].toString(),
        'icon': Icons.done_all,
        'color': Colors.teal,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const spacing = 16.0;
        final totalSpacing = spacing * (crossAxisCount - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
        const itemHeight = 160.0;
        final childAspectRatio = itemWidth / itemHeight;

        return GridView.builder(
          itemCount: stats.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              stat['title'] as String,
              stat['value'] as String,
              stat['icon'] as IconData,
              stat['color'] as Color,
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.heading2.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(title, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard() {
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
                Text('Financial Overview', style: AppTheme.heading3.copyWith(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
            _buildRevenueItem('Total Revenue', 'ETB ${_stats!['totalRevenue'].toStringAsFixed(2)}'),
            const Divider(color: Colors.white30, height: 24),
            _buildRevenueItem('Total Commission', 'ETB ${_stats!['totalCommission'].toStringAsFixed(2)}'),
            const Divider(color: Colors.white30, height: 24),
            _buildRevenueItem('Pending Commission', 'ETB ${_stats!['pendingCommission'].toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyLarge.copyWith(color: Colors.white70)),
        Text(value, style: AppTheme.heading3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _LoungeProfileEditSheet extends StatefulWidget {
  const _LoungeProfileEditSheet({
    required this.profile,
    required this.loungeService,
    required this.loungeId,
  });

  final Map<String, dynamic> profile;
  final LoungeService loungeService;
  final String loungeId;

  @override
  State<_LoungeProfileEditSheet> createState() => _LoungeProfileEditSheetState();
}

class _LoungeProfileEditSheetState extends State<_LoungeProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _logoController;
  late TextEditingController _openingController;
  late TextEditingController _closingController;
  late List<_BankAccountFieldSet> _bankAccountFields;
  late List<_WalletFieldSet> _walletFields;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    final bankAccountRaw = profile['bankAccount'];
    final legacyBankAccount = bankAccountRaw is Map
        ? Map<String, dynamic>.from(bankAccountRaw as Map)
        : <String, dynamic>{};
    final operatingRaw = profile['operatingHours'];
    final operatingHours = operatingRaw is Map
        ? Map<String, dynamic>.from(operatingRaw as Map)
        : <String, dynamic>{};

    final existingBankAccounts = _asMapList(profile['bankAccounts']);
    if (existingBankAccounts.isEmpty && legacyBankAccount.isNotEmpty) {
      existingBankAccounts.add(Map<String, dynamic>.from(legacyBankAccount));
    }
    final existingWallets = _asMapList(profile['wallets']);

    _nameController = TextEditingController(text: profile['name']?.toString() ?? '');
    _descriptionController = TextEditingController(text: profile['description']?.toString() ?? '');
    _logoController = TextEditingController(text: profile['logo']?.toString() ?? '');
    _openingController = TextEditingController(text: operatingHours['opening']?.toString() ?? '');
    _closingController = TextEditingController(text: operatingHours['closing']?.toString() ?? '');

    _bankAccountFields = existingBankAccounts.isEmpty
        ? [_BankAccountFieldSet()]
        : existingBankAccounts
            .map(
              (account) => _BankAccountFieldSet(
                accountHolderName: account['accountHolderName']?.toString(),
                bankName: account['bankName']?.toString(),
                accountNumber: account['accountNumber']?.toString(),
              ),
            )
            .toList();

    _walletFields = existingWallets.isEmpty
        ? [_WalletFieldSet()]
        : existingWallets
            .map(
              (wallet) => _WalletFieldSet(
                provider: wallet['provider']?.toString(),
                phoneNumber: (wallet['phoneNumber'] ?? wallet['accountNumber'])?.toString(),
                accountHolderName: wallet['accountHolderName']?.toString(),
                walletId: wallet['accountNumber']?.toString(),
                instructions: wallet['instructions']?.toString(),
              ),
            )
            .toList();
  }

  static List<Map<String, dynamic>> _asMapList(dynamic source) {
    if (source is List) {
      return source
          .where((element) => element is Map)
          .map((element) => Map<String, dynamic>.from(element as Map))
          .toList();
    }
    return [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _logoController.dispose();
    _openingController.dispose();
    _closingController.dispose();
    for (final field in _bankAccountFields) {
      field.dispose();
    }
    for (final field in _walletFields) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final logo = _logoController.text.trim();
    final opening = _openingController.text.trim();
    final closing = _closingController.text.trim();

    final bankPayloads = _bankAccountFields
        .map((field) => field.buildPayload())
        .whereType<Map<String, String>>()
        .toList();
    final walletPayloads = _walletFields
        .map((field) => field.buildPayload())
        .whereType<Map<String, String>>()
        .toList();
    final bankPayload = bankPayloads.isNotEmpty ? bankPayloads.first : null;
    final bankAccountsPayload = bankPayloads.isNotEmpty ? bankPayloads : null;
    final walletsPayload = walletPayloads.isNotEmpty ? walletPayloads : null;

    final operatingPayload = <String, String>{};
    if (opening.isNotEmpty) operatingPayload['opening'] = opening;
    if (closing.isNotEmpty) operatingPayload['closing'] = closing;

    try {
      await widget.loungeService.updateLounge(
        loungeId: widget.loungeId,
        name: name,
        description: description.isEmpty ? null : description,
        logo: logo.isEmpty ? null : logo,
        bankAccount: bankPayload,
        bankAccounts: bankAccountsPayload,
        wallets: walletsPayload,
        operatingHours: operatingPayload.isEmpty ? null : operatingPayload,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update lounge: $error'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edit Lounge Profile', style: AppTheme.heading3),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Lounge Name',
                    prefixIcon: Icon(Icons.store),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _logoController,
                  decoration: const InputDecoration(
                    labelText: 'Logo URL',
                    prefixIcon: Icon(Icons.image_outlined),
                    helperText: 'Provide a publicly accessible image URL',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _openingController,
                        decoration: const InputDecoration(
                          labelText: 'Opening Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _closingController,
                        decoration: const InputDecoration(
                          labelText: 'Closing Time',
                          prefixIcon: Icon(Icons.access_time_filled),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Bank Accounts', style: AppTheme.heading3),
                const SizedBox(height: 8),
                ..._bankAccountFields.asMap().entries.map((entry) {
                  final index = entry.key;
                  final fieldSet = entry.value;
                  return Card(
                    key: ValueKey(fieldSet.id),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Account ${index + 1}', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                              if (_bankAccountFields.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                                  onPressed: () {
                                    setState(() {
                                      final removed = _bankAccountFields.removeAt(index);
                                      removed.dispose();
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: fieldSet.accountHolderController,
                            decoration: const InputDecoration(
                              labelText: 'Account Holder Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: fieldSet.bankNameController,
                            decoration: const InputDecoration(
                              labelText: 'Bank Name',
                              prefixIcon: Icon(Icons.account_balance),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: fieldSet.accountNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Account Number',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _bankAccountFields.add(_BankAccountFieldSet());
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Bank Account'),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Wallets & Mobile Money', style: AppTheme.heading3),
                const SizedBox(height: 8),
                ..._walletFields.asMap().entries.map((entry) {
                  final index = entry.key;
                  final fieldSet = entry.value;
                  return Card(
                    key: ValueKey(fieldSet.id),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Wallet ${index + 1}', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                              if (_walletFields.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                                  onPressed: () {
                                    setState(() {
                                      final removed = _walletFields.removeAt(index);
                                      removed.dispose();
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: fieldSet.providerController,
                            decoration: const InputDecoration(
                              labelText: 'Provider (e.g., Telebirr)',
                              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: fieldSet.phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_iphone),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: fieldSet.walletIdController,
                            decoration: const InputDecoration(
                              labelText: 'Wallet / Account ID (optional)',
                              prefixIcon: Icon(Icons.confirmation_number_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: fieldSet.accountHolderController,
                            decoration: const InputDecoration(
                              labelText: 'Account Holder Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: fieldSet.instructionsController,
                            decoration: const InputDecoration(
                              labelText: 'Payment Instructions',
                              prefixIcon: Icon(Icons.notes_outlined),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _walletFields.add(_WalletFieldSet());
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Wallet'),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                    onPressed: _isSaving ? null : _handleSave,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BankAccountFieldSet {
  _BankAccountFieldSet({
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
  })  : id = UniqueKey().toString(),
        accountHolderController = TextEditingController(text: accountHolderName ?? ''),
        bankNameController = TextEditingController(text: bankName ?? ''),
        accountNumberController = TextEditingController(text: accountNumber ?? '');

  final String id;
  final TextEditingController accountHolderController;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;

  Map<String, String>? buildPayload() {
    final holder = accountHolderController.text.trim();
    final bank = bankNameController.text.trim();
    final number = accountNumberController.text.trim();
    if (holder.isEmpty && bank.isEmpty && number.isEmpty) return null;
    return {
      if (holder.isNotEmpty) 'accountHolderName': holder,
      if (bank.isNotEmpty) 'bankName': bank,
      if (number.isNotEmpty) 'accountNumber': number,
    };
  }

  void dispose() {
    accountHolderController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
  }
}

class _WalletFieldSet {
  _WalletFieldSet({
    String? provider,
    String? phoneNumber,
    String? walletId,
    String? accountHolderName,
    String? instructions,
  })  : id = UniqueKey().toString(),
        providerController = TextEditingController(text: provider ?? ''),
        phoneController = TextEditingController(text: phoneNumber ?? ''),
        walletIdController = TextEditingController(text: walletId ?? ''),
        accountHolderController = TextEditingController(text: accountHolderName ?? ''),
        instructionsController = TextEditingController(text: instructions ?? '');

  final String id;
  final TextEditingController providerController;
  final TextEditingController phoneController;
  final TextEditingController walletIdController;
  final TextEditingController accountHolderController;
  final TextEditingController instructionsController;

  Map<String, String>? buildPayload() {
    final provider = providerController.text.trim();
    final phone = phoneController.text.trim();
    final walletId = walletIdController.text.trim();
    final holder = accountHolderController.text.trim();
    final instructions = instructionsController.text.trim();
    if (provider.isEmpty && phone.isEmpty && walletId.isEmpty && holder.isEmpty && instructions.isEmpty) {
      return null;
    }
    return {
      if (provider.isNotEmpty) 'provider': provider,
      if (phone.isNotEmpty) 'phoneNumber': phone,
      if (walletId.isNotEmpty) 'accountNumber': walletId,
      if (holder.isNotEmpty) 'accountHolderName': holder,
      if (instructions.isNotEmpty) 'instructions': instructions,
      'type': 'MOBILE_WALLET',
    };
  }

  void dispose() {
    providerController.dispose();
    phoneController.dispose();
    walletIdController.dispose();
    accountHolderController.dispose();
    instructionsController.dispose();
  }
}
