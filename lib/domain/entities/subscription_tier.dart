/// Enum định nghĩa các gói subscription trong hệ thống
enum SubscriptionTier {
  /// Gói miễn phí
  free,

  /// Gói Pro (trả phí)
  pro,
}

extension SubscriptionTierExtension on SubscriptionTier {
  /// Chuyển đổi từ string sang SubscriptionTier
  static SubscriptionTier fromString(String tier) {
    switch (tier.toLowerCase()) {
      case 'pro':
        return SubscriptionTier.pro;
      case 'free':
      default:
        return SubscriptionTier.free;
    }
  }

  /// Chuyển đổi SubscriptionTier sang string
  String get value {
    switch (this) {
      case SubscriptionTier.free:
        return 'free';
      case SubscriptionTier.pro:
        return 'pro';
    }
  }

  /// Tên hiển thị bằng tiếng Việt
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Miễn phí';
      case SubscriptionTier.pro:
        return 'Pro';
    }
  }

  /// Giá hàng tháng
  String get priceMonthly {
    switch (this) {
      case SubscriptionTier.free:
        return '0đ';
      case SubscriptionTier.pro:
        return '49,000đ';
    }
  }

  /// Giá hàng năm
  String get priceYearly {
    switch (this) {
      case SubscriptionTier.free:
        return '0đ';
      case SubscriptionTier.pro:
        return '490,000đ';
    }
  }

  /// Giá bằng USD (cho Stripe)
  int get priceMonthlyUSD {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.pro:
        return 490; // $4.90
    }
  }

  /// Giá hàng năm bằng USD (cho Stripe)
  int get priceYearlyUSD {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.pro:
        return 4900; // $49.00
    }
  }

  /// Giới hạn số quiz có thể tạo mỗi ngày
  int get quizDailyLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 20; // Free users: 20 quizzes/ngày
      case SubscriptionTier.pro:
        return -1; // Pro users: unlimited
    }
  }

  /// Giới hạn AI generation mỗi ngày
  int get aiGenerationDailyLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 5; // Free users: 5 AI generations/ngày
      case SubscriptionTier.pro:
        return -1; // Pro users: unlimited
    }
  }

  /// Danh sách tính năng
  List<String> get features {
    switch (this) {
      case SubscriptionTier.free:
        return [
          'Tạo 20 quizzes/ngày',
          'Chơi unlimited quizzes',
          'AI quiz generation: 5/ngày',
          'Xem basic statistics',
        ];
      case SubscriptionTier.pro:
        return [
          'Tạo unlimited quizzes',
          'Chơi unlimited quizzes',
          'Xem basic statistics',
          'AI quiz generation: Unlimited',
          'Priority support',
          'Remove ads',
        ];
    }
  }

  /// Kiểm tra có phải Pro không
  bool get isPro => this == SubscriptionTier.pro;

  /// Kiểm tra có phải Free không
  bool get isFree => this == SubscriptionTier.free;

  /// Mô tả gói
  String get description {
    switch (this) {
      case SubscriptionTier.free:
        return 'Gói cơ bản với các tính năng cần thiết';
      case SubscriptionTier.pro:
        return 'Gói cao cấp với đầy đủ tính năng';
    }
  }
}
