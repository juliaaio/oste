/// Utility helper for password validation across the application.
class PasswordValidator {
  PasswordValidator._();

  static final RegExp uppercaseRegExp = RegExp(r'[A-Z]');
  static final RegExp lowercaseRegExp = RegExp(r'[a-z]');
  static final RegExp digitRegExp = RegExp(r'[0-9]');
  static final RegExp specialCharRegExp = RegExp(r'[^a-zA-Z0-9\s]');

  /// Minimum 8 characters
  static bool hasMinLength(String password) => password.length >= 8;

  /// At least one uppercase letter
  static bool hasUppercase(String password) =>
      password.contains(uppercaseRegExp);

  /// At least one lowercase letter
  static bool hasLowercase(String password) =>
      password.contains(lowercaseRegExp);

  /// At least one digit
  static bool hasDigit(String password) => password.contains(digitRegExp);

  /// At least one special character (non-alphanumeric, non-whitespace)
  static bool hasSpecialChar(String password) =>
      password.contains(specialCharRegExp);

  /// Checks if all password rules are satisfied
  static bool isValid(String password) =>
      hasMinLength(password) &&
      hasUppercase(password) &&
      hasLowercase(password) &&
      hasDigit(password) &&
      hasSpecialChar(password);
}
