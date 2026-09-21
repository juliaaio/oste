import 'package:flutter/material.dart';

/// Status chip untuk menandai hasil skrining atau status konsultasi
class HistoryStatusChip extends StatelessWidget {
  final String label;
  final bool isPositive;
  final bool isConsultation;

  const HistoryStatusChip({
    super.key,
    required this.label,
    this.isPositive = false,
    this.isConsultation = false,
  });

  /// Factory khusus untuk hasil skrining mandiri
  factory HistoryStatusChip.screening({
    Key? key,
    required String label,
    required bool isPositive,
  }) {
    return HistoryStatusChip(
      key: key,
      label: label,
      isPositive: isPositive,
      isConsultation: false,
    );
  }

  /// Factory khusus untuk status sesi konsultasi (misal "Selesai")
  factory HistoryStatusChip.consultation({
    Key? key,
    String label = 'Selesai',
  }) {
    return HistoryStatusChip(
      key: key,
      label: label,
      isPositive: false,
      isConsultation: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (isConsultation) {
      bgColor = const Color(0xFFECFDF5);
      textColor = const Color(0xFF16A34A);
    } else if (isPositive) {
      bgColor = const Color(0xFFFFE4E6); // Rose/pink muda
      textColor = const Color(0xFFE11D48); // Rose/merah
    } else {
      bgColor = const Color(0xFFDCFCE7); // Hijau muda
      textColor = const Color(0xFF16A34A); // Hijau
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
