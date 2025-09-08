import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';
import '../create/enhanced_create_quiz_screen.dart';
import '../create/quiz_preview_screen.dart';

class MyQuizzesScreen extends StatefulWidget {
  const MyQuizzesScreen({super.key});

  @override
  State<MyQuizzesScreen> createState() => _MyQuizzesScreenState();
}

class _MyQuizzesScreenState extends State<MyQuizzesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserQuizzes();
    });
  }

  void _loadUserQuizzes() {
    final authProvider = context.read<AuthProvider>();
    final quizProvider = context.read<QuizProvider>();

    if (authProvider.user != null) {
      quizProvider.loadUserQuizzes(authProvider.user!.uid);
    }
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
      appBar: AppBar(
        title: Text(
          'Quiz của tôi',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 20),
                    SizedBox(width: 12),
                    Text('Mới nhất'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20),
                    SizedBox(width: 12),
                    Text('Cũ nhất'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'title',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 20),
                    SizedBox(width: 12),
                    Text('Theo tên'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'popular',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 20),
                    SizedBox(width: 12),
                    Text('Phổ biến'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Công khai'),
            Tab(text: 'Riêng tư'),
          ],
        ),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildQuizList(quizProvider.userQuizzes, 'all'),
              _buildQuizList(
                quizProvider.userQuizzes.where((q) => q.isPublic).toList(),
                'public',
              ),
              _buildQuizList(
                quizProvider.userQuizzes.where((q) => !q.isPublic).toList(),
                'private',
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateQuiz(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text(
          'Tạo Quiz',
          style: GoogleFonts.inter(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizList(List<QuizEntity> quizzes, String type) {
    // Sort quizzes
    final sortedQuizzes = List<QuizEntity>.from(quizzes);
    switch (_sortBy) {
      case 'newest':
        sortedQuizzes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'oldest':
        sortedQuizzes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case 'title':
        sortedQuizzes.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'popular':
        sortedQuizzes.sort(
          (a, b) => b.stats.totalAttempts.compareTo(a.stats.totalAttempts),
        );
        break;
    }

    if (sortedQuizzes.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadUserQuizzes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: sortedQuizzes.length,
        itemBuilder: (context, index) {
          return _buildQuizCard(sortedQuizzes[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String title;
    String subtitle;
    IconData icon;

    switch (type) {
      case 'public':
        title = 'Chưa có quiz công khai';
        subtitle = 'Tạo quiz và chia sẻ với mọi người';
        icon = Icons.public;
        break;
      case 'private':
        title = 'Chưa có quiz riêng tư';
        subtitle = 'Tạo quiz chỉ dành cho bạn';
        icon = Icons.lock;
        break;
      default:
        title = 'Chưa có quiz nào';
        subtitle = 'Tạo quiz đầu tiên của bạn ngay bây giờ';
        icon = Icons.quiz_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.grey.withOpacity(0.5)),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 16, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateQuiz(),
            icon: const Icon(Icons.add, color: AppColors.white),
            label: Text(
              'Tạo Quiz',
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizEntity quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToQuizPreview(quiz),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getCategoryName(quiz.category),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Privacy indicator
                  Icon(
                    quiz.isPublic ? Icons.public : Icons.lock,
                    size: 16,
                    color: quiz.isPublic ? Colors.green : Colors.orange,
                  ),

                  const Spacer(),

                  // More options
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleQuizAction(value, quiz),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'preview',
                        child: Row(
                          children: [
                            Icon(Icons.preview, size: 20),
                            SizedBox(width: 12),
                            Text('Xem trước'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 12),
                            Text('Nhân bản'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 20),
                            SizedBox(width: 12),
                            Text('Chia sẻ'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'stats',
                        child: Row(
                          children: [
                            Icon(Icons.analytics, size: 20),
                            SizedBox(width: 12),
                            Text('Thống kê'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 20,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Xóa',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Quiz title
              Text(
                quiz.title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Quiz description
              Text(
                quiz.description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.grey,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Quiz stats
              Row(
                children: [
                  _buildStatChip(
                    Icons.quiz,
                    '${quiz.questionCount} câu hỏi',
                    AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    Icons.people,
                    '${quiz.stats.totalAttempts} lượt chơi',
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    Icons.star,
                    '${quiz.stats.rating.toStringAsFixed(1)}★',
                    Colors.amber,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tags
              if (quiz.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: quiz.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$tag',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Footer
              Row(
                children: [
                  Text(
                    'Cập nhật: ${_formatDate(quiz.updatedAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(
                        quiz.difficulty,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getDifficultyName(quiz.difficulty),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getDifficultyColor(quiz.difficulty),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleQuizAction(String action, QuizEntity quiz) {
    switch (action) {
      case 'preview':
        _navigateToQuizPreview(quiz);
        break;
      case 'edit':
        _editQuiz(quiz);
        break;
      case 'duplicate':
        _duplicateQuiz(quiz);
        break;
      case 'share':
        _shareQuiz(quiz);
        break;
      case 'stats':
        _viewQuizStats(quiz);
        break;
      case 'delete':
        _deleteQuiz(quiz);
        break;
    }
  }

  void _navigateToCreateQuiz() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EnhancedCreateQuizScreen()),
    );

    if (result == true) {
      _loadUserQuizzes();
    }
  }

  void _navigateToQuizPreview(QuizEntity quiz) async {
    final quizProvider = context.read<QuizProvider>();

    // Load questions for the quiz
    final questions = await quizProvider.quizRepository.getQuizQuestionsOnce(
      quiz.quizId,
    );

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              QuizPreviewScreen(quiz: quiz, questions: questions),
        ),
      );
    }
  }

  void _editQuiz(QuizEntity quiz) async {
    final quizProvider = context.read<QuizProvider>();

    // Load quiz for editing
    await quizProvider.loadQuizForEditing(quiz.quizId);

    if (mounted) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const EnhancedCreateQuizScreen(),
        ),
      );

      if (result == true) {
        _loadUserQuizzes();
      }
    }
  }

  void _duplicateQuiz(QuizEntity quiz) {
    // TODO: Implement quiz duplication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tính năng nhân bản quiz sẽ có trong phiên bản tiếp theo',
        ),
      ),
    );
  }

  void _shareQuiz(QuizEntity quiz) {
    // TODO: Implement quiz sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng chia sẻ quiz sẽ có trong phiên bản tiếp theo'),
      ),
    );
  }

  void _viewQuizStats(QuizEntity quiz) {
    // TODO: Implement quiz statistics view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tính năng thống kê quiz sẽ có trong phiên bản tiếp theo',
        ),
      ),
    );
  }

  void _deleteQuiz(QuizEntity quiz) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc chắn muốn xóa quiz "${quiz.title}"?\n\nHành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final quizProvider = context.read<QuizProvider>();
                final success = await quizProvider.deleteQuiz(quiz.quizId);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Quiz đã được xóa thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
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

  String _getDifficultyName(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return 'Dễ';
      case QuizDifficulty.intermediate:
        return 'Trung bình';
      case QuizDifficulty.advanced:
        return 'Khó';
    }
  }

  Color _getDifficultyColor(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return Colors.green;
      case QuizDifficulty.intermediate:
        return Colors.orange;
      case QuizDifficulty.advanced:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
