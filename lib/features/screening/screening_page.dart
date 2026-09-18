import 'package:flutter/material.dart';
import 'package:oste/features/screening/hasil_page.dart';
import 'package:oste/services/screening_service.dart';
/// Palet warna utama halaman Skrining Osteoporosis
class _ScreeningColors {
  static const Color background = Color(0xFFFAF9F5);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textPlaceholder = Color(0xFF94A3B8);
  static const Color primaryYellow = Color(0xFFFBBF24);
  static const Color selectedBlue = Color(0xFF2563EB);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputBg = Color(0xFFF8FAFC);
  static const Color bannerBg = Color(0xFFFFF7D6);
  static const Color bannerBorder = Color(0xFFFDE68A);
  static const Color bmiCardBg = Color(0xFFFFF8E7);
  static const Color bmiCardBorder = Color(0xFFFDE68A);
}

/// Halaman Skrining Osteoporosis
class ScreeningPage extends StatefulWidget {
  const ScreeningPage({super.key});

  @override
  State<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {
  // Controller untuk input teks (Umur, Tinggi, Berat)
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // State pilihan jawaban
  String? _selectedGender;
  String? _selectedHormonal;
  String? _selectedRace;
  String? _selectedAlcohol;
  String? _selectedSmoking;
  String? _selectedCalcium;
  String? _selectedVitaminD;
  String? _selectedPhysicalActivity;
  String? _selectedMedicalCondition;
  String? _selectedMedication;
  String? _selectedFractureHistory;

  // State perhitungan BMI
  double? _calculatedBmi;
  String? _calculatedBmiCategory;

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBmi() {
    final heightText = _heightController.text.trim().replaceAll(',', '.');
    final weightText = _weightController.text.trim().replaceAll(',', '.');

    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);

    if (height != null && weight != null && height > 0 && weight > 0) {
      final heightInM = height / 100.0;
      final bmi = weight / (heightInM * heightInM);
      String category;
      if (bmi < 18.5) {
        category = 'Kurus';
      } else if (bmi < 25.0) {
        category = 'Normal';
      } else if (bmi < 30.0) {
        category = 'Berlebih';
      } else {
        category = 'Obesitas';
      }

      setState(() {
        _calculatedBmi = bmi;
        _calculatedBmiCategory = category;
      });
    } else {
      if (_calculatedBmi != null || _calculatedBmiCategory != null) {
        setState(() {
          _calculatedBmi = null;
          _calculatedBmiCategory = null;
        });
      }
    }
  }

