import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';
import '../services/firebase_category_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseCategoryService _categoryService;

  CategoryRepositoryImpl(this._categoryService);

  @override
  Stream<List<CategoryEntity>> getActiveCategories() {
    return _categoryService.getActiveCategories().map(
      (categories) => categories.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Stream<List<CategoryEntity>> getAllCategories() {
    return _categoryService.getAllCategories().map(
      (categories) => categories.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<CategoryEntity?> getCategoryById(String categoryId) async {
    final model = await _categoryService.getCategoryById(categoryId);
    return model?.toEntity();
  }

  @override
  Future<CategoryEntity?> getCategoryBySlug(String slug) async {
    final model = await _categoryService.getCategoryBySlug(slug);
    return model?.toEntity();
  }

  @override
  Future<String> createCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    return await _categoryService.createCategory(model);
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await _categoryService.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _categoryService.deleteCategory(categoryId);
  }

  @override
  Future<void> updateQuizCount(String categoryId) async {
    await _categoryService.updateQuizCount(categoryId);
  }

  @override
  Future<void> initializeDefaultCategories() async {
    await _categoryService.initializeDefaultCategories();
  }
}
