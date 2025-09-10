import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/result_entity.dart';
import '../../providers/result_provider.dart';
import '../../providers/auth_provider.dart';
import '../quiz/quiz_player_screen.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserHistory();
  }

  void _loadUserHistory() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final resultProvider = context.read<ResultProvider>();

      if (authProvider.user != null) {
        resultProvider.loadUserResults(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Lịch sử làm quiz',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer2<ResultProvider, AuthProvider>(
        builder: (context, resultProvider, authProvider, child) {
          if (authProvider.user == null) {
            return _buildNotLoggedIn();
          }

          if (resultProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (resultProvider.hasError) {
            return _buildErrorState(
              resultProvider.errorMessage ?? 'Có lỗi xảy ra',
            );
          }

          final userResults = resultProvider.userResults;

          if (userResults.isEmpty) {
            return _buildEmptyState();
          }

          return _buildHistoryList(userResults);
        },
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          Text(
            'Vui lòng đăng nhập',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Để xem lịch sử làm quiz của bạn',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserHistory,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch sử',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy làm một vài quiz để xem lịch sử ở đây',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<ResultEntity> results) {
    // Sort by completion date (newest first)
    final sortedResults = List<ResultEntity>.from(results)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return RefreshIndicator(
      onRefresh: () async {
        _loadUserHistory();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: sortedResults.length,
        itemBuilder: (context, index) {
          final result = sortedResults[index];
          return _buildHistoryCard(result);
        },
      ),
    );
  }

  Widget _buildHistoryCard(ResultEntity result) {
    final percentage = (result.score / result.totalQuestions * 100).round();
    final isGoodScore = percentage >= 70;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _retakeQuiz(result.quizId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with quiz title and score
              Row(
                children: [
                  Expanded(
                    child: Text(
                      result.quizTitle,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isGoodScore
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$percentage%',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isGoodScore ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  _buildStatChip(
                    Icons.quiz,
                    '${result.score}/${result.totalQuestions}',
                    AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.timer,
                    _formatDuration(result.totalTimeSpent),
                    Colors.orange,
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(result.completedAt),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Performance indicator
              LinearProgressIndicator(
                value: result.score / result.totalQuestions,
                backgroundColor: AppColors.lightGrey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isGoodScore ? Colors.green : Colors.orange,
                ),
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

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _retakeQuiz(String quizId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            QuizPlayerScreen(quizId: quizId, enableTimer: true),
      ),
    );
  }
}
