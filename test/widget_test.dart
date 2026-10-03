import 'package:flutter_test/flutter_test.dart';
import 'package:medfleet/core/format.dart';

void main() {
  test('number formatting', () {
    expect(fmtNum(1285000), '1,285,000');
    expect(fmtMoney(-44000), '-44,000 د.ع');
    expect(fmtMoney(0), '0 د.ع');
  });
}
