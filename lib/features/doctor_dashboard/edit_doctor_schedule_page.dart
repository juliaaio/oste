import 'package:flutter/material.dart';
import 'package:oste/features/doctor_dashboard/widgets/doctor_decorations.dart';
import 'package:oste/models/doctor_schedule_model.dart';
import 'package:oste/services/doctor_schedule_service.dart';

/// Halaman Form Edit Jadwal Praktik Dokter
class EditDoctorSchedulePage extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const EditDoctorSchedulePage({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<EditDoctorSchedulePage> createState() => _EditDoctorSchedulePageState();
}

class _EditDoctorSchedulePageState extends State<EditDoctorSchedulePage> {
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isActive;
  late Set<int> _selectedDays;
  late TextEditingController _noteController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Ambil data jadwal yang ada saat ini dari service
    final existing = DoctorScheduleService().getSchedule(
      widget.doctorId,
      fallbackDoctorName: widget.doctorName,
    );

    _selectedDate = DateTime.tryParse(existing.date) ?? DateTime.now();
    _startTime = _parseTimeOfDay(existing.startTime, const TimeOfDay(hour: 8, minute: 0));
    _endTime = _parseTimeOfDay(existing.endTime, const TimeOfDay(hour: 12, minute: 0));
    _isActive = existing.isActive;
    _selectedDays = Set<int>.from(existing.repeatDays);
    _noteController = TextEditingController(text: existing.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTimeOfDay(String timeStr, TimeOfDay fallback) {
    try {
      final parts = timeStr.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return fallback;
    }
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DoctorThemeColors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: DoctorThemeColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DoctorThemeColors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: DoctorThemeColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DoctorThemeColors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: DoctorThemeColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _saveSchedule() async {
    // Validasi jam mulai dan jam selesai
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam selesai praktik harus setelah jam mulai.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 hari jadwal berulang.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final updatedSchedule = DoctorSchedule(
      doctorId: widget.doctorId,
      doctorName: widget.doctorName,
      isActive: _isActive,
      date: dateStr,
      startTime: _formatTimeOfDay(_startTime),
      endTime: _formatTimeOfDay(_endTime),
      repeatDays: _selectedDays.toList()..sort(),
      note: _noteController.text.trim(),
      updatedAt: DateTime.now(),
    );

    try {
      await DoctorScheduleService().saveSchedule(updatedSchedule);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Jadwal praktik berhasil disimpan dan disinkronkan.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan jadwal: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayName = DoctorSchedule.getDayName(_selectedDate.weekday);
    final monthName = DoctorSchedule.getMonthName(_selectedDate.month);
    final formattedDateText = '$dayName, ${_selectedDate.day} $monthName ${_selectedDate.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: DoctorThemeColors.textDark,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Jadwal Praktik',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: DoctorThemeColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Status Praktik ──────────────────────────────────────────
              const Text(
                'Status Praktik',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DoctorThemeColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Opsi Aktif
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isActive = true),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: _isActive
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFE2E8F0),
                            width: _isActive ? 1.8 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Aktif',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: _isActive
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: _isActive
                                    ? const Color(0xFF047857)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Opsi Tidak Aktif
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isActive = false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: !_isActive
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: !_isActive
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFE2E8F0),
                            width: !_isActive ? 1.8 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tidak Aktif',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: !_isActive
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: !_isActive
                                    ? const Color(0xFFB91C1C)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ── 2. Pilih Tanggal ───────────────────────────────────────────
              const Text(
                'Pilih Tanggal Praktik',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DoctorThemeColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: DoctorThemeColors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          formattedDateText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DoctorThemeColors.textDark,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.edit_calendar_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ── 3. Jam Mulai & Jam Selesai ─────────────────────────────────
              Row(
                children: [
                  // Jam Mulai
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jam Mulai',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DoctorThemeColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickStartTime,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 18,
                                  color: DoctorThemeColors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTimeOfDay(_startTime),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: DoctorThemeColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Jam Selesai
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jam Selesai',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DoctorThemeColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickEndTime,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 18,
                                  color: Color(0xFF7C3AED),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTimeOfDay(_endTime),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: DoctorThemeColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ── 4. Pilihan Hari Berulang (Senin–Minggu) Checkbox ────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilihan Hari Berulang',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: DoctorThemeColors.textDark,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedDays = {1, 2, 3, 4, 5};
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Senin–Jumat',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: DoctorThemeColors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedDays = {1, 2, 3, 4, 5, 6, 7};
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Semua',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: List.generate(7, (index) {
                    final dayNum = index + 1;
                    final dayName = DoctorSchedule.getDayName(dayNum);
                    final isChecked = _selectedDays.contains(dayNum);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            if (_selectedDays.length > 1) {
                              _selectedDays.remove(dayNum);
                            }
                          } else {
                            _selectedDays.add(dayNum);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          border: index < 6
                              ? const Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFF1F5F9),
                                    width: 1,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              activeColor: DoctorThemeColors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedDays.add(dayNum);
                                  } else {
                                    if (_selectedDays.length > 1) {
                                      _selectedDays.remove(dayNum);
                                    }
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isChecked
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isChecked
                                    ? DoctorThemeColors.textDark
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            const Spacer(),
                            if (isChecked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Praktik',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 22),

              // ── 5. Catatan (Opsional) ──────────────────────────────────────
              const Text(
                'Catatan (Opsional)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DoctorThemeColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: DoctorThemeColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Contoh: Menerima konsultasi osteoporosis dan pemeriksaan berkala sendi.',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: DoctorThemeColors.orange, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── 6. Tombol Simpan ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7C948), // Butter Yellow
                    foregroundColor: DoctorThemeColors.textDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: DoctorThemeColors.textDark,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                              color: DoctorThemeColors.textDark,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Simpan Jadwal Praktik',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
