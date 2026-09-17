import 'package:flutter/material.dart';
import 'package:oste/features/education/tahukah_anda/painters/bone_painter.dart';
import 'package:oste/features/education/tahukah_anda/painters/exercise_painter.dart';
import 'package:oste/features/education/tahukah_anda/painters/food_painter.dart';
import 'package:oste/features/education/tahukah_anda/painters/healthy_habit_painter.dart';
import 'package:oste/features/education/tahukah_anda/painters/seedling_painter.dart';
import 'package:oste/features/education/tahukah_anda/painters/sun_painter.dart';

/// 1. Ilustrasi Tulang Emas dengan Percikan
class BoneIllustration extends StatelessWidget {
  const BoneIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 80,
      height: 75,
      child: CustomPaint(
        painter: BonePainter(),
      ),
    );
  }
}

/// 2. Ilustrasi Orang Berolahraga / Peregangan
class ExercisePersonIllustration extends StatelessWidget {
  const ExercisePersonIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: ExercisePainter(),
      ),
    );
  }
}

/// 3. Ilustrasi Matahari Bersinar Hangat
class SunIllustration extends StatelessWidget {
  const SunIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 75,
      height: 75,
      child: CustomPaint(
        painter: SunPainter(),
      ),
    );
  }
}

/// 4. Ilustrasi Piring Makanan Bergizi & Susu
class FoodPlateIllustration extends StatelessWidget {
  const FoodPlateIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 85,
      height: 75,
      child: CustomPaint(
        painter: FoodPainter(),
      ),
    );
  }
}

/// 5. Ilustrasi Tanda Larangan Merokok / Pola Hidup Sehat
class HealthyHabitIllustration extends StatelessWidget {
  const HealthyHabitIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 75,
      height: 75,
      child: CustomPaint(
        painter: HealthyHabitPainter(),
      ),
    );
  }
}

/// 6. Ilustrasi Tunas Tanaman untuk Banner Bawah
class SeedlingIllustration extends StatelessWidget {
  const SeedlingIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: SeedlingPainter(),
      ),
    );
  }
}
