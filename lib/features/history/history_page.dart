import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Color(0xFF1A1A1A)),
        title: const Text(
          'Riwayat',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Riwayat belum tersedia',
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
