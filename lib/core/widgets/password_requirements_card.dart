import 'package:flutter/material.dart';

/// Live password requirements card showing validation status for each requirement.
class PasswordRequirementsCard extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigit;
  final bool hasSpecialChar;

  const PasswordRequirementsCard({
    super.key,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecialChar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password harus mengandung:',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('Minimal 8 karakter', hasMinLength),
          const SizedBox(height: 5),
          _buildRequirementItem(
            'Huruf besar dan huruf kecil',
            hasUppercase && hasLowercase,
          ),
          const SizedBox(height: 5),
          _buildRequirementItem('Angka', hasDigit),
          const SizedBox(height: 5),
          _buildRequirementItem(
            'Karakter khusus (contoh: !@#)',
            hasSpecialChar,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        isMet
            ? const Icon(
                Icons.check_circle,
                size: 13,
                color: Color(0xFF10B981),
              )
            : Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD4A359),
                    width: 1.3,
                  ),
                ),
              ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: isMet ? const Color(0xFF047857) : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}
