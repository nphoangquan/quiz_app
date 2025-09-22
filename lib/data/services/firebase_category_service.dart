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

  /// Delete category (soft delete by setting isActive to false)
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete category: $e');
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
