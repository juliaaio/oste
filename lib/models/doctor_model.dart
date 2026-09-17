class Doctor {
  final String id;
  final String name;
  final String specialist;
  final double rating;
  final bool isOnline;
  final String imageUrl;
  final int experienceYears;
  final int patientCount;
  final String hospital;
  final String biography;
  final int consultationFee;
  final String consultationFeeFormatted;
  final String schedules;
  final List<String> todaySchedule;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialist,
    required this.rating,
    this.isOnline = true,
    required this.imageUrl,
    this.experienceYears = 8,
    this.patientCount = 1000,
    this.hospital = 'RS Orthopedi & Traumatologi',
    this.biography =
        'Dokter spesialis ortopedi berpengalaman dalam penanganan kesehatan tulang, sendi, dan pencegahan osteoporosis.',
    this.consultationFee = 50000,
    this.consultationFeeFormatted = 'Rp 50.000',
    this.schedules = 'Senin - Jumat, 09:00 - 16:00',
    this.todaySchedule = const ['09.00', '13.00', '19.00'],
  });
}
