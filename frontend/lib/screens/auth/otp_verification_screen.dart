import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../../services/lounge_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final AuthService authService;
  final String phone;
  final LoungeService? loungeService;

  const OTPVerificationScreen({
    Key? key,
    required this.authService,
    required this.phone,
    this.loungeService,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    AppConfig.otpLength,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    AppConfig.otpLength,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _canResend = false;
  int _countdown = AppConfig.otpResendDelay;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = AppConfig.otpResendDelay;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _handleVerifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != AppConfig.otpLength) {
      _showError('Please enter the complete OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await widget.authService.verifyOtp(
        phone: widget.phone,
        otp: otp,
      );

      if (mounted) {
        if (response.success) {
          final userData = response.data?['user'] as Map<String, dynamic>?;
          final role = userData?['role'] as String?;

          if (role == 'ADMIN') {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/admin-dashboard',
              (route) => false,
            );
            return;
          }

          if (role == 'LOUNGE' && widget.loungeService != null) {
            try {
              final lounge = await widget.loungeService!.getMyLounge();
              if (lounge == null) {
                _showInfo('Your lounge registration is pending admin approval. You will be notified once it is approved.');
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                return;
              }

              if (lounge['isApproved'] != true) {
                _showInfo('Your lounge has not been approved yet. Please wait for admin approval.');
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                return;
              }

              Navigator.of(context).pushNamedAndRemoveUntil(
                '/lounge-dashboard',
                (route) => false,
                arguments: {'loungeId': lounge['id']},
              );
              return;
            } catch (e) {
              _showError('Unable to load lounge details. Please try logging in again.');
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              return;
            }
          }

          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        } else {
          _showError(response.message ?? 'Invalid OTP');
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

  Future<void> _handleResendOTP() async {
    if (!_canResend) return;

    try {
      final response = await widget.authService.resendOtp(phone: widget.phone);

      if (mounted) {
        if (response.success) {
          _startCountdown();
          _showSuccess('OTP sent successfully');
        } else {
          _showError(response.message ?? 'Failed to resend OTP');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('An error occurred. Please try again.');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Icon
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Verification Code',
                style: AppTheme.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a code to ${widget.phone}',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  AppConfig.otpLength,
                  (index) => _buildOTPField(index),
                ),
              ),
              const SizedBox(height: 32),
              // Verify Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerifyOTP,
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
                    : const Text('Verify'),
              ),
              const SizedBox(height: 24),
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: AppTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _canResend ? _handleResendOTP : null,
                    child: Text(
                      _canResend ? 'Resend' : 'Resend in ${_countdown}s',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTheme.heading2,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < AppConfig.otpLength - 1) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          // Auto-submit when all fields are filled
          if (index == AppConfig.otpLength - 1 && value.isNotEmpty) {
            final allFilled = _controllers.every((c) => c.text.isNotEmpty);
            if (allFilled && !_isLoading) {
              _handleVerifyOTP();
            }
          }
        },
      ),
    );
  }
}
