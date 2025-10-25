import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider để quản lý payment processing
class PaymentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isProcessing = false;
  String? _error;
  List<PaymentRecord> _paymentHistory = [];

  // Getters
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  List<PaymentRecord> get paymentHistory => _paymentHistory;

  /// Process payment (Mock implementation)
  Future<bool> processPayment({
    required double amount,
    required String cardNumber,
    required String cardholderName,
    required String expiryDate,
    required String cvv,
  }) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock payment validation
      if (!_validatePaymentDetails(cardNumber, expiryDate, cvv)) {
        _error = 'Thông tin thẻ không hợp lệ';
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      // Simulate payment gateway response
      final paymentResult = await _simulatePaymentGateway(
        amount: amount,
        cardNumber: cardNumber,
        cardholderName: cardholderName,
        expiryDate: expiryDate,
        cvv: cvv,
      );

      if (paymentResult['success']) {
        // Save payment record
        await _savePaymentRecord(
          amount: amount,
          transactionId: paymentResult['transactionId'],
          cardLast4: cardNumber.substring(cardNumber.length - 4),
          status: 'completed',
        );

        _isProcessing = false;
        notifyListeners();
        return true;
      } else {
        _error = paymentResult['error'] ?? 'Thanh toán thất bại';
        _isProcessing = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Lỗi hệ thống: $e';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Validate payment details
  bool _validatePaymentDetails(
    String cardNumber,
    String expiryDate,
    String cvv,
  ) {
    // Remove spaces from card number
    final cleanCardNumber = cardNumber.replaceAll(' ', '');

    // Basic validation
    if (cleanCardNumber.length < 16) return false;
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) return false;
    if (cvv.length < 3) return false;

    // Check expiry date
    final now = DateTime.now();
    final expiryParts = expiryDate.split('/');
    final expiryMonth = int.parse(expiryParts[0]);
    final expiryYear = 2000 + int.parse(expiryParts[1]);

    if (expiryYear < now.year ||
        (expiryYear == now.year && expiryMonth < now.month)) {
      return false;
    }

    return true;
  }

  /// Simulate payment gateway call
  Future<Map<String, dynamic>> _simulatePaymentGateway({
    required double amount,
    required String cardNumber,
    required String cardholderName,
    required String expiryDate,
    required String cvv,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock payment gateway logic
    final cleanCardNumber = cardNumber.replaceAll(' ', '');

    // Simulate different scenarios
    if (cleanCardNumber.startsWith('4000')) {
      // Simulate declined card
      return {
        'success': false,
        'error': 'Thẻ bị từ chối. Vui lòng thử thẻ khác.',
        'transactionId': null,
      };
    } else if (cleanCardNumber.startsWith('5000')) {
      // Simulate insufficient funds
      return {
        'success': false,
        'error': 'Số dư không đủ. Vui lòng kiểm tra tài khoản.',
        'transactionId': null,
      };
    } else {
      // Simulate successful payment
      final transactionId = 'TXN_${DateTime.now().millisecondsSinceEpoch}';
      return {'success': true, 'transactionId': transactionId, 'error': null};
    }
  }

  /// Save payment record to Firestore
  Future<void> _savePaymentRecord({
    required double amount,
    required String transactionId,
    required String cardLast4,
    required String status,
  }) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.collection('payments').add({
        'userId': userId,
        'amount': amount,
        'transactionId': transactionId,
        'cardLast4': cardLast4,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'paymentMethod': 'Mock',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Failed to save payment record: $e');
      throw e;
    }
  }

  /// Get current user ID from AuthProvider
  String? _getCurrentUserId() {
    // This will be set by the calling context
    return _currentUserId;
  }

  String? _currentUserId;

  /// Set current user ID (called from AuthProvider)
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  /// Load payment history
  Future<void> loadPaymentHistory() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      _paymentHistory = snapshot.docs.map((doc) {
        final data = doc.data();

        // Handle both Mock payments (createdAt) and PayPal payments (timestamp)
        DateTime createdAt;
        if (data['timestamp'] != null) {
          createdAt = (data['timestamp'] as Timestamp).toDate();
        } else if (data['createdAt'] != null) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        } else {
          createdAt = DateTime.now();
        }

        // Handle cardLast4 for both Mock and PayPal
        String cardLast4 = data['cardLast4'] ?? '';
        if (cardLast4.isEmpty && data['paymentMethod'] == 'PayPal') {
          cardLast4 = 'PayPal';
        }

        return PaymentRecord(
          id: doc.id,
          amount: (data['amount'] as num).toDouble(),
          transactionId: data['transactionId'] ?? '',
          cardLast4: cardLast4,
          status: data['status'] ?? '',
          createdAt: createdAt,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to load payment history: $e');
      _error = 'Không thể tải lịch sử thanh toán';
      notifyListeners();
    }
  }

  /// Add a payment record to the history (for merging PayPal payments)
  void addPaymentRecord(PaymentRecord payment) {
    _paymentHistory.add(payment);
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _isProcessing = false;
    _error = null;
    _paymentHistory.clear();
    notifyListeners();
  }
}

/// Payment record model
class PaymentRecord {
  final String id;
  final double amount;
  final String transactionId;
  final String cardLast4;
  final String status;
  final DateTime createdAt;

  PaymentRecord({
    required this.id,
    required this.amount,
    required this.transactionId,
    required this.cardLast4,
    required this.status,
    required this.createdAt,
  });

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedDate =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get maskedCardNumber => '**** **** **** $cardLast4';
}
