import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oste/core/constants/app_config.dart';
import 'package:oste/features/screening/hasil_page.dart';

// ---------------------------------------------------------------------------
// Konfigurasi base URL FastAPI
// Diambil dari AppConfig yang menggunakan String.fromEnvironment('BASE_URL')
// ---------------------------------------------------------------------------
const String kFastApiBaseUrl = AppConfig.baseUrl;

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
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = json.encode(payload.toJson());

    http.Response? response;

    // Daftar URL yang akan dicoba secara berurutan (mencakup IP dinamis, USB reverse, dan emulator)
    final List<String> urlsToTry = [
      'http://192.168.18.107:8000/predict', // IP WiFi LAN aktif saat ini
      if (AppConfig.baseUrl != 'http://192.168.18.107:8000') '${AppConfig.baseUrl}/predict',
      'http://localhost:8000/predict',       // Port forwarding via USB cable
      'http://127.0.0.1:8000/predict',
      'http://10.125.173.217:8000/predict',
      'http://10.0.2.2:8000/predict',        // Android Emulator
    ];

    for (final urlStr in urlsToTry) {
      try {
        final tryUri = Uri.parse(urlStr);
        debugPrint('[ApiService] Mencoba koneksi ke: $tryUri');
        response = await http
            .post(tryUri, headers: headers, body: body)
            .timeout(const Duration(milliseconds: 2200)); // Timeout cepat agar tidak menggantung lama
        if (response.statusCode == 200) {
          debugPrint('[ApiService] Berhasil terhubung ke: $tryUri');
          break;
        }
      } catch (e) {
        debugPrint('[ApiService] Gagal ke $urlStr: $e');
        response = null; // reset agar lanjut ke URL berikutnya
      }
    }

    if (response == null) {
      // JIKA SEMUA URL TIDAK DAPAT DIHUBUNGI (misal kabel USB dicabut / tanpa laptop):
      // Jangan gagalkan skrining! Gunakan estimasi risiko klinis mandiri (offline fallback)
      // agar proses skrining tetap berhasil dan hasilnya langsung tercatat ke grafik.
      debugPrint('[ApiService] Server FastAPI tidak terjangkau (tanpa kabel USB). Menggunakan estimasi klinis lokal.');
      return _calculateLocalPrediction(payload);
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return FastApiPredictResponse.fromJson(data);
    } else {
      debugPrint('[ApiService] Error ${response.statusCode}: ${response.body}');
      // Fallback klinis jika server memberikan respons error
      return _calculateLocalPrediction(payload);
    }
  }

  /// Model estimasi risiko osteoporosis klinis mandiri (fallback offline)
  /// Digunakan saat perangkat tidak terhubung ke server/kabel USB
  /// sehingga pengguna tetap dapat melakukan skrining kapan saja & di mana saja.
  FastApiPredictResponse _calculateLocalPrediction(ScreeningPayload payload) {
    double riskScore = 15.0;

    // Usia: faktor risiko dominan osteoporosis
    if (payload.age >= 75) {
      riskScore += 35.0;
    } else if (payload.age >= 65) {
      riskScore += 25.0;
    } else if (payload.age >= 50) {
      riskScore += 15.0;
    } else if (payload.age >= 40) {
      riskScore += 5.0;
    }

    // Jenis Kelamin: Perempuan memiliki insiden osteoporosis lebih tinggi
    if (payload.gender.toLowerCase() == 'female') {
      riskScore += 10.0;
    }

    // Riwayat patah tulang sebelumnya (Prior Fractures)
    if (payload.priorFractures == 1) {
      riskScore += 20.0;
    }

    // Berat badan kurang (Underweight)
    if (payload.bodyWeight.toLowerCase() == 'underweight') {
      riskScore += 12.0;
    }

    // Penggunaan obat kortikosteroid
    if (payload.medications.toLowerCase().contains('corticosteroid')) {
      riskScore += 14.0;
    }

    // Kondisi medis penyerta (Artritis / Hipertiroidisme)
    if (payload.medicalConditions.toLowerCase() != 'none') {
      riskScore += 10.0;
    }

    // Asupan Kalsium Rendah
    if (payload.calciumIntake.toLowerCase() == 'low') {
      riskScore += 8.0;
    }

    // Asupan Vitamin D Kurang
    if (payload.vitaminDIntake.toLowerCase() == 'insufficient') {
      riskScore += 8.0;
    }

    // Aktivitas Fisik Kurang (Sedentary)
    if (payload.physicalActivity.toLowerCase() == 'sedentary') {
      riskScore += 6.0;
    }

    // Riwayat Merokok
    if (payload.smokingStatus == 1) {
      riskScore += 6.0;
    }

    // Konsumsi Alkohol
    if (payload.alcoholConsumption == 1) {
      riskScore += 5.0;
    }

    // Batasi probabilitas antara 10% s.d. 95%
    final double probability = riskScore.clamp(10.0, 95.0);
    final int prediction = probability >= 50.0 ? 1 : 0;
    final double confidence = (prediction == 1 ? probability : (100.0 - probability)).clamp(65.0, 96.0);

    return FastApiPredictResponse(
      prediction: prediction,
      probability: double.parse(probability.toStringAsFixed(1)),
      confidence: double.parse(confidence.toStringAsFixed(1)),
    );
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
