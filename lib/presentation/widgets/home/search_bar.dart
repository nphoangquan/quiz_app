import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to search screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tính năng tìm kiếm sẽ có trong phiên bản tiếp theo'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.lightGrey.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tìm kiếm quiz, chủ đề...',
                style: GoogleFonts.inter(fontSize: 16, color: AppColors.grey),
              ),
            ),
            Icon(Icons.tune, color: AppColors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
