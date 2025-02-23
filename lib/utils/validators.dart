String? validateUserInput({
  required String password,
  required String confirmPassword,
  required String dateOfBirth,
  required String gender,
}) {
  if (password.length < 6) {
    return "Password must be at least 6 characters long";
  }

  if (password != confirmPassword) {
    return "Passwords do not match";
  }

  try {
    DateTime birthDate = DateTime.parse(dateOfBirth);
    int age = DateTime.now().year - birthDate.year;
    if (age < 15) {
      return "You must be at least 15 years old";
    }
  } catch (e) {
    return "Invalid date format. Use YYYY-MM-DD";
  }

  if (!['Male', 'Female', 'Other'].contains(gender)) {
    return "Invalid gender selection";
  }

  return null; // Valid input
}
