import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../../domain/entities/category_entity.dart';
// import '../../../core/utils/category_mapper.dart';
import '../../providers/category_provider.dart';
import '../../widgets/quiz/quiz_card.dart';
import '../../providers/quiz_provider.dart';
import '../quiz/quiz_player_screen.dart';

class CategoryFilterScreen extends StatefulWidget {
  final CategoryEntity? initialCategory;
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const CategoryFilterScreen({
    super.key,
    this.initialCategory,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  State<CategoryFilterScreen> createState() => _CategoryFilterScreenState();
}

class _CategoryFilterScreenState extends State<CategoryFilterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  CategoryEntity? _selectedCategory;
  QuizDifficulty? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedCategory = widget.initialCategory;

    // Load category quizzes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoryQuizzes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Reset shared provider filters to avoid affecting home screen
    final quizProvider = context.read<QuizProvider>();
    quizProvider.clearAllFilters();
    super.dispose();
  }

  void _loadCategoryQuizzes() {
    // Load all public quizzes without affecting shared provider state
    final quizProvider = context.read<QuizProvider>();
    quizProvider.loadPublicQuizzes(); // Load all quizzes, filter locally
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại trang chủ',
        ),
        title: Text(
          'Danh mục',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(
              Icons.tune,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            return Column(
              children: [
                // Search Bar
                _buildSearchBar(),

                // Filter Chips
                _buildFilterChips(),

                // Tab Bar
                _buildTabBar(),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllQuizzes(quizProvider),
                      _buildPopularQuizzes(quizProvider),
                      _buildNewestQuizzes(quizProvider),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.home),
        label: Text(
          'Về trang chủ',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm trong ${widget.categoryName.toLowerCase()}...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                    _loadCategoryQuizzes();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Category Filter
          _buildFilterChip(
            'Danh mục: ${_selectedCategory != null ? _selectedCategory!.name : "Tất cả"}',
            _selectedCategory != null,
            () => _showCategoryPicker(),
          ),
          const SizedBox(width: 8),
          // Difficulty Filter
          _buildFilterChip(
            'Độ khó: ${_getDifficultyDisplayName(_selectedDifficulty)}',
            _selectedDifficulty != null,
            () => _showDifficultyPicker(),
          ),
          const SizedBox(width: 8),
          // Clear filters
          if (_selectedDifficulty != null)
            _buildFilterChip(
              'Xóa bộ lọc',
              false,
              _clearFilters,
              isAction: true,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    bool isAction = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : isAction
              ? AppColors.error.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isAction
                ? AppColors.error
                : AppColors.lightGrey,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? AppColors.primary
                : isAction
                ? AppColors.error
                : Theme.of(context).textTheme.bodyMedium?.color,
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
          Tab(text: 'Phổ biến'),
          Tab(text: 'Mới nhất'),
        ],
      ),
    );
  }

  Widget _buildAllQuizzes(QuizProvider quizProvider) {
    return _buildQuizGrid(quizProvider, sortAlphabetically: true);
  }

  Widget _buildPopularQuizzes(QuizProvider quizProvider) {
    return _buildQuizGrid(quizProvider, sortByPopularity: true);
  }

  Widget _buildNewestQuizzes(QuizProvider quizProvider) {
    return _buildQuizGrid(quizProvider, sortByDate: true);
  }

  Widget _buildQuizGrid(
    QuizProvider quizProvider, {
    bool sortAlphabetically = false,
    bool sortByPopularity = false,
    bool sortByDate = false,
  }) {
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
              onPressed: _loadCategoryQuizzes,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Filter and sort quizzes
    var quizzes = List<QuizEntity>.from(quizProvider.publicQuizzes);

    // Apply category filter
    if (_selectedCategory != null) {
      quizzes = quizzes
          .where((quiz) => quiz.categoryId == _selectedCategory!.categoryId)
          .toList();
    }

    // Apply difficulty filter
    if (_selectedDifficulty != null) {
      quizzes = quizzes
          .where((quiz) => quiz.difficulty == _selectedDifficulty)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      quizzes = quizzes.where((quiz) {
        return quiz.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            quiz.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            quiz.tags.any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
            );
      }).toList();
    }

    // Apply sorting
    if (sortByPopularity) {
      // Sắp xếp theo số lượt hoàn thành (totalAttempts) từ cao đến thấp
      quizzes.sort(
        (a, b) => b.stats.totalAttempts.compareTo(a.stats.totalAttempts),
      );
    } else if (sortByDate) {
      // Sắp xếp theo thời gian tạo quiz (mới nhất trước)
      quizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortAlphabetically) {
      // Sắp xếp theo tên quiz từ A-Z
      quizzes.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    }

    if (quizzes.isEmpty) {
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
              'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadCategoryQuizzes();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: double.infinity,
              child: QuizCard(
                quiz: quizzes[index],
                onTap: () => _navigateToQuizPlayer(context, quizzes[index]),
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
        builder: (context) =>
            QuizPlayerScreen(quizId: quiz.quizId, enableTimer: true),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadCategoryQuizzes();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Bộ lọc',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _clearFilters();
                        setModalState(() {}); // Update modal UI
                      },
                      child: Text(
                        'Xóa tất cả',
                        style: GoogleFonts.inter(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Section
                  _buildFilterSection('Danh mục', _buildCategoryOptions()),
                  const SizedBox(height: 24),

                  // Difficulty Section
                  _buildFilterSection('Độ khó', _buildDifficultyOptions()),
                ],
              ),
            ),
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _loadCategoryQuizzes();
                },
                child: const Text('Áp dụng'),
              ),
            ),
          ),
        ],
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

  Widget _buildCategoryOptions() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final dynamicCategories = categoryProvider.categories;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // "Tất cả danh mục"
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                    setModalState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedCategory == null
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: _selectedCategory == null
                            ? AppColors.primary
                            : AppColors.lightGrey,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tất cả danh mục',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _selectedCategory == null
                            ? AppColors.primary
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
                // Dynamic categories from Firestore
                ...dynamicCategories.map((cat) {
                  final isSelected =
                      _selectedCategory?.categoryId == cat.categoryId;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                      setModalState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.lightGrey,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).textTheme.bodyMedium?.color,
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

  Widget _buildDifficultyOptions() {
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
            final isSelected = _selectedDifficulty == difficulty;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDifficulty = difficulty;
                });
                setModalState(() {}); // Update modal UI
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.lightGrey,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showCategoryPicker() {
    // Implementation for category picker
    _showFilterDialog();
  }

  void _showDifficultyPicker() {
    // Implementation for difficulty picker
    _showFilterDialog();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null; // Clear category selection
      _selectedDifficulty = null;
      _searchQuery = '';
    });
    _loadCategoryQuizzes();
  }

  String _getDifficultyDisplayName(QuizDifficulty? difficulty) {
    if (difficulty == null) return 'Tất cả';
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return 'Dễ';
      case QuizDifficulty.intermediate:
        return 'Trung bình';
      case QuizDifficulty.advanced:
        return 'Khó';
    }
  }
}
