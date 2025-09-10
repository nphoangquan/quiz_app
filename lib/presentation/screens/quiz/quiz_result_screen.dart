import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/result_entity.dart';
import '../../../domain/entities/question_entity.dart';
import '../../providers/quiz_player_provider.dart';
import '../../providers/result_provider.dart';
import '../../widgets/common/confetti_widget.dart';
import 'quiz_player_screen.dart';
import 'answer_review_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final ResultEntity result;

  const QuizResultScreen({super.key, required this.result});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _celebrationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(begin: 0.0, end: widget.result.percentage)
        .animate(
          CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
        );

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scoreController.forward();
      if (widget.result.percentage >= 80) {
        _celebrationController.forward();
      }
    });

    // Load related data
    _loadResultData();
  }

  void _loadResultData() {
    final resultProvider = context.read<ResultProvider>();
    resultProvider.loadUserResults(widget.result.userId);
    resultProvider.loadQuizResults(widget.result.quizId);
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Main result card
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    // Score circle
                    _buildScoreCircle(),

                    const SizedBox(height: 24),

                    // Result message
                    _buildResultMessage(),

                    const SizedBox(height: 32),

                    // Stats cards
                    _buildStatsCards(),

                    const SizedBox(height: 24),

                    // Performance breakdown
                    _buildPerformanceBreakdown(),

                    const SizedBox(height: 24),

                    // Action buttons
                    _buildActionButtons(),

                    const SizedBox(height: 32),

                    // Answer review
                    _buildAnswerReview(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.white),
          ),
          Expanded(
            child: Text(
              'Kết quả Quiz',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => _shareResult(),
            icon: const Icon(Icons.share, color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Confetti animation
        if (widget.result.percentage >= 80)
          AnimatedBuilder(
            animation: _celebrationAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _celebrationAnimation.value,
                child: const ConfettiWidget(),
              );
            },
          ),

        // Score circle
        AnimatedBuilder(
          animation: _scoreAnimation,
          builder: (context, child) {
            return Container(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  // Background circle
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withOpacity(0.2),
                    ),
                  ),

                  // Progress circle
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _scoreAnimation.value / 100,
                      strokeWidth: 12,
                      backgroundColor: AppColors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(widget.result.percentage),
                      ),
                    ),
                  ),

                  // Score text
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_scoreAnimation.value.toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          '${widget.result.score}/${widget.result.totalQuestions} đúng',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultMessage() {
    final message = _getResultMessage(widget.result.percentage);
    final emoji = _getResultEmoji(widget.result.percentage);

    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.result.percentage >= 80
              ? 0.8 + (_celebrationAnimation.value * 0.2)
              : 1.0,
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getEncouragementMessage(widget.result.percentage),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Thời gian',
            _formatTime(widget.result.totalTimeSpent),
            Icons.timer,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Điểm số',
            '${widget.result.score}',
            Icons.stars,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Độ chính xác',
            '${widget.result.percentage.toInt()}%',
            Icons.gps_fixed,
            _getScoreColor(widget.result.percentage),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
            title,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBreakdown() {
    final correctAnswers = widget.result.score;
    final wrongAnswers = widget.result.totalQuestions - widget.result.score;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân tích kết quả',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 16),

          // Correct answers
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Câu trả lời đúng',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              Text(
                '$correctAnswers',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Wrong answers
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Câu trả lời sai',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              Text(
                '$wrongAnswers',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          LinearProgressIndicator(
            value: widget.result.percentage / 100,
            backgroundColor: Colors.red.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _retakeQuiz(),
                icon: const Icon(Icons.refresh),
                label: const Text('Làm lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: _getBackgroundColor(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _reviewAnswers(),
                icon: const Icon(Icons.quiz),
                label: const Text('Xem đáp án'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white.withOpacity(0.2),
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.white),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Secondary actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareResult(),
                icon: const Icon(Icons.share),
                label: const Text('Chia sẻ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.white),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _goHome(),
                icon: const Icon(Icons.home),
                label: const Text('Về trang chủ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.white),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerReview() {
    return Consumer<QuizPlayerProvider>(
      builder: (context, quizPlayer, child) {
        if (widget.result.answers.isEmpty) {
          return Container();
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Chi tiết câu trả lời',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _reviewAnswers(),
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Show first few answers as preview
              ...widget.result.answers.take(3).map((answer) {
                return _buildAnswerPreview(answer);
              }).toList(),

              if (widget.result.answers.length > 3) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'và ${widget.result.answers.length - 3} câu khác...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnswerPreview(UserAnswer answer) {
    final isCorrect = answer.isCorrect;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Question number
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${widget.result.answers.indexOf(answer) + 1}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Result icon
          Icon(
            isCorrect ? Icons.check : Icons.close,
            color: isCorrect ? Colors.green : Colors.red,
            size: 16,
          ),

          const SizedBox(width: 8),

          // Answer text (truncated)
          Expanded(
            child: Text(
              answer.selectedAnswer,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.darkGrey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Time spent
          if (answer.timeSpent > 0)
            Text(
              '${answer.timeSpent}s',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.result.percentage >= 80) {
      return Colors.green.shade400;
    } else if (widget.result.percentage >= 60) {
      return Colors.orange.shade400;
    } else {
      return Colors.red.shade400;
    }
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getResultMessage(double percentage) {
    if (percentage >= 90) {
      return 'Xuất sắc!';
    } else if (percentage >= 80) {
      return 'Tốt lắm!';
    } else if (percentage >= 70) {
      return 'Khá tốt!';
    } else if (percentage >= 60) {
      return 'Tạm được!';
    } else {
      return 'Cần cố gắng hơn!';
    }
  }

  String _getResultEmoji(double percentage) {
    if (percentage >= 90) {
      return '🎉';
    } else if (percentage >= 80) {
      return '😊';
    } else if (percentage >= 70) {
      return '🙂';
    } else if (percentage >= 60) {
      return '😐';
    } else {
      return '😔';
    }
  }

  String _getEncouragementMessage(double percentage) {
    if (percentage >= 90) {
      return 'Bạn thực sự là một thiên tài!';
    } else if (percentage >= 80) {
      return 'Kiến thức của bạn rất vững vàng!';
    } else if (percentage >= 70) {
      return 'Bạn đã làm tốt, tiếp tục phát huy!';
    } else if (percentage >= 60) {
      return 'Không sao, bạn sẽ làm tốt hơn lần sau!';
    } else {
      return 'Đừng nản lòng, hãy thử lại và học hỏi thêm!';
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  void _retakeQuiz() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizPlayerScreen(
          quizId: widget.result.quizId,
          enableTimer: false, // Can be made configurable
        ),
      ),
    );
  }

  void _reviewAnswers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnswerReviewScreen(result: widget.result),
      ),
    );
  }

  void _shareResult() {
    // Implement share functionality
    final message =
        '''
🎯 Tôi vừa hoàn thành quiz "${widget.result.quizTitle}"!

📊 Kết quả:
• Điểm số: ${widget.result.score}/${widget.result.totalQuestions}
• Độ chính xác: ${widget.result.percentage.toInt()}%
• Thời gian: ${_formatTime(widget.result.totalTimeSpent)}

${_getResultMessage(widget.result.percentage)} ${_getResultEmoji(widget.result.percentage)}

#QuizApp #Learning
    ''';

    // Here you would integrate with share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chia sẻ: $message'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _goHome() {
    // Navigate back to home screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
