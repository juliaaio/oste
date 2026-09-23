import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oste/core/utils/password_validator.dart';
import 'package:oste/core/widgets/password_requirements_card.dart';

/// Halaman Ubah Kata Sandi – mengikuti design language aplikasi Oste.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Palet warna – konsisten dengan halaman lain
  static const Color _butterYellow = Color(0xFFF7C948);
  static const Color _background = Color(0xFFFFF9EF);
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textLabel = Color(0xFF334155);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _iconGrey = Color(0xFF94A3B8);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _cardWhite = Color(0xFFFFFFFF);

  bool get _hasMinLength =>
      PasswordValidator.hasMinLength(_newPasswordController.text);
  bool get _hasUppercase =>
      PasswordValidator.hasUppercase(_newPasswordController.text);
  bool get _hasLowercase =>
      PasswordValidator.hasLowercase(_newPasswordController.text);
  bool get _hasDigit => PasswordValidator.hasDigit(_newPasswordController.text);
  bool get _hasSpecialChar =>
      PasswordValidator.hasSpecialChar(_newPasswordController.text);

  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasDigit &&
      _hasSpecialChar;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onNewPasswordChanged);
  }

  void _onNewPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onNewPasswordChanged);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Verify all requirements are satisfied and passwords match before Firebase call
    if (!_isPasswordValid ||
        _newPasswordController.text.trim() !=
            _confirmPasswordController.text.trim()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        _showSnackBar('User not found. Please log in again.', isError: true);
        return;
      }

      // Reauthenticate with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPasswordController.text.trim());

      if (mounted) {
        _showSnackBar('Password updated successfully.', isError: false);
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showSnackBar(e.message ?? 'An error occurred.', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 28,
            color: _textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textDark,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── Card form ───────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: _cardWhite,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPasswordField(
                          label: 'Current Password',
                          controller: _currentPasswordController,
                          obscure: _obscureCurrent,
                          onToggle: () =>
                              setState(() => _obscureCurrent = !_obscureCurrent),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Current password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(
                          label: 'New Password',
                          controller: _newPasswordController,
                          obscure: _obscureNew,
                          onChanged: (value) => setState(() {}),
                          onToggle: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'New password is required';
                            }
                            if (!_isPasswordValid) {
                              return 'Password does not meet all requirements';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordRequirementsCard(),
                        const SizedBox(height: 20),
                        _buildPasswordField(
                          label: 'Confirm New Password',
                          controller: _confirmPasswordController,
                          obscure: _obscureConfirm,
                          onToggle: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please confirm your new password';
                            }
                            if (value.trim() != _newPasswordController.text.trim()) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Save button ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _butterYellow,
                        foregroundColor: _textDark,
                        disabledBackgroundColor: _butterYellow.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: _textDark,
                              ),
                            )
                          : const Text('Save Password'),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirementsCard() {
    return PasswordRequirementsCard(
      hasMinLength: _hasMinLength,
      hasUppercase: _hasUppercase,
      hasLowercase: _hasLowercase,
      hasDigit: _hasDigit,
      hasSpecialChar: _hasSpecialChar,
    );
  }

  /// Builds a labeled password field with show/hide toggle.
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: _textLabel,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _textDark,
          ),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _textMuted.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _butterYellow, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: _iconGrey,
              ),
              onPressed: onToggle,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
