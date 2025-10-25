import 'package:flutter/foundation.dart';

/// PayPal Configuration Service
/// Manages PayPal SDK configuration and credentials
class PayPalConfigService {
  static const String _sandboxClientId = '';
  static const String _sandboxSecret = '';

  // Production credentials (for future use)
  static const String _productionClientId = 'YOUR_PRODUCTION_CLIENT_ID';
  static const String _productionSecret = 'YOUR_PRODUCTION_SECRET';

  /// Get PayPal configuration based on environment
  static PayPalConfig getConfig() {
    if (kDebugMode) {
      // Use Sandbox for development
      return PayPalConfig(
        clientId: _sandboxClientId,
        secret: _sandboxSecret,
        environment: PayPalEnvironment.sandbox,
        currency: 'USD',
        locale: 'en_US',
      );
    } else {
      // Use Production for release
      return PayPalConfig(
        clientId: _productionClientId,
        secret: _productionSecret,
        environment: PayPalEnvironment.production,
        currency: 'USD',
        locale: 'en_US',
      );
    }
  }

  /// Check if PayPal is properly configured
  static bool get isConfigured {
    final config = getConfig();
    return config.clientId.isNotEmpty &&
        config.clientId != 'YOUR_SANDBOX_CLIENT_ID' &&
        config.secret.isNotEmpty &&
        config.secret != 'YOUR_SANDBOX_SECRET';
  }

  /// Get PayPal environment name for display
  static String get environmentName {
    return kDebugMode ? 'Sandbox' : 'Production';
  }
}

/// PayPal Configuration Model
class PayPalConfig {
  final String clientId;
  final String secret;
  final PayPalEnvironment environment;
  final String currency;
  final String locale;

  const PayPalConfig({
    required this.clientId,
    required this.secret,
    required this.environment,
    required this.currency,
    required this.locale,
  });
}

/// PayPal Environment Enum
enum PayPalEnvironment { sandbox, production }

/// PayPal Payment Request Model
class PayPalPaymentRequest {
  final String amount;
  final String currency;
  final String description;
  final String? returnUrl;
  final String? cancelUrl;

  const PayPalPaymentRequest({
    required this.amount,
    required this.currency,
    required this.description,
    this.returnUrl,
    this.cancelUrl,
  });

  /// Create Pro subscription payment request
  factory PayPalPaymentRequest.proSubscription() {
    return const PayPalPaymentRequest(
      amount: '9.99',
      currency: 'USD',
      description: 'QuizApp Pro Subscription - Monthly',
      returnUrl: 'https://quizapp.com/payment/success',
      cancelUrl: 'https://quizapp.com/payment/cancel',
    );
  }
}
