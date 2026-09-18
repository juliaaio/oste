import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/features/history/history_page.dart';
import 'package:oste/features/history/models/history_model.dart';
import 'package:oste/features/history/widgets/history_card.dart';
import 'package:oste/features/screening/hasil_page.dart';
import 'package:oste/services/history_service.dart';
import 'package:oste/services/screening_service.dart';

void main() {
  setUp(() {
    HistoryService().clearScreeningHistories();
  });

  group('ScreeningService Dynamic Calculation Tests', () {
    test('Calculates high risk properly for elderly with risk factors', () {
      const inputHigh = ScreeningInput(
        age: 70,
        gender: 'Perempuan',
        height: 155,
        weight: 42,
        bmi: 17.5,
        bmiCategory: 'Kurus',
        hormonal: 'Pascamenopause',
        race: 'Kaukasia',
        alcohol: 'Ya',
        smoking: 'Iya',
        calcium: 'Rendah',
        vitaminD: 'Tidak cukup',
        physicalActivity: 'Kurang bergerak',
        medicalCondition: 'Hipertiroidisme (benjolan di leher)',
        medication: 'Kortikosteroid (obat radang sendi)',
        fractureHistory: 'Iya',
      );

      final result = ScreeningService().calculate(inputHigh);

      expect(result.scorePercentage, greaterThanOrEqualTo(60));
      expect(result.riskTitle, 'risiko tinggi');
      expect(result.riskCategory, 'Risiko Tinggi');
      expect(result.isPositive, true);
      expect(result.statusHasil, 'Terindikasi Osteoporosis');
      expect(result.predictionData.length, 14);
      expect(result.recommendations.length, greaterThanOrEqualTo(4));
    });

    test('Calculates low risk properly for young active person', () {
      const inputLow = ScreeningInput(
        age: 25,
        gender: 'Laki-laki',
        height: 175,
        weight: 68,
        bmi: 22.2,
        bmiCategory: 'Normal',
        hormonal: 'Normal',
        race: 'Afrika-Amerika',
        alcohol: 'Tidak',
        smoking: 'Tidak',
        calcium: 'Cukup',
        vitaminD: 'Cukup',
        physicalActivity: 'Aktif',
        medicalCondition: 'Tidak ada',
        medication: 'Tidak ada',
        fractureHistory: 'Tidak',
      );

      final result = ScreeningService().calculate(inputLow);

      expect(result.scorePercentage, lessThan(35));
      expect(result.riskTitle, 'risiko rendah');
      expect(result.riskCategory, 'Risiko Rendah');
      expect(result.isPositive, false);
      expect(result.statusHasil, 'Tidak Terindikasi Osteoporosis');
      expect(result.predictionData.length, 14);
    });
  });

  group('HistoryService & Model Integration Tests', () {
    test('HistoryModel differentiates between screening and consultation', () {
      final screeningModel = HistoryModel.fromScreening(
        id: 's1',
        tanggal: DateTime.now(),
        waktu: 'Pukul 10.00 WIB',
        probabilitas: 65,
        status: 'Terindikasi Osteoporosis',
        isPositive: true,
      );

      expect(screeningModel.type, HistoryType.screening);
      expect(screeningModel.probabilitas, 65);

      final historyService = HistoryService();
      historyService.addScreening(screeningModel);

      expect(historyService.latestScreening, isNotNull);
      expect(historyService.latestScreening!.id, 's1');
      expect(historyService.allHistories.any((h) => h.type == HistoryType.screening), isTrue);
      expect(historyService.allHistories.any((h) => h.type == HistoryType.consultation), isTrue);
    });
  });

  group('Dashboard & History UI Integration Tests', () {
    testWidgets('Dashboard shows placeholder when no screening history exists', (tester) async {
      HistoryService().clearScreeningHistories();

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Belum Ada Hasil Skrining'), findsOneWidget);
      expect(find.text('Mulai'), findsOneWidget);
    });

    testWidgets('Dashboard updates dynamically after screening is completed', (tester) async {
      final history = HistoryModel.fromScreening(
        id: 'screen_test_1',
        tanggal: DateTime(2026, 9, 19),
        waktu: 'Pukul 14.30 WIB',
        probabilitas: 72,
        status: 'Terindikasi Osteoporosis',
        isPositive: true,
        riskCategory: 'Risiko Tinggi',
        summary: 'Hasil analisis menunjukkan probabilitas tinggi sebesar 72%.',
      );

      HistoryService().addScreening(history);

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );
      await tester.pump();

      expect(find.text('72%'), findsOneWidget);
      expect(find.text('Terindikasi\nOsteoporosis'), findsOneWidget);
      expect(find.text('19 September 2026'), findsOneWidget);
      expect(find.text('Hasil analisis menunjukkan probabilitas tinggi sebesar 72%.'), findsOneWidget);
    });

    testWidgets('HasilScreeningPage automatically saves to HistoryService', (tester) async {
      HistoryService().clearScreeningHistories();
      expect(HistoryService().latestScreening, isNull);

      await tester.pumpWidget(
        const MaterialApp(
          home: HasilScreeningPage(
            scorePercentage: 58,
            riskTitle: 'risiko sedang',
            riskDescription: 'Probabilitas sedang 58%.',
          ),
        ),
      );
      await tester.pump();

      expect(HistoryService().latestScreening, isNotNull);
      expect(HistoryService().latestScreening!.probabilitas, 58);
      expect(HistoryService().latestScreening!.type, HistoryType.screening);
    });

    testWidgets('HistoryPage displays screening cards alongside consultations', (tester) async {
      final screening = HistoryModel.fromScreening(
        id: 's_render',
        tanggal: DateTime(2026, 9, 19),
        waktu: 'Pukul 11.00 WIB',
        probabilitas: 45,
        status: 'Terindikasi Osteoporosis',
        isPositive: true,
      );
      HistoryService().addScreening(screening);

      await tester.pumpWidget(
        const MaterialApp(
          home: HistoryPage(),
        ),
      );
      await tester.pump();

      expect(find.byType(HistoryCard), findsWidgets);
      expect(find.text('Probabilitas: 45%'), findsOneWidget);
    });
  });
}
