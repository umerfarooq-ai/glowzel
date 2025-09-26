class PhoneValidator {
  static String? validate(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return 'Phone number cannot be empty';
    }
    String pattern = r'^\+92(3)([0-9]{9})$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(phoneNumber)) {
      return 'Invalid phone number format. Use +923XXXXXXXXX.';
    }
    return null;
  }
}
