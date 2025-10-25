import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/category_entity.dart';
import '../../providers/category_provider.dart';

class CategoryManagementWidget extends StatefulWidget {
  const CategoryManagementWidget({super.key});

  @override
  State<CategoryManagementWidget> createState() =>
      _CategoryManagementWidgetState();
}

class _CategoryManagementWidgetState extends State<CategoryManagementWidget> {
  bool _isProcessing = false;
  bool _hasLoadedCategories = false;

  @override
  void initState() {
    super.initState();
    // Load categories only once when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedCategories) {
        context.read<CategoryProvider>().loadAllCategories();
        _hasLoadedCategories = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.allCategories;

        return Column(
          children: [
            // Header with Add Button
            _buildHeader(context),

            const SizedBox(height: 16),

            // Categories List
            Expanded(
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : categories.isEmpty
                  ? _buildEmptyState(context)
                  : _buildCategoriesList(context, categories),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            'Quản lý danh mục',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Thêm, chỉnh sửa và quản lý các danh mục quiz',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Buttons row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _refreshCategories(context),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: Text(
                    'Làm mới',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddCategoryDialog(context),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(
                    'Thêm danh mục',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có danh mục nào',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thêm danh mục đầu tiên để bắt đầu quản lý quiz.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(context),
              icon: const Icon(Icons.add),
              label: Text(
                'Thêm danh mục đầu tiên',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    List<CategoryEntity> categories,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryEntity category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: category.isActive ? Colors.green[200]! : Colors.red[200]!,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(int.parse(category.color.replaceFirst('#', '0xFF'))),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.category, color: Colors.white, size: 20),
        ),
        title: Text(
          category.name,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Slug: ${category.slug}',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: category.isActive
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category.isActive ? 'Hoạt động' : 'Tạm dừng',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: category.isActive
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Thứ tự: ${category.order}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleCategoryAction(context, value, category),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    category.isActive ? Icons.pause_circle : Icons.play_circle,
                    size: 18,
                    color: category.isActive ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.isActive ? 'Tạm dừng' : 'Kích hoạt',
                    style: TextStyle(
                      color: category.isActive ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_forever, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCategoryAction(
    BuildContext context,
    String action,
    CategoryEntity category,
  ) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(context, category);
        break;
      case 'toggle':
        _toggleCategoryStatus(context, category);
        break;
      case 'delete':
        _showDeleteCategoryDialog(context, category);
        break;
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    _showCategoryDialog(context);
  }

  void _refreshCategories(BuildContext context) {
    final categoryProvider = context.read<CategoryProvider>();
    categoryProvider.loadAllCategories();
  }

  void _showEditCategoryDialog(BuildContext context, CategoryEntity category) {
    _showCategoryDialog(context, existingCategory: category);
  }

  void _showCategoryDialog(
    BuildContext context, {
    CategoryEntity? existingCategory,
  }) {
    final nameController = TextEditingController(
      text: existingCategory?.name ?? '',
    );
    final slugController = TextEditingController(
      text: existingCategory?.slug ?? '',
    );
    final orderController = TextEditingController(
      text: existingCategory?.order.toString() ?? '',
    );
    bool isActive = existingCategory?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            existingCategory == null
                ? 'Thêm danh mục mới'
                : 'Chỉnh sửa danh mục',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên danh mục',
                    hintText: 'Ví dụ: Toán học',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // Auto-generate slug
                    final slug = _generateSlug(value);
                    slugController.text = slug;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: slugController,
                  decoration: InputDecoration(
                    labelText: 'Slug',
                    hintText: 'toan-hoc',
                    helperText: 'Chỉ chữ thường, số và dấu gạch ngang',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Thứ tự hiển thị',
                    hintText: 'Để trống để thêm vào cuối danh sách',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: isActive,
                      onChanged: (value) =>
                          setState(() => isActive = value ?? true),
                    ),
                    Text(
                      'Danh mục hoạt động',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => _saveCategoryDialog(
                context,
                existingCategory,
                nameController.text,
                slugController.text,
                int.tryParse(orderController.text) ?? 0,
                isActive,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: Text(
                existingCategory == null ? 'Thêm' : 'Cập nhật',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategoryDialog(
    BuildContext context,
    CategoryEntity? existingCategory,
    String name,
    String slug,
    int order,
    bool isActive,
  ) async {
    // Validation
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên danh mục'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (slug.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập slug'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate slug format (only lowercase letters, numbers, hyphens)
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(slug.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slug chỉ được chứa chữ thường, số và dấu gạch ngang'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate order
    if (order < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thứ tự phải là số dương'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final categoryProvider = context.read<CategoryProvider>();

      if (existingCategory != null) {
        // Update existing category
        final updatedCategory = CategoryEntity(
          categoryId: existingCategory.categoryId,
          name: name.trim(),
          slug: slug.trim(),
          color: existingCategory.color,
          isActive: isActive,
          order: order,
          createdAt: existingCategory.createdAt,
          updatedAt: DateTime.now(),
        );
        await categoryProvider.updateCategory(updatedCategory);
      } else {
        // Create new category
        final finalOrder = order <= 0 ? categoryProvider.getNextOrder() : order;

        final newCategory = CategoryEntity(
          categoryId: '',
          name: name.trim(),
          slug: slug.trim(),
          color: '#6366F1',
          isActive: isActive,
          order: finalOrder,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          quizCount: 0,
        );
        await categoryProvider.createCategory(newCategory);
      }

      Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existingCategory == null
                  ? 'Thêm danh mục thành công!'
                  : 'Cập nhật danh mục thành công!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _toggleCategoryStatus(
    BuildContext context,
    CategoryEntity category,
  ) async {
    try {
      final categoryProvider = context.read<CategoryProvider>();

      final updatedCategory = CategoryEntity(
        categoryId: category.categoryId,
        name: category.name,
        slug: category.slug,
        color: category.color,
        isActive: !category.isActive,
        order: category.order,
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
      );

      await categoryProvider.updateCategory(updatedCategory);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              category.isActive
                  ? 'Danh mục đã được tạm dừng'
                  : 'Danh mục đã được kích hoạt',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteCategoryDialog(
    BuildContext context,
    CategoryEntity category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Xóa danh mục',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa danh mục "${category.name}"? Hành động này không thể hoàn tác.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Hủy',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteCategory(context, category);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Xóa',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    CategoryEntity category,
  ) async {
    try {
      final categoryProvider = context.read<CategoryProvider>();
      await categoryProvider.deleteCategory(category.categoryId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa danh mục thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _generateSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
