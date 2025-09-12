import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../core/utils/category_mapper.dart';
import '../../widgets/quiz/quiz_card.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/category_provider.dart';
import '../quiz/quiz_player_screen.dart';
import '../category/category_filter_screen.dart';

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
          IconButton(
            onPressed: _showAdvancedFilterDialog,
            icon: Icon(
              Icons.tune,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm quiz...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
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
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            children: [
              _buildCategoryChip('Tất cả', null),
              const SizedBox(width: 8),
              ...categoryProvider.categories
                  .map(
                    (category) => [
                      _buildCategoryChip(category.name, category),
                      const SizedBox(width: 8),
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
    return GestureDetector(
      onTap: () {
        if (category == null) {
          // Clear filters and reload all quizzes
          final quizProvider = context.read<QuizProvider>();
          quizProvider.clearAllFilters();
          quizProvider.loadPublicQuizzes();
        } else {
          // Navigate to category screen
          final categoryProvider = context.read<CategoryProvider>();
          final categoryColor = categoryProvider.getCategoryColor(
            category.categoryId,
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategoryFilterScreen(
                initialCategory: CategoryMapper.slugToEnum(category.slug),
                categoryName: category.name,
                categoryColor: categoryColor,
                categoryIcon: Icons.category,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
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
        unselectedLabelColor: AppColors.grey,
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
        // First sort by category
        final categoryComparison = a.category.name.compareTo(b.category.name);
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
      final matchesSearch =
          _searchQuery.isEmpty ||
          quiz.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          quiz.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
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

    // Trigger search in provider and reload quizzes
    final quizProvider = context.read<QuizProvider>();
    quizProvider.updateSearchQuery(query);
    quizProvider.loadPublicQuizzes(); // Reload with new search query
  }

  void _showAdvancedFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Bộ lọc nâng cao',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: Text(
                      'Xóa tất cả',
                      style: GoogleFonts.inter(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Filter Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildFilterSection(
                      'Danh mục',
                      _buildAdvancedCategoryOptions(),
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      'Độ khó',
                      _buildAdvancedDifficultyOptions(),
                    ),
                  ],
                ),
              ),
            ),

            // Apply Button
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildAdvancedCategoryOptions() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categories;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
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
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedFilterCategory == null
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: _selectedFilterCategory == null
                            ? AppColors.primary
                            : Colors.grey.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tất cả danh mục',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _selectedFilterCategory == null
                            ? AppColors.primary
                            : Colors.grey[600],
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
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[600],
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

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
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
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.primary : Colors.grey[600],
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

    final quizProvider = context.read<QuizProvider>();
    quizProvider.clearAllFilters();
    quizProvider.loadPublicQuizzes();
  }

  void _applyFilters() {
    final quizProvider = context.read<QuizProvider>();

    // Convert CategoryEntity to QuizCategory enum if needed
    QuizCategory? categoryEnum;
    if (_selectedFilterCategory != null) {
      categoryEnum = CategoryMapper.slugToEnum(_selectedFilterCategory!.slug);
    }

    // Apply filters
    quizProvider.loadPublicQuizzes(
      category: categoryEnum,
      difficulty: _selectedFilterDifficulty,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
    );
  }
}
