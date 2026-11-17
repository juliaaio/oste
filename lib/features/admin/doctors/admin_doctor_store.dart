import '../../../services/doctor_repository.dart';
export '../../../services/doctor_repository.dart';
export 'add_doctor_page.dart';
export 'edit_doctor_page.dart';
export 'admin_doctor_list_page.dart';

/// Store dokter admin yang mengarahkan langsung ke single source of truth [DoctorRepository].
/// Memastikan setiap operasi CRUD dokter oleh Admin langsung sinkron ke POV Pasien.
typedef AdminDoctorStore = DoctorRepository;


