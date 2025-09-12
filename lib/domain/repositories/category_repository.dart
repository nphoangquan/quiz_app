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

  /// Delete category (soft delete)
  Future<void> deleteCategory(String categoryId);

  /// Update quiz count for category
  Future<void> updateQuizCount(String categoryId);

  /// Initialize default categories
  Future<void> initializeDefaultCategories();
}
