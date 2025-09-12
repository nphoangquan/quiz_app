import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel {
  final String categoryId;
  final String name;
  final String slug;
  final String? description;
  final String color;
  final bool isActive;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int quizCount;

  const CategoryModel({
    required this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    required this.color,
    this.isActive = true,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
    this.quizCount = 0,
  });

  // Convert from Entity
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      categoryId: entity.categoryId,
      name: entity.name,
      slug: entity.slug,
      description: entity.description,
      color: entity.color,
      isActive: entity.isActive,
      order: entity.order,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      quizCount: entity.quizCount,
    );
  }

  // Convert to Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      name: name,
      slug: slug,
      description: description,
      color: color,
      isActive: isActive,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
      quizCount: quizCount,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'color': color,
      'isActive': isActive,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'quizCount': quizCount,
    };
  }

  // Create from Firestore document
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CategoryModel(
      categoryId: doc.id,
      name: data['name'] ?? '',
      slug: data['slug'] ?? '',
      description: data['description'],
      color: data['color'] ?? '#6366F1',
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      quizCount: data['quizCount'] ?? 0,
    );
  }

  // Create from Map (for testing/other purposes)
  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      categoryId: id,
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      description: map['description'],
      color: map['color'] ?? '#6366F1',
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      quizCount: map['quizCount'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.categoryId == categoryId;
  }

  @override
  int get hashCode => categoryId.hashCode;

  @override
  String toString() {
    return 'CategoryModel(categoryId: $categoryId, name: $name, slug: $slug)';
  }
}
