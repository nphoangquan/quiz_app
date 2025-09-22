import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/category_entity.dart';

/// Utility class to map between QuizCategory enum and dynamic CategoryEntity
class CategoryMapper {
  /// Default category mappings for backward compatibility
  static const Map<QuizCategory, String> _enumToSlug = {
    QuizCategory.programming: 'programming',
    QuizCategory.mathematics: 'mathematics',
    QuizCategory.science: 'science',
    QuizCategory.history: 'history',
    QuizCategory.language: 'language',
    QuizCategory.geography: 'geography',
    QuizCategory.sports: 'sports',
    QuizCategory.entertainment: 'entertainment',
    QuizCategory.general: 'general',
  };

  static const Map<String, QuizCategory> _slugToEnum = {
    'programming': QuizCategory.programming,
    'mathematics': QuizCategory.mathematics,
    'science': QuizCategory.science,
    'history': QuizCategory.history,
    'language': QuizCategory.language,
    'geography': QuizCategory.geography,
    'sports': QuizCategory.sports,
    'entertainment': QuizCategory.entertainment,
    'general': QuizCategory.general,
  };

  /// Convert QuizCategory enum to slug string
  static String enumToSlug(QuizCategory category) {
    return _enumToSlug[category] ?? 'general';
  }

  /// Convert slug string to QuizCategory enum
  static QuizCategory slugToEnum(String slug) {
    return _slugToEnum[slug] ?? QuizCategory.general;
  }

  /// Get category name from enum (Vietnamese)
  static String getDisplayName(QuizCategory category) {
    switch (category) {
      case QuizCategory.programming:
        return 'Lập trình';
      case QuizCategory.mathematics:
        return 'Toán học';
      case QuizCategory.science:
        return 'Khoa học';
      case QuizCategory.history:
        return 'Lịch sử';
      case QuizCategory.language:
        return 'Ngôn ngữ';
      case QuizCategory.geography:
        return 'Địa lý';
      case QuizCategory.sports:
        return 'Thể thao';
      case QuizCategory.entertainment:
        return 'Giải trí';
      case QuizCategory.general:
        return 'Tổng hợp';
    }
  }

  /// Create CategoryEntity from QuizCategory enum
  static CategoryEntity enumToCategoryEntity(QuizCategory category) {
    return CategoryEntity(
      categoryId: enumToSlug(category),
      name: getDisplayName(category),
      slug: enumToSlug(category),
      description: 'Default category: ${getDisplayName(category)}',
      color: _getDefaultColor(category),
      isActive: true,
      order: category.index + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      quizCount: 0,
    );
  }

  /// Get default color for category
  static String _getDefaultColor(QuizCategory category) {
    switch (category) {
      case QuizCategory.programming:
        return '#6366F1'; // Indigo
      case QuizCategory.mathematics:
        return '#F59E0B'; // Orange
      case QuizCategory.science:
        return '#10B981'; // Green
      case QuizCategory.history:
        return '#8B5A2B'; // Brown
      case QuizCategory.language:
        return '#3B82F6'; // Blue
      case QuizCategory.geography:
        return '#14B8A6'; // Teal
      case QuizCategory.sports:
        return '#EF4444'; // Red
      case QuizCategory.entertainment:
        return '#A855F7'; // Purple
      case QuizCategory.general:
        return '#6B7280'; // Gray
    }
  }

  /// Check if a categoryId exists in enum mappings
  static bool isEnumCategory(String categoryId) {
    return _slugToEnum.containsKey(categoryId);
  }

  /// Get all enum categories as CategoryEntity list
  static List<CategoryEntity> getAllEnumCategories() {
    return QuizCategory.values
        .map((category) => enumToCategoryEntity(category))
        .toList();
  }
}
