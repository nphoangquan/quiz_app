import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../widgets/quiz/quiz_card.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/category_provider.dart';
import '../quiz/quiz_player_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  CategoryEntity? _selectedFilterCategory;
  QuizDifficulty? _selectedFilterDifficulty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load public quizzes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = context.read<QuizProvider>();

      quizProvider.loadPublicQuizzes();
      quizProvider.loadFeaturedQuizzes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            return Column(
              children: [
                // Header
                _buildHeader(),

                // Search Bar
                _buildSearchBar(),

                // Filters
                _buildFilters(),

                // Tab Bar
                _buildTabBar(),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllQuizzes(quizProvider),
                      _buildNewQuizzes(quizProvider),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          Text(
            'Khám phá',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Use theme card color
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.15)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: IconButton(
              onPressed: _showAdvancedFilterDialog,
              icon: Icon(Icons.tune, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Use theme card color
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm quiz...',
            hintStyle: GoogleFonts.inter(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withOpacity(0.6),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withOpacity(0.6),
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withOpacity(0.6),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.categories.isEmpty) {
          return const SizedBox(height: 16); // Just spacing if no categories
        }

        return Container(
          height: 50, // Increased height to accommodate shadow and padding
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.symmetric(vertical: 4), // Space for shadows
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none, // Allow shadows to extend beyond bounds
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            children: [
              _buildCategoryChip('Tất cả', null),
              const SizedBox(width: 12),
              ...categoryProvider.categories
                  .map(
                    (category) => [
                      _buildCategoryChip(category.name, category),
                      const SizedBox(width: 12),
                    ],
                  )
                  .expand((element) => element),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String name, CategoryEntity? category) {
    final bool isSelected = category == _selectedFilterCategory;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterCategory = category;
        });

        // Apply filter directly without navigation
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).cardColor, // Use theme card color
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 8 : 6,
              offset: const Offset(0, 2),
              spreadRadius: isSelected ? 1 : 0,
            ),
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Theme.of(
          context,
        ).textTheme.bodyLarge?.color?.withOpacity(0.6),
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'Tất cả'),
          Tab(text: 'Mới nhất'),
        ],
      ),
    );
  }

  Widget _buildAllQuizzes(QuizProvider quizProvider) {
    if (quizProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quizProvider.hasError) {
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
              quizProvider.errorMessage ?? 'Không thể tải quiz',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                quizProvider.loadPublicQuizzes();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Sort "Tất cả" by category, then title (alphabetical)
    final sortedQuizzes = List<QuizEntity>.from(quizProvider.publicQuizzes)
      ..sort((a, b) {
        // First sort by category name
        final categoryA = _getCategoryName(a);
        final categoryB = _getCategoryName(b);
        final categoryComparison = categoryA.compareTo(categoryB);
        if (categoryComparison != 0) return categoryComparison;

        // Then sort by title (alphabetical)
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

    return _buildQuizGrid(sortedQuizzes);
  }

  Widget _buildNewQuizzes(QuizProvider quizProvider) {
    if (quizProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Sort "Mới nhất" by creation date (newest first)
    final newQuizzes = List<QuizEntity>.from(quizProvider.publicQuizzes)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return _buildQuizGrid(newQuizzes);
  }

  Widget _buildQuizGrid(List<QuizEntity> quizzes) {
    var filteredQuizzes = quizzes.where((quiz) {
      // Category filter
      final matchesCategory =
          _selectedFilterCategory == null ||
          quiz.categoryId == _selectedFilterCategory!.categoryId;

      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          quiz.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          quiz.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Difficulty filter
      final matchesDifficulty =
          _selectedFilterDifficulty == null ||
          quiz.difficulty == _selectedFilterDifficulty;

      return matchesCategory && matchesSearch && matchesDifficulty;
    }).toList();

    if (filteredQuizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy quiz nào',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: filteredQuizzes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: double.infinity,
              child: QuizCard(
                quiz: filteredQuizzes[index],
                onTap: () =>
                    _navigateToQuizPlayer(context, filteredQuizzes[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToQuizPlayer(BuildContext context, QuizEntity quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizPlayerScreen(
          quizId: quiz.quizId,
          enableTimer: false, // Can be made configurable based on quiz settings
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    // Filtering is now done locally in _buildQuizGrid, no need to reload
  }

  void _showAdvancedFilterDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Use theme card color
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header với padding cải thiện
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Text(
                    'Bộ lọc nâng cao',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineLarge?.color,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAllFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Xóa tất cả',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider với margin
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
            ),

            // Filter Content với padding cải thiện
            Expanded(
              child: SingleChildScrollView(
                clipBehavior:
                    Clip.none, // Allow shadows to extend beyond bounds
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(
                      'Danh mục',
                      _buildAdvancedCategoryOptions(),
                    ),
                    const SizedBox(height: 32),
                    _buildFilterSection(
                      'Độ khó',
                      _buildAdvancedDifficultyOptions(),
                    ),
                  ],
                ),
              ),
            ),

            // Apply Button với padding và style cải thiện
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyFilters();
                  },
                  child: Text(
                    'Áp dụng bộ lọc',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),
        ),
        content,
      ],
    );
  }

  Widget _buildAdvancedCategoryOptions() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categories;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // "Tất cả danh mục"
                GestureDetector(
                  onTap: () {
                    setModalState(() {
                      _selectedFilterCategory = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedFilterCategory == null
                          ? AppColors.primary
                          : isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[50],
                      border: Border.all(
                        color: _selectedFilterCategory == null
                            ? AppColors.primary
                            : isDarkMode
                            ? Colors.grey[600]!
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (_selectedFilterCategory == null)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Text(
                      'Tất cả danh mục',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _selectedFilterCategory == null
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                // Dynamic categories
                ...categories.map((category) {
                  final isSelected =
                      _selectedFilterCategory?.categoryId ==
                      category.categoryId;

                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _selectedFilterCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[50],
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isDarkMode
                              ? Colors.grey[600]!
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        category.name,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAdvancedDifficultyOptions() {
    final difficulties = [
      {'difficulty': null, 'name': 'Tất cả độ khó'},
      {'difficulty': QuizDifficulty.beginner, 'name': 'Dễ'},
      {'difficulty': QuizDifficulty.intermediate, 'name': 'Trung bình'},
      {'difficulty': QuizDifficulty.advanced, 'name': 'Khó'},
    ];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: difficulties.map((item) {
            final difficulty = item['difficulty'] as QuizDifficulty?;
            final name = item['name'] as String;
            final isSelected = _selectedFilterDifficulty == difficulty;

            return GestureDetector(
              onTap: () {
                setModalState(() {
                  _selectedFilterDifficulty = difficulty;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[50],
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : isDarkMode
                        ? Colors.grey[600]!
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilterCategory = null;
      _selectedFilterDifficulty = null;
      _searchQuery = '';
    });
  }

  void _applyFilters() {
    // Just trigger UI rebuild - filtering is now done locally in _buildQuizGrid
    setState(() {});
  }

  String _getCategoryName(QuizEntity quiz) {
    if (quiz.categoryId != null) {
      final categoryProvider = context.read<CategoryProvider>();
      try {
        final category = categoryProvider.categories.firstWhere(
          (cat) => cat.categoryId == quiz.categoryId,
        );
        return category.name;
      } catch (e) {
        return 'Chưa phân loại';
      }
    }
    return 'Chưa phân loại';
  }
}
