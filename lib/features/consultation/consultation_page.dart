import 'package:flutter/material.dart';
import 'package:oste/features/consultation/doctor_list_page.dart';

export 'doctor_list_page.dart';

/// Entry point halaman Konsultasi Osteo
class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoctorListPage();
  }
}
