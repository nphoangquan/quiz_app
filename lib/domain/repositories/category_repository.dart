import '../entities/category_entity.dart';

abstract class CategoryRepository {
  /// Get all active categories
  Stream<List<CategoryEntity>> getActiveCategories();

  /// Get all categories (including inactive)
  Stream<List<CategoryEntity>> getAllCategories();

  /// Get category by ID
  Future<CategoryEntity?> getCategoryById(String categoryId);

  /// Get category by slug
  Future<CategoryEntity?> getCategoryBySlug(String slug);

  /// Create new category
  Future<String> createCategory(CategoryEntity category);

  /// Update category
  Future<void> updateCategory(CategoryEntity category);

  /// Check if category is used by any quizzes
  Future<bool> isCategoryInUse(String categoryId);

  /// Get count of quizzes using this category
  Future<int> getCategoryUsageCount(String categoryId);

  /// Delete category (hard delete - permanently remove)
  Future<void> deleteCategory(String categoryId);

  /// Disable category (soft delete - set isActive to false)
  Future<void> disableCategory(String categoryId);

  /// Update quiz count for category
  Future<void> updateQuizCount(String categoryId);

  /// Initialize default categories
  Future<void> initializeDefaultCategories();
}
