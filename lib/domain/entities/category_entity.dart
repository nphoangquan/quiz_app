class CategoryEntity {
  final String categoryId;
  final String name;
  final String slug; // For URL-friendly identifier
  final String? description;
  final String color; // Hex color string (e.g., "#FF5722")
  final bool isActive;
  final int order; // For sorting display order
  final DateTime createdAt;
  final DateTime updatedAt;
  final int quizCount; // Number of quizzes in this category

  const CategoryEntity({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryEntity && other.categoryId == categoryId;
  }

  @override
  int get hashCode => categoryId.hashCode;

  @override
  String toString() {
    return 'CategoryEntity(categoryId: $categoryId, name: $name, slug: $slug)';
  }

  CategoryEntity copyWith({
    String? categoryId,
    String? name,
    String? slug,
    String? description,
    String? color,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? quizCount,
  }) {
    return CategoryEntity(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      quizCount: quizCount ?? this.quizCount,
    );
  }
}
