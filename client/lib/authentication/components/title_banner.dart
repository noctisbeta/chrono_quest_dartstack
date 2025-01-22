import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:flutter/material.dart';

class TitleBanner extends StatelessWidget {
  const TitleBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(kPadding),
        decoration: BoxDecoration(
          color: kSecondaryColor,
          
          borderRadius: BorderRadius.circular(kBorderRadius * 10),
        ),
        child: const Center(
          child: Text(
            'ChronoQuest',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
}
