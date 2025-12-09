import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../config/app_theme.dart';
import '../../services/lounge_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({
    Key? key,
    required this.loungeService,
  }) : super(key: key);

  final LoungeService loungeService;

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _isProcessing = false;
  String _statusMessage = 'Align the QR code within the frame';

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      final code = scanData.code;
      if (_isProcessing || code == null || code.isEmpty) return;
      _verifyCode(code.trim());
    });
  }

  Future<void> _verifyCode(String code) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Verifying code...';
    });
    await _controller?.pauseCamera();

    try {
      final response = await widget.loungeService.verifyQRCode(code);
      if (!mounted) return;
      final order = response['data'] as Map<String, dynamic>?;
      final message = response['message']?.toString() ?? 'Order verified successfully';

      final shouldExit = await _showResultSheet(
        success: true,
        message: message,
        order: order,
      );

      if (!mounted) return;
      if (shouldExit == true) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Align the QR code within the frame';
        });
        await _controller?.resumeCamera();
      }
    } catch (error) {
      if (!mounted) return;
      final message = _mapError(error);
      await _showResultSheet(success: false, message: message);
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Align the QR code within the frame';
      });
      await _controller?.resumeCamera();
    }
  }

  String _mapError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      return error.message ?? 'Failed to verify QR code';
    }
    return error.toString();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool granted) {
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission not granted'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<bool?> _showResultSheet({
    required bool success,
    required String message,
    Map<String, dynamic>? order,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: _VerificationResultContent(
              success: success,
              message: message,
              order: order,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isProcessing ? AppTheme.successColor : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Order QR'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                QRView(
                  key: _qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: borderColor,
                    borderRadius: 12,
                    borderLength: 32,
                    borderWidth: 8,
                    cutOutSize: MediaQuery.of(context).size.width * 0.7,
                  ),
                  onPermissionSet: (ctrl, granted) => _onPermissionSet(context, ctrl, granted),
                ),
                if (_isProcessing)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Text('Verifying...', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  'Make sure the QR code is clear and well-lit. This will automatically mark the order as delivered.',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      onPressed: () => _controller?.toggleFlash(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.cameraswitch, color: Colors.white),
                      onPressed: () => _controller?.flipCamera(),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationResultContent extends StatelessWidget {
  const _VerificationResultContent({
    required this.success,
    required this.message,
    this.order,
  });

  final bool success;
  final String message;
  final Map<String, dynamic>? order;

  @override
  Widget build(BuildContext context) {
    final iconColor = success ? AppTheme.successColor : AppTheme.errorColor;
    final title = success ? 'Order Verified' : 'Verification Failed';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error, color: iconColor, size: 32),
            const SizedBox(width: 12),
            Text(title, style: AppTheme.heading2),
          ],
        ),
        const SizedBox(height: 12),
        Text(message, style: AppTheme.bodyMedium),
        if (order != null) ...[
          const SizedBox(height: 16),
          _InfoRow(label: 'Order ID', value: order!['id']?.toString() ?? '-'),
          _InfoRow(label: 'Status', value: order!['status']?.toString() ?? '-'),
          if (order!['totalPrice'] != null)
            _InfoRow(label: 'Amount', value: 'ETB ${order!['totalPrice']}'),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(success ? 'Close Scanner' : 'Dismiss'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(success ? 'Scan another order' : 'Try again'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
