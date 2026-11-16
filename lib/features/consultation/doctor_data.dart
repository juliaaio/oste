import 'package:oste/models/doctor_model.dart';
import 'package:oste/services/doctor_repository.dart';

/// Data sumber awal dokter (statis) untuk inisialisasi tanpa duplikasi
const List<DoctorModel> initialDoctorList = [
  DoctorModel(
    id: 'doc_1',
    name: 'dr. Andi Wijaya, Sp.OT',
    specialist: 'Sp. Orthopaedi & Traumatologi',
    email: 'dr.andi.wijaya@osteo.id',
    phone: '081234567801',
    rating: 4.9,
    reviewCount: 1540,
    patientCount: 1540,
    isOnline: false, // status real-time dari DoctorPresenceService (Firestore)
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=400&q=80',
    experienceYears: 10,
    hospital: 'RS Orthopedi & Traumatologi',
    biography:
        'Berpengalaman lebih dari 10 tahun menangani berbagai masalah tulang dan sendi, termasuk osteoporosis, dengan pendekatan perawatan yang sesuai dengan kondisi dan kebutuhan pasien.',
    consultationFee: 75000,
    consultationFeeFormatted: 'Rp 75.000',
    schedules: 'Senin - Kamis, 08:00 - 15:00',
    availableDays: ['Senin', 'Selasa', 'Rabu', 'Kamis'],
    todaySchedule: ['08.00', '10.30', '13.00'],
  ),
  DoctorModel(
    id: 'doc_2',
    name: 'dr. Edwin Ardianta, Sp.OT(K)., Subsp.PL',
    specialist: 'Sp. Bedah Panggul & Lutut',
    email: 'dr.edwin.ardianta@osteo.id',
    phone: '081234567802',
    rating: 4.8,
    reviewCount: 1820,
    patientCount: 1820,
    isOnline: false,
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=400&q=80',
    experienceYears: 12,
    hospital: 'RS Siloam Hospitals',
    biography:
        'Konsultan rekonstruksi sendi panggul dan lutut dengan fokus pada pemulihan mobilitas dan kepadatan tulang usia lanjut.',
    consultationFee: 90000,
    consultationFeeFormatted: 'Rp 90.000',
    schedules: 'Senin - Jumat, 10:00 - 16:00',
    availableDays: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'],
    todaySchedule: ['10.00', '13.00', '15.00'],
  ),
  DoctorModel(
    id: 'doc_3',
    name: 'dr. Hanna Widiana, Sp.OT',
    specialist: 'Sp. Orthopaedi & Traumatologi',
    email: 'dr.hanna.widiana@osteo.id',
    phone: '081234567803',
    rating: 4.82,
    reviewCount: 1210,
    patientCount: 1210,
    isOnline: false,
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=400&q=80',
    experienceYears: 8,
    hospital: 'RSUP Dr. Sardjito',
    biography:
        'Berdedikasi dalam edukasi pencegahan osteoporosis sejak dini serta penanganan patah tulang kerapuhan.',
    consultationFee: 65000,
    consultationFeeFormatted: 'Rp 65.000',
    schedules: 'Selasa - Sabtu, 09:00 - 14:00',
    availableDays: ['Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'],
    todaySchedule: ['09.00', '11.30', '13.30'],
  ),
  DoctorModel(
    id: 'doc_4',
    name: 'dr. Dian Amelia, Sp.OT',
    specialist: 'Sp. Orthopaedi & Traumatologi',
    email: 'dr.dian.amelia@osteo.id',
    phone: '081234567804',
    rating: 4.8,
    reviewCount: 980,
    patientCount: 980,
    isOnline: false,
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1594824813620-6d43ecbb6251?auto=format&fit=crop&w=400&q=80',
    experienceYears: 7,
    hospital: 'RS Mitra Keluarga',
    biography:
        'Fokus pada kesehatan tulang wanita, penanganan osteopenia, serta terapi suplemen kalsium dan vitamin D.',
    consultationFee: 60000,
    consultationFeeFormatted: 'Rp 60.000',
    schedules: 'Senin - Jumat, 13:00 - 18:00',
    availableDays: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'],
    todaySchedule: ['13.00', '15.00', '17.00'],
  ),
  DoctorModel(
    id: 'doc_5',
    name: 'dr. Martin Hartono, Sp.OT.,Subsp.A(K)., M.H',
    specialist: 'Sp. OT (Subspesialis Orthopaedi Anak)',
    email: 'dr.martin.hartono@osteo.id',
    phone: '081234567805',
    rating: 4.91,
    reviewCount: 2300,
    patientCount: 2300,
    isOnline: false,
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=400&q=80',
    experienceYears: 15,
    hospital: 'RS Cipto Mangunkusumo',
    biography:
        'Subspesialis ortopedi anak dan kelainan pertumbuhan tulang dengan pengalaman klinis dan advokasi kesehatan tulang keluarga.',
    consultationFee: 100000,
    consultationFeeFormatted: 'Rp 100.000',
    schedules: 'Senin - Rabu, 08:30 - 15:30',
    availableDays: ['Senin', 'Selasa', 'Rabu'],
    todaySchedule: ['08.30', '11.00', '14.00'],
  ),
];

/// Getter dokter aktif yang terhubung langsung ke single source of truth [DoctorRepository].
/// Pasien hanya melihat dokter yang berstatus aktif (isActive == true).
List<DoctorModel> get doctorList => DoctorRepository().activeDoctors;
