import 'package:flutter/material.dart';
import 'package:oste/features/screening/hasil_page.dart';

/// Data input lengkap dari formulir skrining osteoporosis
class ScreeningInput {
  final int age;
  final String gender;
  final double height;
  final double weight;
  final double bmi;
  final String bmiCategory;
  final String hormonal;
  final String race;
  final String alcohol;
  final String smoking;
  final String calcium;
  final String vitaminD;
  final String physicalActivity;
  final String medicalCondition;
  final String medication;
  final String fractureHistory;

  const ScreeningInput({
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.bmiCategory,
    required this.hormonal,
    required this.race,
    required this.alcohol,
    required this.smoking,
    required this.calcium,
    required this.vitaminD,
    required this.physicalActivity,
    required this.medicalCondition,
    required this.medication,
    required this.fractureHistory,
  });
}

/// Hasil kalkulasi analisis skrining osteoporosis
class ScreeningResult {
  final double scorePercentage;
  final String riskTitle;
  final String riskCategory;
  final String riskDescription;
  final String statusHasil;
  final bool isPositive;
  final List<PredictionItem> predictionData;
  final List<String> recommendations;
  final ScreeningInput input;

  const ScreeningResult({
    required this.scorePercentage,
    required this.riskTitle,
    required this.riskCategory,
    required this.riskDescription,
    required this.statusHasil,
    required this.isPositive,
    required this.predictionData,
    required this.recommendations,
    required this.input,
  });
}

/// Layanan kalkulasi analisis skrining osteoporosis berbasis data input riil pengguna
class ScreeningService {
  static final ScreeningService _instance = ScreeningService._internal();
  factory ScreeningService() => _instance;
  ScreeningService._internal();

