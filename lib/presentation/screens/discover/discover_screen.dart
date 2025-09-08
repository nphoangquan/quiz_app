import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../widgets/quiz/quiz_card.dart';
import '../../providers/quiz_provider.dart';
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
  QuizCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

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
                      _buildTrendingQuizzes(quizProvider),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Tính năng lọc sẽ có trong phiên bản tiếp theo',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
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
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
        ),
        children: [
          _buildFilterChip(
            'Tất cả',
            _selectedCategory == null,
            () => setState(() => _selectedCategory = null),
          ),
          const SizedBox(width: 8),
          ...QuizCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                _getCategoryName(category),
                _selectedCategory == category,
                () => setState(() => _selectedCategory = category),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.grey,
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
          Tab(text: 'Thịnh hành'),
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

    return _buildQuizGrid(quizProvider.publicQuizzes);
  }

  Widget _buildTrendingQuizzes(QuizProvider quizProvider) {
    if (quizProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Sort by total attempts for trending
    final trendingQuizzes = List<QuizEntity>.from(quizProvider.publicQuizzes)
      ..sort((a, b) => b.stats.totalAttempts.compareTo(a.stats.totalAttempts));

    return _buildQuizGrid(trendingQuizzes.take(10).toList());
  }

  Widget _buildNewQuizzes(QuizProvider quizProvider) {
    if (quizProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Sort by creation date for newest
    final newQuizzes = List<QuizEntity>.from(quizProvider.publicQuizzes)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return _buildQuizGrid(newQuizzes.take(10).toList());
  }

  Widget _buildQuizGrid(List<QuizEntity> quizzes) {
    var filteredQuizzes = quizzes.where((quiz) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          quiz.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          quiz.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || quiz.category == _selectedCategory;
      return matchesSearch && matchesCategory;
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

  String _getCategoryName(QuizCategory category) {
    switch (category) {
      case QuizCategory.programming:
        return 'Lập trình';
      case QuizCategory.mathematics:
        return 'Toán học';
      case QuizCategory.science:
        return 'Khoa học';
      case QuizCategory.history:
        return 'Lịch sử';
      case QuizCategory.language:
        return 'Ngôn ngữ';
      case QuizCategory.geography:
        return 'Địa lý';
      case QuizCategory.sports:
        return 'Thể thao';
      case QuizCategory.entertainment:
        return 'Giải trí';
      case QuizCategory.general:
        return 'Tổng hợp';
    }
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

    // Trigger search in provider if needed
    final quizProvider = context.read<QuizProvider>();
    quizProvider.updateSearchQuery(query);
  }
}
