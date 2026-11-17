import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/education/education_page.dart';
import 'package:oste/features/education/nutrisi/nutrisi_page.dart';
import 'package:oste/features/education/olahraga/olahraga_page.dart';
import 'package:oste/features/education/vitamin/vitamin_page.dart';
import 'package:oste/models/education_model.dart';
import 'package:oste/services/education_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    EducationRepository().resetForTesting();
  });

  group('EducationPage & EducationRepository Synchronization Tests', () {
    testWidgets('Renders all initial education items from EducationRepository',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EducationPage(),
        ),
      );
      await tester.pump();

      // Header Osteo Edukasi
      expect(find.text('Edukasi'), findsWidgets);
      expect(find.text('PANDUAN KESEHATAN TULANG'), findsOneWidget);
      expect(find.text('Topik Edukasi'), findsOneWidget);
      expect(find.text('3 Topik'), findsOneWidget);

      // Initial education items
      expect(find.text('Latihan Penguatan Tulang'), findsOneWidget);
      expect(find.text('Asupan Nutrisi untuk Tulang Sehat'), findsOneWidget);
      expect(find.text('Rekomendasi Vitamin D'), findsOneWidget);

      // Category Badges
      expect(find.text('Latihan'), findsOneWidget);
      expect(find.text('Nutrisi'), findsOneWidget);
      expect(find.text('Vitamin'), findsOneWidget);

      // Category Icons
      expect(find.byIcon(Icons.directions_run_rounded), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
      expect(find.byIcon(Icons.medication_rounded), findsOneWidget);
    });

    testWidgets('Tapping education card navigates to the mapped category page',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EducationPage(),
        ),
      );
      await tester.pump();

      // Tap on Latihan card -> should navigate to OlahragaPage
      await tester.tap(find.text('Latihan Penguatan Tulang'));
      await tester.pumpAndSettle();
      expect(find.byType(OlahragaPage), findsOneWidget);

      // Pop back
      final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Tap on Nutrisi card -> should navigate to NutrisiPage
      await tester.tap(find.text('Asupan Nutrisi untuk Tulang Sehat'));
      await tester.pumpAndSettle();
      expect(find.byType(NutrisiPage), findsOneWidget);

      // Pop back
      final backButtonNutrisi = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButtonNutrisi, findsOneWidget);
      await tester.tap(backButtonNutrisi);
      await tester.pumpAndSettle();

      // Tap on Vitamin card -> should navigate to VitaminPage
      await tester.tap(find.text('Rekomendasi Vitamin D'));
      await tester.pumpAndSettle();
      expect(find.byType(VitaminPage), findsOneWidget);
    });

    testWidgets(
        'Admin adding an education item immediately appears in EducationPage without manual reload',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EducationPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Senam Lansia Tulang Kuat'), findsNothing);
      expect(find.text('3 Topik'), findsOneWidget);

      // Admin adds education item via EducationRepository
      await EducationRepository().addEducation(
        const EducationModel(
          id: 'edu_test_add',
          title: 'Senam Lansia Tulang Kuat',
          category: 'Latihan',
          description: 'Latihan senam ringan teratur untuk fleksibilitas sendi.',
        ),
      );

      // Pump to trigger reactive AnimatedBuilder
      await tester.pump();

      // Should immediately appear
      expect(find.text('Senam Lansia Tulang Kuat'), findsOneWidget);
      expect(find.text('4 Topik'), findsOneWidget);
    });

    testWidgets(
        'Admin editing an education item immediately reflects changes in EducationPage',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EducationPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Latihan Penguatan Tulang'), findsOneWidget);

      // Admin updates the item
      await EducationRepository().updateEducation(
        const EducationModel(
          id: 'edu_1',
          title: 'Latihan Penguatan Tulang Diperbarui',
          category: 'Latihan',
          description: 'Deskripsi baru setelah diedit admin.',
        ),
      );

      await tester.pump();

      // Should immediately display the updated title & description
      expect(find.text('Latihan Penguatan Tulang Diperbarui'), findsOneWidget);
      expect(find.text('Deskripsi baru setelah diedit admin.'), findsOneWidget);
      expect(find.text('Latihan Penguatan Tulang'), findsNothing);
    });

    testWidgets(
        'Admin deleting an education item immediately removes it from EducationPage',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EducationPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Rekomendasi Vitamin D'), findsOneWidget);
      expect(find.text('3 Topik'), findsOneWidget);

      // Admin deletes the vitamin item
      await EducationRepository().deleteEducation('edu_3');

      await tester.pump();

      // Should immediately disappear and count should update to 2 Topik
      expect(find.text('Rekomendasi Vitamin D'), findsNothing);
      expect(find.text('2 Topik'), findsOneWidget);
    });
  });
}
