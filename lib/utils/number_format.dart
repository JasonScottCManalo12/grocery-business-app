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

/// Formats an in-progress decimal input with grouping separators.
///
/// Unlike [parseCommaSeparatedDouble], this accepts temporarily incomplete
/// input such as `1234.` while the user is still typing.
String? formatEditableGroupedDecimal(String input) {
  final clean = input.replaceAll(',', '');
  if (clean.isEmpty) return '';
  if (!RegExp(r'^\d*(?:\.\d*)?$').hasMatch(clean)) return null;

  final dot = clean.indexOf('.');
  final wholeText = dot < 0 ? clean : clean.substring(0, dot);
  final fraction = dot < 0 ? null : clean.substring(dot + 1);
  final whole = wholeText.isEmpty ? '0' : wholeText;
  final parsedWhole = int.tryParse(whole);
  if (parsedWhole == null) return null;
  final groupedWhole = formatIntWithCommas(parsedWhole);
  return fraction == null ? groupedWhole : '$groupedWhole.$fraction';
}
