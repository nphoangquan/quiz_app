import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class FirebaseCategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _categoriesCollection;

  FirebaseCategoryService() {
    _categoriesCollection = _firestore.collection('categories');
  }

  /// Get all active categories ordered by order field
  Stream<List<CategoryModel>> getActiveCategories() {
    return _categoriesCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final categories = snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList();

          // Sort in memory to avoid Firestore index issues
          categories.sort((a, b) => a.order.compareTo(b.order));
          return categories;
        });
  }

  /// Get all categories (including inactive) - for admin use
  Stream<List<CategoryModel>> getAllCategories() {
    return _categoriesCollection
        .orderBy('order')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      if (doc.exists) {
        return CategoryModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  /// Get category by slug
  Future<CategoryModel?> getCategoryBySlug(String slug) async {
    try {
      final querySnapshot = await _categoriesCollection
          .where('slug', isEqualTo: slug)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return CategoryModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category by slug: $e');
    }
  }

  /// Create a new category
  Future<String> createCategory(CategoryModel category) async {
    try {
      // Check if slug already exists
      final existingCategory = await getCategoryBySlug(category.slug);
      if (existingCategory != null) {
        throw Exception('Category with slug "${category.slug}" already exists');
      }

      final docRef = await _categoriesCollection.add(category.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update category
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _categoriesCollection
          .doc(category.categoryId)
          .update(category.toFirestore());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Check if category is used by any quizzes
  Future<bool> isCategoryInUse(String categoryId) async {
    try {
      // First get the category to know its slug
      final category = await getCategoryById(categoryId);
      if (category == null) return false;

      // Check by categoryId field (for dynamic categories)
      final categoryIdBasedQuizzes = await _firestore
          .collection('quizzes')
          .where('categoryId', isEqualTo: categoryId)
          .limit(1)
          .get();

      // Check by category slug (for enum-based categories)
      final enumBasedQuizzes = await _firestore
          .collection('quizzes')
          .where('category', isEqualTo: category.slug)
          .limit(1)
          .get();

      // Also check by Vietnamese category name (if stored as name)
      final nameBasedQuizzes = await _firestore
          .collection('quizzes')
          .where('category', isEqualTo: category.name)
          .limit(1)
          .get();

      return categoryIdBasedQuizzes.docs.isNotEmpty ||
          enumBasedQuizzes.docs.isNotEmpty ||
          nameBasedQuizzes.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check category usage: $e');
    }
  }

  /// Get count of quizzes using this category
  Future<int> getCategoryUsageCount(String categoryId) async {
    try {
      // First get the category to know its slug
      final category = await getCategoryById(categoryId);
      if (category == null) return 0;

      final categoryIdBased = await _firestore
          .collection('quizzes')
          .where('categoryId', isEqualTo: categoryId)
          .count()
          .get();

      final slugBased = await _firestore
          .collection('quizzes')
          .where('category', isEqualTo: category.slug)
          .count()
          .get();

      final nameBased = await _firestore
          .collection('quizzes')
          .where('category', isEqualTo: category.name)
          .count()
          .get();

      return (categoryIdBased.count ?? 0) +
          (slugBased.count ?? 0) +
          (nameBased.count ?? 0);
    } catch (e) {
      throw Exception('Failed to get category usage count: $e');
    }
  }

  /// Delete category (hard delete - permanently remove from database)
  Future<void> deleteCategory(String categoryId) async {
    try {
      // Check if category is in use before deletion
      final isInUse = await isCategoryInUse(categoryId);
      if (isInUse) {
        throw Exception(
          'Cannot delete category: It is being used by existing quizzes',
        );
      }

      // Get the category order before deletion
      final categoryToDelete = await getCategoryById(categoryId);
      final deletedOrder = categoryToDelete?.order ?? 0;

      // Delete the category
      await _categoriesCollection.doc(categoryId).delete();

      // Reorder remaining categories
      await _reorderCategoriesAfterDelete(deletedOrder);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Reorder categories after deletion to fill gaps
  Future<void> _reorderCategoriesAfterDelete(int deletedOrder) async {
    try {
      // Get all categories with order greater than deleted order
      final categoriesSnapshot = await _categoriesCollection
          .where('order', isGreaterThan: deletedOrder)
          .get();

      // Update each category to move up by 1
      final batch = _firestore.batch();
      for (final doc in categoriesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final currentOrder = data['order'] as int;
        batch.update(doc.reference, {
          'order': currentOrder - 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (categoriesSnapshot.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      // Don't throw error - deletion was successful, reordering is optional
    }
  }

  /// Disable category (soft delete by setting isActive to false)
  Future<void> disableCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to disable category: $e');
    }
  }

  /// Update quiz count for a category
  Future<void> updateQuizCount(String categoryId) async {
    try {
      // Get current quiz count for this category
      final quizCount = await _firestore
          .collection('quizzes')
          .where('category', isEqualTo: categoryId)
          .where('isPublic', isEqualTo: true)
          .count()
          .get();

      // Update category with new count
      await _categoriesCollection.doc(categoryId).update({
        'quizCount': quizCount.count,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update quiz count: $e');
    }
  }

  /// Initialize default categories (for first-time setup)
  Future<void> initializeDefaultCategories() async {
    try {
      final defaultCategories = [
        CategoryModel(
          categoryId: '',
          name: 'Lập trình',
          slug: 'programming',
          description: 'Các chủ đề về lập trình và công nghệ',
          color: '#6366F1', // Indigo
          isActive: true,
          order: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          categoryId: '',
          name: 'Toán học',
          slug: 'mathematics',
          description: 'Các chủ đề về toán học',
          color: '#F59E0B', // Orange
          isActive: true,
          order: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          categoryId: '',
          name: 'Khoa học',
          slug: 'science',
          description: 'Các chủ đề về khoa học tự nhiên',
          color: '#10B981', // Green
          isActive: true,
          order: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          categoryId: '',
          name: 'Lịch sử',
          slug: 'history',
          description: 'Các chủ đề về lịch sử',
          color: '#8B5A2B', // Brown
          isActive: true,
          order: 4,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          categoryId: '',
          name: 'Ngôn ngữ',
          slug: 'language',
          description: 'Các chủ đề về ngôn ngữ và văn học',
          color: '#3B82F6', // Blue
          isActive: true,
          order: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Check if categories collection is empty
      final existingCategories = await _categoriesCollection.limit(1).get();
      if (existingCategories.docs.isEmpty) {
        // Add default categories
        for (final category in defaultCategories) {
          await createCategory(category);
        }
        print('Default categories initialized successfully');
      }
    } catch (e) {
      print('Failed to initialize default categories: $e');
    }
  }
}
