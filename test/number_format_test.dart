import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_business_app/utils/number_format.dart';

void main() {
  test('formats integer values with thousands separators', () {
    expect(formatIntWithCommas(0), '0');
    expect(formatIntWithCommas(999), '999');
    expect(formatIntWithCommas(1000), '1,000');
    expect(formatIntWithCommas(1234567), '1,234,567');
    expect(formatIntWithCommas(-1234567), '-1,234,567');
  });

  test('formats PHP amounts with comma grouping and two decimal places', () {
    expect(formatMoneyCents(0), '₱0.00');
    expect(formatMoneyCents(123456), '₱1,234.56');
    expect(formatMoneyCents(123456789), '₱1,234,567.89');
    expect(formatMoneyCents(-123456), '-₱1,234.56');
  });

  test('formats in-progress decimal input with grouping beyond four digits', () {
    expect(formatEditableGroupedDecimal('1234'), '1,234');
    expect(formatEditableGroupedDecimal('12345'), '12,345');
    expect(formatEditableGroupedDecimal('1234567'), '1,234,567');
    expect(formatEditableGroupedDecimal('123456789'), '123,456,789');
    expect(formatEditableGroupedDecimal('123456789.00'), '123,456,789.00');
    expect(formatEditableGroupedDecimal('1234.'), '1,234.');
    expect(formatEditableGroupedDecimal(''), '');
    expect(formatEditableGroupedDecimal('12.3.4'), isNull);
  });

  test('parses comma-grouped whole quantities and rejects malformed grouping', () {
    expect(parseCommaSeparatedInt('1,234'), 1234);
    expect(parseCommaSeparatedInt('1234'), 1234);
    expect(parseCommaSeparatedInt('1,234,567'), 1234567);
    expect(parseCommaSeparatedInt('12,34'), isNull);
    expect(parseCommaSeparatedInt('1,,234'), isNull);
    expect(parseCommaSeparatedInt('1.5'), isNull);
  });

  test('parses comma-grouped decimal money values', () {
    expect(parseCommaSeparatedDouble('1,234.56'), 1234.56);
    expect(parseCommaSeparatedDouble('1234.56'), 1234.56);
    expect(parseCommaSeparatedDouble('1,234,567'), 1234567);
    expect(parseCommaSeparatedDouble('12,34.56'), isNull);
    expect(parseCommaSeparatedDouble('1,,234.56'), isNull);
  });
}
