import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomHeaderBs extends StatelessWidget {
  const CustomHeaderBs({super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: colors.grey8,
              borderRadius: BorderRadius.circular(1000),
            ),
          ),
        ],
      );
}
