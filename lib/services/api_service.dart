import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oste/features/screening/hasil_page.dart';

// ---------------------------------------------------------------------------
// Konfigurasi base URL FastAPI
// Ganti sesuai environment:
//   Flutter Web / iOS Simulator : 'http://127.0.0.1:8000'
//   Android Emulator            : 'http://10.0.2.2:8000'
//   Physical Device (LAN)       : 'http://10.125.173.142:8000'
const String kFastApiBaseUrl = 'http://10.125.173.142:8000';

// ---------------------------------------------------------------------------
// Mapping helpers: Flutter form values -> FastAPI feature labels
// ---------------------------------------------------------------------------
String _mapBodyWeight(String bmiCategory) {
  switch (bmiCategory.toLowerCase()) {
    case 'kurus':
      return 'Underweight';
    case 'normal':
      return 'Normal';
    case 'berlebih':
    case 'overweight':
      return 'Normal'; // backend maps Overweight -> Normal
    case 'obesitas':
      return 'Obese';
    default:
      return 'Normal';
  }
}

String _mapGender(String gender) {
  switch (gender.toLowerCase()) {
    case 'perempuan':
      return 'Female';
    case 'laki-laki':
      return 'Male';
    default:
      return gender;
  }
}

String _mapRace(String race) {
  switch (race.toLowerCase()) {
    case 'asia':
      return 'Asian';
    case 'kaukasia':
      return 'Caucasian';
    case 'afrika-amerika':
      return 'African American';
    default:
      return race;
  }
}

int _mapYesNo(String val) {
  final v = val.toLowerCase();
  return (v == 'ya' || v == 'iya' || v == 'yes') ? 1 : 0;
}

String _mapLowAdequate(String val) =>
    val.toLowerCase() == 'rendah' ? 'Low' : 'Adequate';

String _mapVitaminD(String val) =>
    val.toLowerCase() == 'rendah' ? 'Insufficient' : 'Sufficient';

String _mapActivity(String val) =>
    val.toLowerCase().contains('kurang') ? 'Sedentary' : 'Active';

String _mapMedicalCondition(String val) {
  final lower = val.toLowerCase();
  if (lower.contains('hipertiroidisme')) return 'Hyperthyroidism';
  if (lower.contains('artritis')) return 'Rheumatoid Arthritis';
  return 'None';
}

String _mapMedication(String val) =>
    val.toLowerCase().contains('kortikosteroid') ? 'Corticosteroids' : 'None';

// ---------------------------------------------------------------------------
// Model: respons JSON dari FastAPI
// { "prediction": 1, "probability": 91.0, "confidence": 91.42 }
// ---------------------------------------------------------------------------
class FastApiPredictResponse {
  final int prediction;     // 0 atau 1
  final double probability; // 0-100
  final double confidence;  // 0-100

  const FastApiPredictResponse({
    required this.prediction,
    required this.probability,
    required this.confidence,
  });

