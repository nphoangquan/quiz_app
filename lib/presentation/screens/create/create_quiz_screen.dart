import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';
import 'enhanced_create_quiz_screen.dart';
import '../profile/my_quizzes_screen.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  @override
  void initState() {
    super.initState();
    // Auto load user statistics when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserStatistics();
    });
  }

  void _loadUserStatistics() {
    final authProvider = context.read<AuthProvider>();
    final quizProvider = context.read<QuizProvider>();

    if (authProvider.user != null) {
      // Load user quizzes to get statistics
      quizProvider.loadUserQuizzes(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Tạo Quiz',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading:
            false, // Remove back button since this is in a tab
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.quiz, size: 64, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Tạo Quiz Mới',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tạo quiz của riêng bạn và chia sẻ với mọi người',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Expanded(
                child: Column(
                  children: [
                    // Create new quiz button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToCreateQuiz(context),
                        icon: const Icon(Icons.add, size: 24),
                        label: Text(
                          'Tạo Quiz Mới',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // My quizzes button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToMyQuizzes(context),
                        icon: const Icon(Icons.library_books, size: 24),
                        label: Text(
                          'Quiz Của Tôi',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Quick stats
                    Consumer<QuizProvider>(
                      builder: (context, quizProvider, child) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Thống kê của bạn',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    'Quiz đã tạo',
                                    '${quizProvider.userQuizzes.length}',
                                    Icons.quiz,
                                    AppColors.primary,
                                  ),
                                  _buildStatItem(
                                    'Câu hỏi',
                                    '${quizProvider.totalQuestionsCount}',
                                    Icons.help_outline,
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const Spacer(),

                    // Tips section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Mẹo: Tạo quiz với nhiều loại câu hỏi khác nhau để tăng tính thú vị!',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _navigateToCreateQuiz(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EnhancedCreateQuizScreen()),
    );

    if (result == true) {
      // Quiz was created successfully, refresh the provider
      if (context.mounted) {
        final quizProvider = context.read<QuizProvider>();
        final authProvider = context.read<AuthProvider>();

        // Refresh user quizzes if user is authenticated
        if (authProvider.user != null) {
          quizProvider.loadUserQuizzes(authProvider.user!.uid);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Quiz đã được tạo thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToMyQuizzes(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final quizProvider = context.read<QuizProvider>();

    if (authProvider.user != null) {
      // Load user quizzes first
      quizProvider.loadUserQuizzes(authProvider.user!.uid);

      // Navigate to My Quizzes screen and wait for result
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const MyQuizzesScreen()));

      // Refresh statistics when coming back
      if (context.mounted) {
        _loadUserStatistics();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để xem quiz của bạn!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
