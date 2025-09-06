import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../widgets/quiz/quiz_card.dart';

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
        child: Column(
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
                  _buildAllQuizzes(),
                  _buildTrendingQuizzes(),
                  _buildNewQuizzes(),
                ],
              ),
            ),
          ],
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
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
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

  Widget _buildAllQuizzes() {
    return _buildQuizGrid(_sampleAllQuizzes);
  }

  Widget _buildTrendingQuizzes() {
    return _buildQuizGrid(_sampleTrendingQuizzes);
  }

  Widget _buildNewQuizzes() {
    return _buildQuizGrid(_sampleNewQuizzes);
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
              child: QuizCard(quiz: filteredQuizzes[index]),
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
}

// Sample data - will be replaced with real Firestore data
final List<QuizEntity> _sampleAllQuizzes = [
  // Mix of all quizzes
  ..._sampleTrendingQuizzes,
  ..._sampleNewQuizzes,
];

final List<QuizEntity> _sampleTrendingQuizzes = [
  QuizEntity(
    quizId: 't1',
    title: 'React Hooks Advanced',
    description: 'Master advanced React Hooks patterns and best practices',
    ownerId: 'user_t1',
    ownerName: 'Sarah Johnson',
    tags: ['react', 'hooks', 'javascript', 'frontend'],
    category: QuizCategory.programming,
    isPublic: true,
    questionCount: 25,
    difficulty: QuizDifficulty.advanced,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    stats: const QuizStats(
      totalAttempts: 3456,
      averageScore: 79.2,
      likes: 567,
      rating: 4.9,
      ratingCount: 789,
    ),
  ),
  // Add more trending quizzes...
];

final List<QuizEntity> _sampleNewQuizzes = [
  QuizEntity(
    quizId: 'n1',
    title: 'Flutter 3.0 New Features',
    description: 'Explore the latest features introduced in Flutter 3.0',
    ownerId: 'user_n1',
    ownerName: 'Alex Chen',
    tags: ['flutter', 'dart', 'mobile', 'new'],
    category: QuizCategory.programming,
    isPublic: true,
    questionCount: 18,
    difficulty: QuizDifficulty.intermediate,
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    stats: const QuizStats(
      totalAttempts: 23,
      averageScore: 85.1,
      likes: 12,
      rating: 4.7,
      ratingCount: 8,
    ),
  ),
  // Add more new quizzes...
];