  factory FastApiPredictResponse.fromJson(Map<String, dynamic> json) {
    return FastApiPredictResponse(
      prediction: (json['prediction'] as num).toInt(),
      probability: (json['probability'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

// ---------------------------------------------------------------------------
// Model: payload POST ke FastAPI (tanpa Hormonal_Changes)
// ---------------------------------------------------------------------------
class ScreeningPayload {
  final int age;
  final String gender;
  final String race;
  final String bodyWeight;
  final int alcoholConsumption;
  final int smokingStatus;
  final String calciumIntake;
  final String vitaminDIntake;
  final String physicalActivity;
  final String medicalConditions;
  final String medications;
  final int priorFractures;

  const ScreeningPayload({
    required this.age,
    required this.gender,
    required this.race,
    required this.bodyWeight,
    required this.alcoholConsumption,
    required this.smokingStatus,
    required this.calciumIntake,
    required this.vitaminDIntake,
    required this.physicalActivity,
    required this.medicalConditions,
    required this.medications,
    required this.priorFractures,
  });

  Map<String, dynamic> toJson() => {
    'Age': age,
    'Gender': gender,
    'Race/Ethnicity': race,
    'Body Weight': bodyWeight,
    'Alcohol Consumption': alcoholConsumption,
    'Smoking': smokingStatus,
    'Calcium Intake': calciumIntake,
    'Vitamin D Intake': vitaminDIntake,
    'Physical Activity': physicalActivity,
    'Medical Conditions': medicalConditions,
    'Medications': medications,
    'Prior Fractures': priorFractures,
  };
}

// ---------------------------------------------------------------------------
// ApiService: singleton untuk HTTP call dan Firestore save
// ---------------------------------------------------------------------------
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _firestore = FirebaseFirestore.instance;

  /// POST ke /predict dan kembalikan respons API.
  Future<FastApiPredictResponse> predict(ScreeningPayload payload) async {
    final uri = Uri.parse('$kFastApiBaseUrl/predict');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = json.encode(payload.toJson());

    http.Response? response;
    try {
      response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[ApiService] Connection error to $uri: $e');

      // Khusus web (Chrome): Coba fallback ke localhost jika 127.0.0.1 gagal
      if (kIsWeb && kFastApiBaseUrl.contains('127.0.0.1')) {
        try {
          final fallbackUri = Uri.parse('http://localhost:8000/predict');
          debugPrint('[ApiService] Retrying with fallback: $fallbackUri');
          response = await http
              .post(fallbackUri, headers: headers, body: body)
              .timeout(const Duration(seconds: 15));
        } catch (e2) {
          debugPrint('[ApiService] Fallback connection error: $e2');
        }
      }
    }

    if (response == null) {
      throw Exception(
        'Tidak dapat terhubung ke server FastAPI ($kFastApiBaseUrl). '
        'Pastikan server uvicorn sedang berjalan (uvicorn main:app --reload --port 8000).',
      );
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return FastApiPredictResponse.fromJson(data);
    } else {
      debugPrint('[ApiService] Error ${response.statusCode}: ${response.body}');
      throw Exception(
        'Server mengembalikan error (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Simpan hasil ke Firestore: users/{uid}/riwayat_skrining/{docId}
  /// Mengembalikan docId.
  Future<String> saveToFirestore({
    required ScreeningPayload payload,
    required FastApiPredictResponse apiResponse,
    required List<String> recommendations,
    required String riskTitle,
    required String riskDescription,
    required String statusHasil,
  }) async {
    final now = DateTime.now();
    final timeStr =
        'Pukul ${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')} WIB';
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return 'local_${now.millisecondsSinceEpoch}';
    }

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('riwayat_skrining')
        .doc();

    final data = <String, dynamic>{
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'tanggal': now.toIso8601String(),
      'waktu': timeStr,
      'prediction': apiResponse.prediction,
      'probability': apiResponse.probability,
      'confidence': apiResponse.confidence,
      'riskTitle': riskTitle,
      'riskDescription': riskDescription,
      'statusHasil': statusHasil,
      'isPositive': apiResponse.prediction == 1,
      'recommendations': recommendations,
      'input': payload.toJson(),
    };

    try {
      await docRef.set(data);
      debugPrint('[ApiService] Berhasil disimpan di Firestore: ${docRef.id}');
    } catch (e) {
      debugPrint('[ApiService] Firestore error: $e');
    }
    return docRef.id;
  }
}

// ---------------------------------------------------------------------------
// Helper: buat ScreeningPayload dari nilai form Flutter
// ---------------------------------------------------------------------------
ScreeningPayload buildScreeningPayload({
  required int age,
  required String gender,
  required String race,
  required String bmiCategory,
  required String alcohol,
  required String smoking,
  required String calcium,
  required String vitaminD,
  required String physicalActivity,
  required String medicalCondition,
  required String medication,
  required String fractureHistory,
}) {
  return ScreeningPayload(
    age: age,
    gender: _mapGender(gender),
    race: _mapRace(race),
    bodyWeight: _mapBodyWeight(bmiCategory),
    alcoholConsumption: _mapYesNo(alcohol),
    smokingStatus: _mapYesNo(smoking),
    calciumIntake: _mapLowAdequate(calcium),
    vitaminDIntake: _mapVitaminD(vitaminD),
    physicalActivity: _mapActivity(physicalActivity),
    medicalConditions: _mapMedicalCondition(medicalCondition),
    medications: _mapMedication(medication),
    priorFractures: _mapYesNo(fractureHistory),
  );
}

// ---------------------------------------------------------------------------
// Helper: buat PredictionItem list (13 item, TANPA hormonal)
// ---------------------------------------------------------------------------
List<PredictionItem> buildPredictionItems({
  required int age,
  required String gender,
  required String race,
  required double height,
  required double weight,
  required String bmiCategory,
  required String alcohol,
  required String smoking,
  required String calcium,
  required String vitaminD,
  required String physicalActivity,
  required String medicalCondition,
  required String medication,
  required String fractureHistory,
}) {
  String shorten(String v) =>
      v.contains('(') ? v.split('(').first.trim() : v;

  return [
    PredictionItem(
      icon: Icons.person_outline_rounded,
      label: 'Usia',
      value: '$age tahun',
    ),
    PredictionItem(
      icon: gender.toLowerCase() == 'perempuan'
          ? Icons.female_rounded
          : Icons.male_rounded,
      label: 'Jenis kelamin',
      value: gender,
    ),
    PredictionItem(
      icon: Icons.public_rounded,
      label: 'Ras/Etnis',
      value: race,
    ),
    PredictionItem(
      icon: Icons.scale_outlined,
      label: 'Berat badan',
      value: '${weight.toStringAsFixed(1)} kg ($bmiCategory)',
    ),
    PredictionItem(
      icon: Icons.height_rounded,
      label: 'Tinggi badan',
      value: '${height.toStringAsFixed(1)} cm',
    ),
    PredictionItem(
      icon: Icons.science_outlined,
      label: 'Asupan kalsium',
      value: calcium,
    ),
    PredictionItem(
      icon: Icons.wb_sunny_outlined,
      label: 'Asupan vitamin D',
      value: vitaminD,
    ),
    PredictionItem(
      icon: Icons.directions_run_rounded,
      label: 'Aktivitas fisik',
      value: physicalActivity,
    ),
    PredictionItem(
      icon: Icons.smoke_free_rounded,
      label: 'Merokok',
      value: smoking,
    ),
    PredictionItem(
      icon: Icons.local_bar_outlined,
      label: 'Konsumsi alkohol',
      value: alcohol,
    ),
    PredictionItem(
      icon: Icons.medical_services_outlined,
      label: 'Kondisi medis',
      value: shorten(medicalCondition),
    ),
    PredictionItem(
      icon: Icons.medication_outlined,
      label: 'Penggunaan obat',
      value: shorten(medication),
    ),
    PredictionItem(
      icon: Icons.healing_rounded,
      label: 'Riwayat patah tulang',
      value: fractureHistory,
    ),
  ];
}

// ---------------------------------------------------------------------------
// Model: hasil interpretasi respons API menjadi teks & rekomendasi lokal
// ---------------------------------------------------------------------------
class ScreeningInterpretation {
  final String riskTitle;
  final String riskCategory;
  final String statusHasil;
  final String riskDescription;
  final bool isPositive;
  final List<String> recommendations;

  const ScreeningInterpretation({
    required this.riskTitle,
    required this.riskCategory,
    required this.statusHasil,
    required this.riskDescription,
    required this.isPositive,
    required this.recommendations,
  });
}

ScreeningInterpretation interpretApiResponse(FastApiPredictResponse res) {
  final isPos = res.prediction == 1;

  final String riskTitle;
  final String riskCategory;
  final String statusHasil;
  final String riskDescription;

  if (isPos) {
    statusHasil = 'Terindikasi Osteoporosis';
    if (res.probability >= 70) {
      riskTitle = 'risiko tinggi';
      riskCategory = 'Risiko Tinggi';
      riskDescription =
          'Anda memiliki risiko tinggi untuk mengalami osteoporosis. '
          'Disarankan untuk segera berkonsultasi dengan dokter spesialis tulang.';
    } else {
      riskTitle = 'risiko sedang';
      riskCategory = 'Risiko Sedang';
      riskDescription =
          'Anda memiliki risiko sedang untuk mengalami osteoporosis. '
          'Pertimbangkan untuk berkonsultasi dengan tenaga medis.';
    }
  } else {
    riskTitle = 'risiko rendah';
    riskCategory = 'Risiko Rendah';
    statusHasil = 'Tidak Terindikasi Osteoporosis';
    riskDescription =
        'Kepadatan tulang Anda kemungkinan besar dalam kondisi baik. '
        'Terus pertahankan gaya hidup sehat.';
  }

  final recs = isPos
      ? [
          'Konsultasikan dengan dokter spesialis tulang.',
          'Lakukan pemeriksaan lebih lanjut (misalnya DEXA Scan).',
          'Pertahankan asupan kalsium dan vitamin D.',
          'Lakukan olahraga beban secara rutin.',
          'Hindari merokok dan konsumsi alkohol berlebihan.',
        ]
      : [
          'Tetap pertahankan pola hidup sehat.',
          'Penuhi kebutuhan kalsium dan vitamin D.',
          'Lakukan olahraga beban secara rutin.',
          'Hindari merokok dan konsumsi alkohol berlebihan.',
          'Lakukan skrining secara berkala.',
        ];

  return ScreeningInterpretation(
    riskTitle: riskTitle,
    riskCategory: riskCategory,
    statusHasil: statusHasil,
    riskDescription: riskDescription,
    isPositive: isPos,
    recommendations: recs,
  );
}
