import 'package:flutter/material.dart';
import 'package:oste/features/education/tahukah_anda/painters/seedling_painter.dart';

/// 1. Ilustrasi Lansia 50+ dengan Ikon Tulang
class BoneIllustration extends StatelessWidget {
  const BoneIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset(
        'assets/images/elderly_50plus_bone.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// 2. Ilustrasi Wanita Mengangkat Dumbbell dengan Ikon Tulang & Panah ke Atas
class ExercisePersonIllustration extends StatelessWidget {
  const ExercisePersonIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset(
        'assets/images/bone_peak_exercise.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// 3. Ilustrasi Tulang dengan Matahari & Ikon Vitamin D
class SunIllustration extends StatelessWidget {
  const SunIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset(
        'assets/images/sun_vitamin_d_bone.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// 4. Ilustrasi Sumber Kalsium (Susu, Salmon, Tahu, Brokoli, Bayam, dan Kacang-kacangan)
class FoodPlateIllustration extends StatelessWidget {
  const FoodPlateIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset(
        'assets/images/calcium_rich_foods.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// 5. Ilustrasi Gaya Hidup (Aktivitas Olahraga Berlari, Larangan Merokok, Minuman Beralkohol)
class HealthyHabitIllustration extends StatelessWidget {
  const HealthyHabitIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset(
        'assets/images/healthy_lifestyle_habits.png',
        fit: BoxFit.contain,
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
