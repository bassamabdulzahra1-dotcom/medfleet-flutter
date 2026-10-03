/// 1234567 -> "1,234,567"
String fmtNum(num n) {
  final s = n.abs().round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/// Signed money text: "-44,000 د.ع" / "+3,000 د.ع" / "0 د.ع"
String fmtMoney(num n, {bool signed = true}) {
  if (n == 0) return '0 د.ع';
  final sign = !signed ? '' : (n < 0 ? '-' : '+');
  return '$sign${fmtNum(n)} د.ع';
}