  /// Menghitung probabilitas risiko, kategori, rekomendasi, dan data prediksi dari input skrining
  ScreeningResult calculate(ScreeningInput input) {
    double riskPoints = 0;
    const double maxPossiblePoints = 170.0;

    // 1. Usia
    if (input.age >= 65) {
      riskPoints += 26;
    } else if (input.age >= 55) {
      riskPoints += 18;
    } else if (input.age >= 45) {
      riskPoints += 10;
    } else {
      riskPoints += 3;
    }

    // 2. Jenis Kelamin
    if (input.gender.toLowerCase() == 'perempuan') {
      riskPoints += 14;
    } else {
      riskPoints += 4;
    }

    // 3. Perubahan Hormonal
    if (input.hormonal.toLowerCase().contains('pasca') ||
        input.hormonal.toLowerCase().contains('menopause')) {
      riskPoints += 16;
    }

    // 4. Berat Badan / BMI
    if (input.bmiCategory.toLowerCase() == 'kurus' || input.bmi < 18.5) {
      riskPoints += 15;
    } else if (input.bmiCategory.toLowerCase() == 'obesitas' || input.bmi >= 30) {
      riskPoints += 3;
    }

    // 5. Riwayat Patah Tulang
    if (input.fractureHistory.toLowerCase() == 'iya' ||
        input.fractureHistory.toLowerCase() == 'ya') {
      riskPoints += 20;
    }

    // 6. Konsumsi Obat (Kortikosteroid)
    if (input.medication.toLowerCase().contains('kortikosteroid')) {
      riskPoints += 16;
    }

    // 7. Kondisi Medis
    if (input.medicalCondition.toLowerCase().contains('hipertiroidisme') ||
        input.medicalCondition.toLowerCase().contains('artritis')) {
      riskPoints += 14;
    }

    // 8. Asupan Kalsium
    if (input.calcium.toLowerCase() == 'rendah') {
      riskPoints += 12;
    }

    // 9. Asupan Vitamin D
    if (input.vitaminD.toLowerCase().contains('tidak cukup')) {
      riskPoints += 12;
    }

    // 10. Aktivitas Fisik
    if (input.physicalActivity.toLowerCase().contains('kurang')) {
      riskPoints += 12;
    }

    // 11. Merokok
    if (input.smoking.toLowerCase() == 'iya' ||
        input.smoking.toLowerCase() == 'ya') {
      riskPoints += 8;
    }

    // 12. Alkohol
    if (input.alcohol.toLowerCase() == 'ya' ||
        input.alcohol.toLowerCase() == 'iya') {
      riskPoints += 8;
    }

    // 13. Ras / Etnis
    if (input.race.toLowerCase().contains('kaukasia')) {
      riskPoints += 5;
    } else if (input.race.toLowerCase().contains('asia')) {
      riskPoints += 4;
    }

    // Hitung persentase dinamis antara 12% - 94%
    final double rawPercent = (riskPoints / maxPossiblePoints) * 100.0;
    final double scorePercentage = rawPercent.clamp(12.0, 94.0).roundToDouble();

    // Tentukan Kategori & Status
    final String riskTitle;
    final String riskCategory;
    final String statusHasil;
    final String riskDescription;
    final bool isPositive;

    if (scorePercentage >= 60) {
      riskTitle = 'risiko tinggi';
      riskCategory = 'Risiko Tinggi';
      statusHasil = 'Terindikasi Osteoporosis';
      isPositive = true;
      riskDescription =
          'Anda memiliki risiko tinggi untuk mengalami osteoporosis. Disarankan untuk segera berkonsultasi dengan dokter spesialis tulang.';
    } else if (scorePercentage >= 35) {
      riskTitle = 'risiko sedang';
      riskCategory = 'Risiko Sedang';
      statusHasil = 'Terindikasi Osteoporosis';
      isPositive = true;
      riskDescription =
          'Anda memiliki risiko sedang untuk mengalami osteoporosis.';
    } else {
      riskTitle = 'risiko rendah';
      riskCategory = 'Risiko Rendah';
      statusHasil = 'Tidak Terindikasi Osteoporosis';
      isPositive = false;
      riskDescription =
          'Kepadatan tulang Anda kemungkinan besar dalam kondisi baik. Terus pertahankan gaya hidup sehat.';
    }

    // Buat Rekomendasi dinamis berdasarkan jawaban spesifik
    final List<String> recs = [];
    if (input.calcium.toLowerCase() == 'rendah') {
      recs.add('Perbanyak makanan tinggi kalsium (susu, keju, olahan kedelai, brokoli)');
    }
    if (input.vitaminD.toLowerCase().contains('tidak')) {
      recs.add('Konsumsi vitamin D sesuai anjuran dan dapatkan paparan sinar matahari pagi');
    }
    if (input.physicalActivity.toLowerCase().contains('kurang')) {
      recs.add('Rutin melakukan aktivitas fisik (latihan beban ringan / jalan kaki 30 menit sehari)');
    }
    if (input.smoking.toLowerCase() == 'iya' ||
        input.smoking.toLowerCase() == 'ya') {
      recs.add('Hindari rokok karena dapat mempercepat pengeroposan mineral tulang');
    }
    if (input.alcohol.toLowerCase() == 'ya' ||
        input.alcohol.toLowerCase() == 'iya') {
      recs.add('Kurangi dan hindari konsumsi minuman beralkohol');
    }
    if (input.bmiCategory.toLowerCase() == 'kurus') {
      recs.add('Tingkatkan asupan nutrisi bergizi untuk mencapai berat badan ideal');
    }
    if (input.fractureHistory.toLowerCase() == 'iya' ||
        scorePercentage >= 60 ||
        input.medication.toLowerCase().contains('kortikosteroid')) {
      recs.add('Lakukan pemeriksaan Bone Mineral Density (BMD / DEXA Scan) untuk deteksi akurat');
    }

    // Rekomendasi wajib penutup
    recs.add('Konsultasikan hasil ini dengan dokter untuk evaluasi lebih lanjut');

    // Susun 14 PredictionItem riil dari jawaban user
    final List<PredictionItem> predictionItems = [
      PredictionItem(
        icon: Icons.person_outline_rounded,
        label: 'Usia',
        value: '${input.age} tahun',
      ),
      PredictionItem(
        icon: input.gender.toLowerCase() == 'perempuan'
            ? Icons.female_rounded
            : Icons.male_rounded,
        label: 'Jenis kelamin',
        value: input.gender,
      ),
      PredictionItem(
        icon: Icons.science_outlined,
        label: 'Perubahan hormonal',
        value: input.hormonal,
      ),
      PredictionItem(
        icon: Icons.public_rounded,
        label: 'Ras/Etnis',
        value: input.race,
      ),
      PredictionItem(
        icon: Icons.scale_outlined,
        label: 'Berat badan',
        value: '${input.weight.toStringAsFixed(0)} kg (${input.bmiCategory})',
      ),
      PredictionItem(
        icon: Icons.height_rounded,
        label: 'Tinggi badan',
        value: '${input.height.toStringAsFixed(0)} cm',
      ),
      PredictionItem(
        icon: Icons.science_outlined,
        label: 'Asupan kalsium',
        value: input.calcium,
      ),
      PredictionItem(
        icon: Icons.wb_sunny_outlined,
        label: 'Asupan vitamin D',
        value: input.vitaminD,
      ),
      PredictionItem(
        icon: Icons.directions_run_rounded,
        label: 'Aktivitas fisik',
        value: input.physicalActivity,
      ),
      PredictionItem(
        icon: Icons.smoke_free_rounded,
        label: 'Merokok',
        value: input.smoking,
      ),
      PredictionItem(
        icon: Icons.local_bar_outlined,
        label: 'Konsumsi alkohol',
        value: input.alcohol,
      ),
      PredictionItem(
        icon: Icons.medical_services_outlined,
        label: 'Kondisi medis',
        value: _shortenCondition(input.medicalCondition),
      ),
      PredictionItem(
        icon: Icons.medication_outlined,
        label: 'Penggunaan obat',
        value: _shortenMedication(input.medication),
      ),
      PredictionItem(
        icon: Icons.healing_rounded,
        label: 'Riwayat patah tulang',
        value: input.fractureHistory,
      ),
    ];

    return ScreeningResult(
      scorePercentage: scorePercentage,
      riskTitle: riskTitle,
      riskCategory: riskCategory,
      riskDescription: riskDescription,
      statusHasil: statusHasil,
      isPositive: isPositive,
      predictionData: predictionItems,
      recommendations: recs,
      input: input,
    );
  }

  static String _shortenCondition(String val) {
    if (val.contains('(')) {
      return val.split('(').first.trim();
    }
    return val;
  }

  static String _shortenMedication(String val) {
    if (val.contains('(')) {
      return val.split('(').first.trim();
    }
    return val;
  }
}
