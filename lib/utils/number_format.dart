String formatIntWithCommas(int value) {
  final digits = value.abs().toString();
  final output = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) output.write(',');
    output.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}$output';
}

String formatMoneyCents(int cents) {
  final whole = cents.abs() ~/ 100;
  final fraction = (cents.abs() % 100).toString().padLeft(2, '0');
  return '${cents < 0 ? '-₱' : '₱'}${formatIntWithCommas(whole)}.$fraction';
}

int? parseCommaSeparatedInt(String input) {
  final value = input.trim();
  final valid = RegExp(r'^(?:\d+|\d{1,3}(?:,\d{3})+)$');
  if (!valid.hasMatch(value)) return null;
  return int.tryParse(value.replaceAll(',', ''));
}

double? parseCommaSeparatedDouble(String input) {
  final value = input.trim();
  final valid = RegExp(r'^(?:(?:\d+|\d{1,3}(?:,\d{3})+))(?:\.\d+)?$');
  if (!valid.hasMatch(value)) return null;
  return double.tryParse(value.replaceAll(',', ''));
}