  void _onSubmit() {
    // Validasi kelengkapan form
    final isAgeFilled = _ageController.text.trim().isNotEmpty;
    final isHeightFilled = _heightController.text.trim().isNotEmpty;
    final isWeightFilled = _weightController.text.trim().isNotEmpty;

    if (!isAgeFilled ||
        _selectedGender == null ||
        !isHeightFilled ||
        !isWeightFilled ||
        _selectedHormonal == null ||
        _selectedRace == null ||
        _selectedAlcohol == null ||
        _selectedSmoking == null ||
        _selectedCalcium == null ||
        _selectedVitaminD == null ||
        _selectedPhysicalActivity == null ||
        _selectedMedicalCondition == null ||
        _selectedMedication == null ||
        _selectedFractureHistory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Mohon lengkapi semua pertanyaan sebelum melanjutkan.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Skrining berhasil disimpan!',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final height = double.tryParse(_heightController.text.trim().replaceAll(',', '.')) ?? 0;
    final weight = double.tryParse(_weightController.text.trim().replaceAll(',', '.')) ?? 0;
    final bmi = _calculatedBmi ?? (height > 0 ? weight / ((height / 100) * (height / 100)) : 0);
    final bmiCategory = _calculatedBmiCategory ?? 'Normal';

    final input = ScreeningInput(
      age: age,
      gender: _selectedGender!,
      height: height,
      weight: weight,
      bmi: bmi,
      bmiCategory: bmiCategory,
      hormonal: _selectedHormonal!,
      race: _selectedRace!,
      alcohol: _selectedAlcohol!,
      smoking: _selectedSmoking!,
      calcium: _selectedCalcium!,
      vitaminD: _selectedVitaminD!,
      physicalActivity: _selectedPhysicalActivity!,
      medicalCondition: _selectedMedicalCondition!,
      medication: _selectedMedication!,
      fractureHistory: _selectedFractureHistory!,
    );

    final result = ScreeningService().calculate(input);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HasilScreeningPage(
          scorePercentage: result.scorePercentage,
          riskTitle: result.riskTitle,
          riskDescription: result.riskDescription,
          predictionData: result.predictionData,
          recommendations: result.recommendations,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ScreeningColors.background,
      appBar: AppBar(
        backgroundColor: _ScreeningColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 30,
            color: _ScreeningColors.textDark,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Skrining Osteoporosis',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _ScreeningColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -------------------------------------------------------------
              // Banner Card Atas
              // -------------------------------------------------------------
              Container(
                decoration: BoxDecoration(
                  color: _ScreeningColors.bannerBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _ScreeningColors.bannerBorder,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Karakter maskot tulang & bintang kilau
                    const SizedBox(
                      width: 90,
                      height: 90,
                      child: CustomPaint(
                        painter: _BannerMascotPainter(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kenali Risikomu,\nJaga Tulangmu',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _ScreeningColors.textDark,
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Isi pertanyaan berikut dengan benar\nuntuk mengetahui risiko\nosteoporosis\nAnda.',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: _ScreeningColors.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // -------------------------------------------------------------
              // 1. Umur
              // -------------------------------------------------------------
              QuestionCard(
                title: '1.  Umur',
                subtitle: 'Berapa usia Anda saat ini?',
                child: CustomTextField(
                  controller: _ageController,
                  hintText: 'Masukkan umur Anda',
                  unitText: 'tahun',
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 2. Jenis kelamin (Horizontal)
              // -------------------------------------------------------------
              QuestionCard(
                title: '2.  Jenis kelamin',
                subtitle: 'Apa jenis kelamin Anda?',
                child: Row(
                  children: [
                    Expanded(
                      child: CustomRadioButton<String>(
                        value: 'Perempuan',
                        groupValue: _selectedGender,
                        label: 'Perempuan',
                        onChanged: (val) => setState(() => _selectedGender = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomRadioButton<String>(
                        value: 'Laki-laki',
                        groupValue: _selectedGender,
                        label: 'Laki-laki',
                        onChanged: (val) => setState(() => _selectedGender = val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 3. Tinggi badan
              // -------------------------------------------------------------
              QuestionCard(
                title: '3.  Tinggi badan',
                subtitle: 'Berapa tinggi badan Anda?',
                child: CustomTextField(
                  controller: _heightController,
                  hintText: 'Masukkan tinggi badan',
                  unitText: 'cm',
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 4. Berat badan & Indeks Massa Tubuh (BMI)
              // -------------------------------------------------------------
              QuestionCard(
                title: '4.  Berat badan',
                subtitle: 'Berapa berat badan Anda?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _weightController,
                      hintText: 'Masukkan berat badan',
                      unitText: 'kg',
                    ),
                    const SizedBox(height: 14),
                    BMICard(
                      bmi: _calculatedBmi,
                      category: _calculatedBmiCategory,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 5. Perubahan hormonal
              // -------------------------------------------------------------
              QuestionCard(
                title: '5.  Perubahan hormonal',
                subtitle: 'Bagaimana perubahan hormonal anda?',
                child: _buildVerticalOptions<String>(
                  options: const ['Normal', 'Pascamenopause'],
                  groupValue: _selectedHormonal,
                  onChanged: (val) => setState(() => _selectedHormonal = val),
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 6. Ras
              // -------------------------------------------------------------
              QuestionCard(
                title: '6.  Ras',
                subtitle: 'Apa ras yang anda anut?',
                child: _buildVerticalOptions<String>(
                  options: const ['Afrika-Amerika', 'Asia', 'Kaukasia'],
                  groupValue: _selectedRace,
                  onChanged: (val) => setState(() => _selectedRace = val),
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 7. Konsumsi alkohol (Horizontal)
              // -------------------------------------------------------------
              QuestionCard(
                title: '7.  Konsumsi alkohol',
                subtitle: 'Apakah Anda mengonsumsi minuman beralkohol?',
                child: Row(
                  children: [
                    Expanded(
                      child: CustomRadioButton<String>(
                        value: 'Ya',
                        groupValue: _selectedAlcohol,
                        label: 'Ya',
                        onChanged: (val) => setState(() => _selectedAlcohol = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomRadioButton<String>(
                        value: 'Tidak',
                        groupValue: _selectedAlcohol,
                        label: 'Tidak',
                        onChanged: (val) => setState(() => _selectedAlcohol = val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 8. Status merokok
              // -------------------------------------------------------------
              QuestionCard(
                title: '8.  Status merokok',
                subtitle: 'Apakah Anda perokok?',
                child: _buildVerticalOptions<String>(
                  options: const ['Iya', 'Tidak'],
                  groupValue: _selectedSmoking,
                  onChanged: (val) => setState(() => _selectedSmoking = val),
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 9. Asupan kalsium
              // -------------------------------------------------------------
              QuestionCard(
                title: '9.  Asupan kalsium',
                subtitle: 'Bagaimana asupan kalsium anda?',
                child: _buildVerticalOptions<String>(
                  options: const ['Cukup', 'Rendah'],
                  groupValue: _selectedCalcium,
                  onChanged: (val) => setState(() => _selectedCalcium = val),
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 10. Asupan vitamin D
              // -------------------------------------------------------------
              QuestionCard(
                title: '10.  Asupan vitamin D',
                subtitle: 'Bagaimana asupan vitamin D anda?',
                child: _buildVerticalOptions<String>(
                  options: const ['Tidak cukup', 'Cukup'],
                  groupValue: _selectedVitaminD,
                  onChanged: (val) => setState(() => _selectedVitaminD = val),
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 11. Aktivitas fisik
              // -------------------------------------------------------------
              QuestionCard(
                title: '11.  Aktivitas fisik',
                subtitle: 'Bagaimana aktivitas anda?',
                child: _buildVerticalOptions<String>(
                  options: const ['Aktif', 'Kurang bergerak'],
                  groupValue: _selectedPhysicalActivity,
                  onChanged: (val) => setState(() => _selectedPhysicalActivity = val),
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 12. Kondisi medis
              // -------------------------------------------------------------
              QuestionCard(
                title: '12.  Kondisi medis',
                subtitle: 'Penyakit apa yang sedang anda derita?',
                child: _buildVerticalOptions<String>(
                  options: const [
                    'Hipertiroidisme (benjolan di leher)',
                    'Artritis reumatoid (peradangan sendi)',
                    'Tidak ada',
                  ],
                  groupValue: _selectedMedicalCondition,
                  onChanged: (val) => setState(() => _selectedMedicalCondition = val),
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 13. Konsumsi obat
              // -------------------------------------------------------------
              QuestionCard(
                title: '13.  Konsumsi obat',
                subtitle: 'Obat apa yang sedang anda konsumsi?',
                child: _buildVerticalOptions<String>(
                  options: const [
                    'Kortikosteroid (obat radang sendi)',
                    'Tidak ada',
                  ],
                  groupValue: _selectedMedication,
                  onChanged: (val) => setState(() => _selectedMedication = val),
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 14. Riwayat patah tulang
              // -------------------------------------------------------------
              QuestionCard(
                title: '14.  Riwayat patah tulang',
                subtitle: 'Apakah anda memiliki riwayat patah tulang ?',
                child: _buildVerticalOptions<String>(
                  options: const ['Iya', 'Tidak'],
                  groupValue: _selectedFractureHistory,
                  onChanged: (val) => setState(() => _selectedFractureHistory = val),
                ),
              ),
              const SizedBox(height: 24),

              // -------------------------------------------------------------
              // Tombol Mulai Skrining
              // -------------------------------------------------------------
              PrimaryButton(
                text: 'Mulai Skrining',
                onPressed: _onSubmit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalOptions<T>({
    required List<T> options,
    required T? groupValue,
    required ValueChanged<T> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          CustomRadioButton<T>(
            value: options[i],
            groupValue: groupValue,
            label: options[i].toString(),
            onChanged: onChanged,
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// REUSABLE COMPONENT: QuestionCard
// =============================================================================
class QuestionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const QuestionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ScreeningColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _ScreeningColors.borderLight,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _ScreeningColors.textDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _ScreeningColors.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// =============================================================================
// REUSABLE COMPONENT: CustomRadioButton
// =============================================================================
class CustomRadioButton<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final String label;
  final ValueChanged<T> onChanged;

  const CustomRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      splashColor: _ScreeningColors.primaryYellow.withValues(alpha: 0.15),
      highlightColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minHeight: 38),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Lingkaran radio dengan ukuran tetap 22x22
            SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(
                painter: _RadioCirclePainter(isSelected: isSelected),
              ),
            ),
            const SizedBox(width: 12),
            // Teks opsi dengan baseline seragam & tepat dimulai pada koordinat x yang sama
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: _ScreeningColors.textDark,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTER: _RadioCirclePainter
// =============================================================================
class _RadioCirclePainter extends CustomPainter {
  final bool isSelected;

  const _RadioCirclePainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 9.5;

    if (isSelected) {
      // Lingkaran luar berwarna biru solid
      final fillPaint = Paint()
        ..color = _ScreeningColors.selectedBlue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, fillPaint);

      // Titik tengah putih solid
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 3.8, dotPaint);
    } else {
      // Lingkaran outline kuning keemasan yang bersih
      final strokePaint = Paint()
        ..color = _ScreeningColors.primaryYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawCircle(center, radius, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadioCirclePainter oldDelegate) {
    return oldDelegate.isSelected != isSelected;
  }
}

// =============================================================================
// REUSABLE COMPONENT: CustomTextField
// =============================================================================
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String unitText;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.unitText,
    this.keyboardType = TextInputType.number,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _ScreeningColors.inputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _ScreeningColors.inputBorder,
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _ScreeningColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: _ScreeningColors.textPlaceholder,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 44,
          child: Text(
            unitText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _ScreeningColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// REUSABLE COMPONENT: BMICard
// =============================================================================
class BMICard extends StatelessWidget {
  final double? bmi;
  final String? category;

  const BMICard({
    super.key,
    this.bmi,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final hasCalculated = bmi != null && category != null;

    return Container(
      decoration: BoxDecoration(
        color: _ScreeningColors.bmiCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _ScreeningColors.bmiCardBorder.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ikon timbangan badan
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _ScreeningColors.primaryYellow.withValues(alpha: 0.7),
                width: 1.2,
              ),
            ),
            child: const Center(
              child: CustomPaint(
                size: Size(22, 22),
                painter: _BmiScaleIconPainter(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Indeks Massa Tubuh (BMI)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ScreeningColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                if (hasCalculated)
                  Text(
                    'BMI: ${bmi!.toStringAsFixed(1)} ($category)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD97706),
                    ),
                  )
                else
                  const Text(
                    'Akan dihitung otomatis setelah Anda mengisi tinggi dan berat badan.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: _ScreeningColors.textMuted,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// REUSABLE COMPONENT: PrimaryButton
// =============================================================================
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _ScreeningColors.primaryYellow,
          foregroundColor: _ScreeningColors.textDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ScreeningColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: _ScreeningColors.textDark,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTER: Ikon Timbangan BMI
// =============================================================================
class _BmiScaleIconPainter extends CustomPainter {
  const _BmiScaleIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.fill;

    // Body kotak timbangan dengan rounded corners
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      const Radius.circular(5),
    );
    canvas.drawRRect(rrect, strokePaint);

    // Kaca pembacaan dial atas
    final dialRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.38),
      width: 7,
      height: 4,
    );
    canvas.drawOval(dialRect, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// CUSTOM PAINTER: Karakter Maskot Tulang Banner & Bintang Kilau
// =============================================================================
class _BannerMascotPainter extends CustomPainter {
  const _BannerMascotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Gambar kilau bintang emas (Sparkles) di sekitar maskot
    final sparklePaint = Paint()
      ..color = _ScreeningColors.primaryYellow
      ..style = PaintingStyle.fill;

    _drawSparkle(canvas, Offset(w * 0.22, h * 0.22), 9.0, sparklePaint);
    _drawSparkle(canvas, Offset(w * 0.16, h * 0.68), 7.0, sparklePaint);
    _drawSparkle(canvas, Offset(w * 0.88, h * 0.72), 7.5, sparklePaint);
    _drawSparkle(canvas, Offset(w * 0.76, h * 0.25), 4.5, sparklePaint);

    // 2. Kaki maskot
    final limbPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Kaki kiri
    canvas.drawLine(Offset(w * 0.44, h * 0.78), Offset(w * 0.40, h * 0.90), limbPaint);
    // Kaki kanan
    canvas.drawLine(Offset(w * 0.60, h * 0.78), Offset(w * 0.64, h * 0.90), limbPaint);

    // 3. Badan tulang vertikal
    final boneFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final boneStroke = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bonePath = Path();
    final cx = w * 0.52;
    final cy = h * 0.52;

    // Kepala atas tulang
    bonePath.moveTo(cx - 7, cy - 26);
    bonePath.cubicTo(cx - 16, cy - 35, cx - 2, cy - 39, cx, cy - 30);
    bonePath.cubicTo(cx + 2, cy - 39, cx + 16, cy - 35, cx + 7, cy - 26);
    // Batang kanan
    bonePath.cubicTo(cx + 6, cy - 10, cx + 6, cy + 10, cx + 7, cy + 26);
    // Kepala bawah tulang
    bonePath.cubicTo(cx + 16, cy + 35, cx + 2, cy + 39, cx, cy + 30);
    bonePath.cubicTo(cx - 2, cy + 39, cx - 16, cy + 35, cx - 7, cy + 26);
    // Batang kiri
    bonePath.cubicTo(cx - 6, cy + 10, cx - 6, cy - 10, cx - 7, cy - 26);
    bonePath.close();

    // Bayangan lembut
    canvas.drawPath(
      bonePath,
      Paint()
        ..color = const Color(0x14F59E0B)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    canvas.drawPath(bonePath, boneFill);
    canvas.drawPath(bonePath, boneStroke);

    // 4. Lengan maskot
    // Lengan kiri
    canvas.drawLine(Offset(cx - 6, cy - 2), Offset(cx - 16, cy - 10), limbPaint);
    // Lengan kanan memegang kaca pembesar
    canvas.drawLine(Offset(cx + 6, cy - 2), Offset(cx + 16, cy + 4), limbPaint);

    // 5. Kaca pembesar di tangan kanan
    final glassPaint = Paint()
      ..color = const Color(0xFFFEF3C7)
      ..style = PaintingStyle.fill;
    final glassStroke = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final glassCenter = Offset(cx + 18, cy + 8);
    canvas.drawCircle(glassCenter, 10, glassPaint);
    canvas.drawCircle(glassCenter, 10, glassStroke);

    // Pola berpori tulang di dalam kaca pembesar
    final porePaint = Paint()
      ..color = const Color(0xFFD97706).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(glassCenter.dx - 4, glassCenter.dy - 3), 1.8, porePaint);
    canvas.drawCircle(Offset(glassCenter.dx + 3, glassCenter.dy - 2), 2.2, porePaint);
    canvas.drawCircle(Offset(glassCenter.dx - 1, glassCenter.dy + 4), 2.0, porePaint);
    canvas.drawCircle(Offset(glassCenter.dx + 4, glassCenter.dy + 3), 1.5, porePaint);

    // 6. Wajah maskot yang lucu (mata berkedip + senyum)
    final eyePaint = Paint()
      ..color = _ScreeningColors.textDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Mata kiri melengkung kedip ^
    final leftEye = Path();
    leftEye.moveTo(cx - 4.5, cy - 8);
    leftEye.quadraticBezierTo(cx - 2.5, cy - 11, cx - 0.5, cy - 8);
    canvas.drawPath(leftEye, eyePaint);

    // Mata kanan bulat imut
    canvas.drawCircle(
      Offset(cx + 4.5, cy - 9),
      1.6,
      Paint()
        ..color = _ScreeningColors.textDark
        ..style = PaintingStyle.fill,
    );

    // Senyum imut
    final smilePath = Path();
    smilePath.moveTo(cx - 2.0, cy - 3.5);
    smilePath.quadraticBezierTo(cx + 1.0, cy - 1.0, cx + 4.0, cy - 3.5);
    canvas.drawPath(smilePath, eyePaint);

    // Pipi merona (blush)
    final blushPaint = Paint()
      ..color = const Color(0xFFFCA5A5).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 4, cy - 4), width: 3.5, height: 2),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 6, cy - 4), width: 3.5, height: 2),
      blushPaint,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
