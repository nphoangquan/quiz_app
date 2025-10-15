import 'package:flutter/material.dart';
import '../../../domain/entities/quiz_entity.dart';
import 'animated_quiz_card.dart';

class QuizCard extends StatelessWidget {
  final QuizEntity quiz;
  final VoidCallback? onTap;

  const QuizCard({super.key, required this.quiz, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedQuizCard(
      quiz: quiz,
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Quiz "${quiz.title}" sẽ có trong phiên bản tiếp theo',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
    );
  }
}
