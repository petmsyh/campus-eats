import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/reference_service.dart';
import '../../services/lounge_service.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService authService;
  final ReferenceService referenceService;
  final LoungeService loungeService;

  const RegisterScreen({
    Key? key,
    required this.authService,
    required this.referenceService,
    required this.loungeService,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isReferenceLoading = true;
  List<Map<String, dynamic>> _universities = [];
  List<Map<String, dynamic>> _campuses = [];
  String? _selectedUniversityId;
  String? _selectedCampusId;
  String _selectedRole = 'USER';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      final universities = await widget.referenceService.getUniversities();
      setState(() {
        _universities = universities
            .map((u) => Map<String, dynamic>.from(u as Map))
            .toList();
        _isReferenceLoading = false;
      });
    } catch (e) {
      setState(() => _isReferenceLoading = false);
      _showError('Failed to load universities. Please try again.');
    }
  }

  void _onUniversityChanged(String? universityId) {
    setState(() {
      _selectedUniversityId = universityId;
      _selectedCampusId = null;
      if (universityId == null) {
        _campuses = [];
        return;
      }

      final selected = _universities.firstWhere(
        (uni) => uni['id'] == universityId,
        orElse: () => <String, dynamic>{},
      );
      final campuses = selected['campuses'] as List<dynamic>?;
      _campuses = campuses != null
          ? campuses.map((c) => Map<String, dynamic>.from(c as Map)).toList()
          : [];
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    if (_selectedUniversityId == null) {
      _showError('Please select your university');
      return;
    }

    if (_selectedCampusId == null) {
      _showError('Please select your campus');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await widget.authService.register(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        universityId: _selectedUniversityId!,
        campusId: _selectedCampusId!,
        role: _selectedRole,
      );

      if (mounted) {
        if (response.success) {
          // Navigate to OTP verification
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                authService: widget.authService,
                loungeService: widget.loungeService,
                phone: _phoneController.text.trim(),
              ),
            ),
          );
        } else {
          _showError(response.message ?? 'Registration failed');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('An error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Register'),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isReferenceLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Role selection
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'USER',
                      child: Text('Student / User'),
                    ),
                    DropdownMenuItem(
                      value: 'LOUNGE',
                      child: Text('Lounge Owner'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedRole = value);
                  },
                ),
                const SizedBox(height: 16),
                // University selection
                DropdownButtonFormField<String>(
                  value: _selectedUniversityId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'University',
                    prefixIcon: Icon(Icons.school),
                  ),
                  items: _universities
                      .map(
                        (uni) => DropdownMenuItem(
                          value: uni['id'] as String?,
                          child: Text(uni['name'] ?? 'Unknown University'),
                        ),
                      )
                      .toList(),
                  onChanged: _onUniversityChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a university';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Campus selection
                DropdownButtonFormField<String>(
                  value: _selectedCampusId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Campus',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: _campuses
                      .map(
                        (campus) => DropdownMenuItem(
                          value: campus['id'] as String?,
                          child: Text(campus['name'] ?? 'Unknown Campus'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCampusId = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a campus';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Create Account',
                  style: AppTheme.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Campus Eats today',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'John Doe',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+251912345678',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!value.startsWith('+251')) {
                      return 'Phone number must start with +251';
                    }
                    if (value.length < 13) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    hintText: 'john@example.com',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Register'),
                ),
                const SizedBox(height: 16),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
