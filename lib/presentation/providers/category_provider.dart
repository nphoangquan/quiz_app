import 'package:flutter/foundation.dart';
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
  CategoryEntity? _selectedCategory;

  // Getters
  CategoryState get state => _state;
  String? get errorMessage => _errorMessage;
  List<CategoryEntity> get categories => _categories;
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
          for (final cat in categories) {
            debugPrint(
              '  - ${cat.name} (${cat.categoryId}): ${cat.quizCount} quizzes',
            );
          }
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

  /// Initialize categories on app startup
  Future<void> initializeCategories() async {
    try {
      _setState(CategoryState.loading);

      // Initialize default categories if needed
      await _categoryRepository.initializeDefaultCategories();

      // Load categories
      loadCategories();
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

  /// Get categories with non-zero quiz counts
  List<CategoryEntity> getCategoriesWithQuizzes() {
    return _categories.where((category) => category.quizCount > 0).toList();
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

  /// Refresh categories
  void refresh() {
    loadCategories();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
