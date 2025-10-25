import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import '../../../data/services/paypal_config_service.dart';

/// PayPal Payment Provider
/// Handles PayPal payment processing and integration
class PayPalPaymentProvider extends ChangeNotifier {
  bool _isProcessing = false;
  String? _error;
  String? _currentUserId;

  // Getters
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  /// Set current user ID for payment processing
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  /// Process PayPal payment
  Future<bool> processPayment({
    required String amount,
    required String currency,
    required String description,
    required BuildContext context,
  }) async {
    if (!PayPalConfigService.isConfigured) {
      _error = 'PayPal chưa được cấu hình';
      notifyListeners();
      return false;
    }

    if (_currentUserId == null) {
      _error = 'User ID không được xác định';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      // Launch PayPal payment with timeout
      final result = await Future.any([
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => PaypalCheckoutView(
              sandboxMode: kDebugMode, // Use sandbox in debug mode
              clientId: PayPalConfigService.getConfig().clientId,
              secretKey: PayPalConfigService.getConfig().secret,
              transactions: [
                {
                  "amount": {
                    "total": amount,
                    "currency": currency,
                    "details": {
                      "subtotal": amount,
                      "shipping": '0',
                      "shipping_discount": 0,
                    },
                  },
                  "description": description,
                  "item_list": {
                    "items": [
                      {
                        "name": "QuizApp Pro Subscription",
                        "quantity": 1,
                        "price": amount,
                        "currency": currency,
                      },
                    ],
                  },
                },
              ],
              note: "Cảm ơn bạn đã nâng cấp lên QuizApp Pro!",
              onSuccess: (Map params) async {
                debugPrint("✅ PayPal payment success: $params");

                // Save payment record
                await _savePaymentRecord(
                  amount: amount,
                  currency: currency,
                  description: description,
                  paymentMethod: 'PayPal',
                  status: 'completed',
                );

                // Close the PayPal view and return success
                Navigator.of(
                  context,
                ).pop({'status': 'success', 'params': params});
              },
              onError: (error) {
                debugPrint("❌ PayPal payment error: $error");
                _error = 'PayPal payment failed: $error';
                notifyListeners();
                Navigator.of(context).pop({'status': 'error', 'error': error});
              },
              onCancel: () {
                debugPrint("⚠️ PayPal payment cancelled");
                _error = 'Payment cancelled by user';
                notifyListeners();
                Navigator.of(context).pop({'status': 'cancelled'});
              },
            ),
          ),
        ),
        // Timeout after 5 minutes
        Future.delayed(const Duration(minutes: 5), () => {'status': 'timeout'}),
      ]);

      // Check if payment was successful
      if (result != null && result['status'] == 'success') {
        debugPrint("✅ PayPal payment completed successfully");
        _isProcessing = false;
        notifyListeners();
        return true;
      } else if (result != null && result['status'] == 'cancelled') {
        debugPrint("⚠️ PayPal payment was cancelled by user");
        _isProcessing = false;
        _error = 'Payment cancelled by user';
        notifyListeners();
        return false;
      } else if (result != null && result['status'] == 'error') {
        debugPrint("❌ PayPal payment failed: ${result['error']}");
        _isProcessing = false;
        _error = 'PayPal payment failed: ${result['error']}';
        notifyListeners();
        return false;
      } else if (result != null && result['status'] == 'timeout') {
        debugPrint("⏰ PayPal payment timed out");
        _isProcessing = false;
        _error = 'Payment timed out. Please try again.';
        notifyListeners();
        return false;
      } else {
        debugPrint("❌ PayPal payment returned unexpected result: $result");
        _isProcessing = false;
        _error = 'Payment was not completed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isProcessing = false;
      _error = 'PayPal payment failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Save payment record to Firestore
  Future<void> _savePaymentRecord({
    required String amount,
    required String currency,
    required String description,
    required String paymentMethod,
    required String status,
  }) async {
    if (_currentUserId == null) return;

    final paymentData = {
      'userId': _currentUserId,
      'amount': double.parse(amount),
      'currency': currency,
      'description': description,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': _generateTransactionId(),
      'timestamp': FieldValue.serverTimestamp(),
      'environment': PayPalConfigService.environmentName,
    };

    await FirebaseFirestore.instance.collection('payments').add(paymentData);
  }

  /// Generate unique transaction ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'PP_${timestamp}_$random';
  }

  /// Load payment history for current user
  Future<List<Map<String, dynamic>>> loadPaymentHistory() async {
    if (_currentUserId == null) return [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      _error = 'Failed to load payment history: $e';
      notifyListeners();
      return [];
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _isProcessing = false;
    _error = null;
    _currentUserId = null;
    notifyListeners();
  }
}
