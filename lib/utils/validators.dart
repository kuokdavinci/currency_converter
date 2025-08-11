String? validateAmount(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Please enter number";
  }
  final number = double.tryParse(value);
  if (number == null || number <= 0) {
    return "Please enter positive number";
  }
  return null;
}
