import 'package:flutter/material.dart';

import 'ringkasan_page.dart';
import 'penyebab_page.dart';
import 'gejala_page.dart';
import 'pencegahan_page.dart';

class OsteoporosisPage extends StatelessWidget {
  const OsteoporosisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF222222),
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            'Osteoporosis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Color(0xFFF7C948),
            indicatorWeight: 3,
            dividerColor: Color(0xFFF0F0F0),
            labelColor: Color(0xFFE5A124),
            unselectedLabelColor: Color(0xFF94A3B8),
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: [
              Tab(text: 'Ringkasan'),
              Tab(text: 'Penyebab'),
              Tab(text: 'Gejala'),
              Tab(text: 'Pencegahan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const RingkasanPage(),
            const PenyebabPage(),
            const GejalaPage(),
            const PencegahanPage(),
          ],
        ),
      ),
    );
  }
}
