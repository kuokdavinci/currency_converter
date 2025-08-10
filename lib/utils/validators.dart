String? validateAmount(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Please enter amount";
  }
  final number = double.tryParse(value);
  if (number == null || number <= 0) {
    return "Enter a valid number";
  }
  return null;
}
