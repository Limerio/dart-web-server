class ValidationUtil {
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  static bool isValidISBN(String isbn) {
    // Remove hyphens and spaces
    final cleanISBN = isbn.replaceAll(RegExp(r'[\s-]'), '');

    // ISBN-10 validation
    if (cleanISBN.length == 10) {
      int sum = 0;
      for (int i = 0; i < 9; i++) {
        final digit = int.tryParse(cleanISBN[i]);
        if (digit == null) return false;
        sum += digit * (10 - i);
      }

      // Check digit can be 'X' for ISBN-10
      final lastChar = cleanISBN[9].toUpperCase();
      final lastDigit = lastChar == 'X' ? 10 : int.tryParse(lastChar);
      if (lastDigit == null) return false;

      return (sum + lastDigit) % 11 == 0;
    }

    // ISBN-13 validation
    if (cleanISBN.length == 13) {
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        final digit = int.tryParse(cleanISBN[i]);
        if (digit == null) return false;
        sum += (i % 2 == 0) ? digit : digit * 3;
      }

      final lastDigit = int.tryParse(cleanISBN[12]);
      if (lastDigit == null) return false;

      return (10 - (sum % 10)) % 10 == lastDigit;
    }

    return false;
  }
}
