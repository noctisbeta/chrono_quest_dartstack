import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredWidget extends StatelessWidget {
  const BlurredWidget({
    required this.child,
    required this.isBlurring,
    super.key,
  });
  final Widget child;

  final bool isBlurring;

  @override
  Widget build(BuildContext context) =>
      isBlurring
          ? ClipRRect(
            child: Stack(
              children: [
                child,
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0),
                            spreadRadius: 5,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
          : child;
}
