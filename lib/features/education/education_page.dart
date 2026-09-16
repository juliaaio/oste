import 'package:flutter/material.dart';
import 'package:oste/features/education/vitamin/vitamin_page.dart';
import 'package:oste/features/education/nutrisi/nutrisi_page.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/features/history/history_page.dart';
import 'package:oste/features/profile/profile_page.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  static const List<_EducationTopic> _topics = [
    _EducationTopic(
      imagePath: 'assets/images/education/osteoporosis.png',
      title: 'Mengenal Osteoporosis\nLebih Dekat',
      description:
          'Pahami apa itu osteoporosis, penyebab, faktor risiko, dan cara..',
    ),
    _EducationTopic(
      imagePath: 'assets/images/education/exercise.png',
      title: 'Gerakan untuk Tulang Lebih\nKuat',
      description:
          'Temukan jenis olahraga yang aman dan bermanfaat untuk menjaga...',
    ),
    _EducationTopic(
      imagePath: 'assets/images/education/nutrition.png',
      title: 'Pilihan Makanan & Minuman\nuntuk Tulang Sehat',
      description:
          'Ketahui asupan gizi yang baik untuk mendukung kepadatan tulang.',
    ),
    _EducationTopic(
      imagePath: 'assets/images/education/vitamins.png',
      title: 'Vitamin & Suplemen yang\nDirekomendasikan',
      description:
          'Pelajari vitamin dan suplemen penting yang dapat membantu...',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EducationCard(topic: _topics[index]),
                  ),
                  childCount: _topics.length,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFEAEAEA),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardPage(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HistoryPage(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFFF59E0B),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.home_rounded, size: 24),
            ),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.calendar_today_outlined, size: 21),
            ),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.menu_book_rounded, size: 22),
            ),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.person_rounded, size: 24),
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: SizedBox()),
          Column(
            children: [
              Text(
                'Edukasi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pengetahuan hari ini, untuk tulang\nyang lebih kuat di masa depan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF757575),
                      height: 1.5,
                    ),
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: _TaglineBadge(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaglineBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFC107), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_outlined,
              size: 22, color: Color(0xFFFFC107)),
          const SizedBox(height: 2),
          Text(
            'Healthy Bones\nHappier You',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFFFC107),
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _EducationTopic {
  final String imagePath;
  final String title;
  final String description;

  const _EducationTopic({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class _EducationCard extends StatelessWidget {
  final _EducationTopic topic;

  const _EducationCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (topic.title.contains('Vitamin')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VitaminPage(),
              ),
            );
          } else if (topic.title.contains('Makanan')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NutrisiPage(),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _TopicImage(imagePath: topic.imagePath),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      topic.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF9E9E9E),
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const _ArrowButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicImage extends StatelessWidget {
  final String imagePath;

  const _TopicImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 32,
              color: Color(0xFFFFC107),
            ),
          );
        },
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        color: Colors.white,
      ),
      child: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: Color(0xFF757575),
      ),
    );
  }
}