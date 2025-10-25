import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

enum CategoryState { idle, loading, success, error }

class CategoryProvider with ChangeNotifier {
  final CategoryRepository _categoryRepository;

  CategoryProvider(this._categoryRepository);

  // State management
  CategoryState _state = CategoryState.idle;
  String? _errorMessage;

  // Categories data
  List<CategoryEntity> _categories = [];
  List<CategoryEntity> _allCategories = [];
  CategoryEntity? _selectedCategory;

  // Getters
  CategoryState get state => _state;
  String? get errorMessage => _errorMessage;
  List<CategoryEntity> get categories => _categories;
  List<CategoryEntity> get allCategories => _allCategories;
  CategoryEntity? get selectedCategory => _selectedCategory;

  bool get isLoading => _state == CategoryState.loading;
  bool get hasError => _state == CategoryState.error;
  bool get hasCategories => _categories.isNotEmpty;

  // Set state helper
  void _setState(CategoryState newState, [String? error]) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  /// Load active categories from Firestore
  void loadCategories() {
    _setState(CategoryState.loading);

    try {
      _categoryRepository.getActiveCategories().listen(
        (categories) {
          debugPrint(
            '📦 Loaded ${categories.length} categories from Firestore',
          );
          _categories = categories;
          _setState(CategoryState.success);
        },
        onError: (error) {
          debugPrint('❌ Error loading categories: $error');
          _setState(CategoryState.error, error.toString());
        },
      );
    } catch (e) {
      _setState(CategoryState.error, e.toString());
    }
  }

  /// Load all categories (including inactive) for admin dashboard
  void loadAllCategories() {
    try {
      _categoryRepository.getAllCategories().listen(
        (allCategories) {
          debugPrint(
            '📦 Loaded ${allCategories.length} total categories (including inactive)',
          );
          _allCategories = allCategories;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('❌ Error loading all categories: $error');
        },
      );
    } catch (e) {
      debugPrint('❌ Error loading all categories: $e');
    }
  }

  /// Initialize categories on app startup
  Future<void> initializeCategories() async {
    try {
      _setState(CategoryState.loading);

      // Initialize default categories if needed
      await _categoryRepository.initializeDefaultCategories();

      // Load categories
      loadCategories();
      loadAllCategories();
    } catch (e) {
      _setState(CategoryState.error, e.toString());
    }
  }

  /// Select a category
  void selectCategory(CategoryEntity? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Get category by ID
  Future<CategoryEntity?> getCategoryById(String categoryId) async {
    try {
      return await _categoryRepository.getCategoryById(categoryId);
    } catch (e) {
      debugPrint('Failed to get category by ID: $e');
      return null;
    }
  }

  /// Get category by slug
  Future<CategoryEntity?> getCategoryBySlug(String slug) async {
    try {
      return await _categoryRepository.getCategoryBySlug(slug);
    } catch (e) {
      debugPrint('Failed to get category by slug: $e');
      return null;
    }
  }

  /// Update quiz count for a category
  Future<void> updateQuizCount(String categoryId) async {
    try {
      await _categoryRepository.updateQuizCount(categoryId);
    } catch (e) {
      debugPrint('Failed to update quiz count: $e');
    }
  }

  /// Get category color as Color object
  Color getCategoryColor(String categoryId) {
    try {
      final category = _categories.firstWhere(
        (cat) => cat.categoryId == categoryId,
      );

      // Parse hex color string to Color
      final hexColor = category.color.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      // Return default color if category not found or color parsing fails
      return const Color(0xFF6366F1); // Default indigo
    }
  }

  /// Clear error
  void clearError() {
    if (_state == CategoryState.error) {
      _state = CategoryState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Create a new category
  Future<void> createCategory(CategoryEntity category) async {
    try {
      await _categoryRepository.createCategory(category);
      // Categories will be automatically updated through the stream listener
    } catch (e) {
      debugPrint('Failed to create category: $e');
      rethrow;
    }
  }

  /// Update an existing category
  Future<void> updateCategory(CategoryEntity category) async {
    try {
      await _categoryRepository.updateCategory(category);
      // Categories will be automatically updated through the stream listener
    } catch (e) {
      debugPrint('Failed to update category: $e');
      rethrow;
    }
  }

  /// Check if category is used by any quizzes
  Future<bool> isCategoryInUse(String categoryId) async {
    try {
      return await _categoryRepository.isCategoryInUse(categoryId);
    } catch (e) {
      debugPrint('Failed to check category usage: $e');
      rethrow;
    }
  }

  /// Get count of quizzes using this category
  Future<int> getCategoryUsageCount(String categoryId) async {
    try {
      return await _categoryRepository.getCategoryUsageCount(categoryId);
    } catch (e) {
      debugPrint('Failed to get category usage count: $e');
      rethrow;
    }
  }

  /// Delete a category (permanently remove from database)
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoryRepository.deleteCategory(categoryId);
      // Categories will be automatically updated through the stream listener
    } catch (e) {
      debugPrint('Failed to delete category: $e');
      rethrow;
    }
  }

  /// Disable a category (soft delete - set isActive to false)
  Future<void> disableCategory(String categoryId) async {
    try {
      await _categoryRepository.disableCategory(categoryId);
      // Categories will be automatically updated through the stream listener
    } catch (e) {
      debugPrint('Failed to disable category: $e');
      rethrow;
    }
  }

  /// Get the next available order for new category (max order + 1)
  int getNextOrder() {
    if (_allCategories.isEmpty) return 1;
    final maxOrder = _allCategories
        .map((cat) => cat.order)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
