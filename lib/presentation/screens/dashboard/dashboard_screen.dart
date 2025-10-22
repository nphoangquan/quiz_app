import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/category_entity.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load categories when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Double check admin access in build method
        if (!authProvider.isAdmin) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                'Dashboard',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block,
                    size: 80,
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Truy cập bị từ chối',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chỉ quản trị viên mới có quyền truy cập Dashboard',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Dashboard',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios),
            ),
            actions: [
              IconButton(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Thêm danh mục',
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeaderSection(),

                  const SizedBox(height: 24),

                  // Categories Management
                  Text(
                    'Quản lý danh mục',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Categories List
                  Expanded(child: _buildCategoriesList()),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddCategoryDialog,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dashboard, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Quản trị',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quản lý nội dung và danh mục ứng dụng',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoryProvider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Có lỗi xảy ra',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categoryProvider.errorMessage ?? 'Không thể tải danh mục',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => categoryProvider.loadCategories(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final categories = categoryProvider.allCategories;

        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 64, color: AppColors.grey),
                const SizedBox(height: 16),
                Text(
                  'Chưa có danh mục nào',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn nút + để thêm danh mục đầu tiên',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(category);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(CategoryEntity category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.category, color: AppColors.primary, size: 24),
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
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  category.isActive ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: category.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  category.isActive ? 'Đang hoạt động' : 'Tạm dừng',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: category.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Thứ tự: ${category.order}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCategoryAction(value, category),
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

  void _handleCategoryAction(String action, CategoryEntity category) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(category);
        break;
      case 'toggle':
        _toggleCategoryStatus(category);
        break;
      case 'delete':
        _showDeleteCategoryDialog(category);
        break;
    }
  }

  void _showAddCategoryDialog() {
    _showCategoryDialog();
  }

  void _showEditCategoryDialog(CategoryEntity category) {
    _showCategoryDialog(category: category);
  }

  void _showCategoryDialog({CategoryEntity? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final slugController = TextEditingController(text: category?.slug ?? '');
    final orderController = TextEditingController(
      text: category?.order.toString() ?? '',
    );
    bool isActive = category?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isEditing ? Icons.edit : Icons.add_circle_outline,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isEditing ? 'Chỉnh sửa danh mục' : 'Thêm danh mục mới',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên danh mục',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  onChanged: (value) {
                    // Auto-generate slug from name
                    if (!isEditing || slugController.text.isEmpty) {
                      slugController.text = _generateSlug(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: slugController,
                  decoration: const InputDecoration(
                    labelText: 'Slug (URL-friendly)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                    helperText: 'Chỉ chứa chữ thường, số và dấu gạch ngang',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Thứ tự hiển thị',
                    hintText: 'Để trống sẽ tự động thêm vào cuối',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sort),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.visibility),
                    const SizedBox(width: 8),
                    const Text('Trạng thái:'),
                    const Spacer(),
                    Switch(
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      isActive ? 'Hoạt động' : 'Tạm dừng',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.green : Colors.red,
                      ),
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
                style: GoogleFonts.inter(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _saveCategoryDialog(
                context,
                category,
                nameController.text,
                slugController.text,
                int.tryParse(orderController.text) ?? 0,
                isActive,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isEditing ? 'Cập nhật' : 'Thêm mới',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp(r'[đ]'), 'd')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  void _saveCategoryDialog(
    BuildContext context,
    CategoryEntity? existingCategory,
    String name,
    String slug,
    int order,
    bool isActive,
  ) async {
    if (name.trim().isEmpty || slug.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final categoryProvider = context.read<CategoryProvider>();

      if (existingCategory != null) {
        // Update existing category
        final updatedCategory = CategoryEntity(
          categoryId: existingCategory.categoryId,
          name: name.trim(),
          slug: slug.trim(),
          color: existingCategory.color, // Keep existing color
          isActive: isActive,
          order: order,
          createdAt: existingCategory.createdAt,
          updatedAt: DateTime.now(),
        );
        await categoryProvider.updateCategory(updatedCategory);
      } else {
        // Create new category
        // Auto-assign order if not provided (0 or empty)
        final finalOrder = order <= 0
            ? (categoryProvider.allCategories.isNotEmpty
                  ? categoryProvider.allCategories
                            .map((c) => c.order)
                            .reduce((a, b) => a > b ? a : b) +
                        1
                  : 1)
            : order;

        final newCategory = CategoryEntity(
          categoryId: '', // Will be generated by Firestore
          name: name.trim(),
          slug: slug.trim(),
          color: '#6366F1', // Default indigo color
          isActive: isActive,
          order: finalOrder,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await categoryProvider.createCategory(newCategory);
      }

      Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existingCategory != null
                  ? 'Cập nhật danh mục thành công'
                  : 'Thêm danh mục thành công',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleCategoryStatus(CategoryEntity category) async {
    try {
      final categoryProvider = context.read<CategoryProvider>();

      // Use disableCategory for better semantic meaning
      if (category.isActive) {
        await categoryProvider.disableCategory(category.categoryId);
      } else {
        // For reactivation, update with isActive = true
        final updatedCategory = CategoryEntity(
          categoryId: category.categoryId,
          name: category.name,
          slug: category.slug,
          color: category.color,
          isActive: true,
          order: category.order,
          createdAt: category.createdAt,
          updatedAt: DateTime.now(),
        );
        await categoryProvider.updateCategory(updatedCategory);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            category.isActive
                ? 'Đã tạm dừng danh mục "${category.name}"'
                : 'Đã kích hoạt danh mục "${category.name}"',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteCategoryDialog(CategoryEntity category) async {
    // Check if category is in use before showing dialog
    final categoryProvider = context.read<CategoryProvider>();

    try {
      final usageCount = await categoryProvider.getCategoryUsageCount(
        category.categoryId,
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_forever, color: AppColors.error, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Xóa vĩnh viễn danh mục',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn có chắc chắn muốn xóa vĩnh viễn danh mục "${category.name}" không?',
                style: GoogleFonts.inter(fontSize: 16),
              ),

              // Usage warning if category is in use
              if (usageCount > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Không thể xóa! Danh mục đang được sử dụng bởi $usageCount quiz.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: GoogleFonts.inter(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (usageCount == 0) // Only show delete button if not in use
              ElevatedButton(
                onPressed: () => _deleteCategory(category),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'XÓA VĨNH VIỄN',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      );
    } catch (e) {
      // Show error if unable to check usage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kiểm tra trạng thái danh mục: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteCategory(CategoryEntity category) async {
    try {
      final categoryProvider = context.read<CategoryProvider>();
      await categoryProvider.deleteCategory(category.categoryId);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa vĩnh viễn danh mục thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
