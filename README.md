# MedFleet (مدفليت) — Flutter

تطبيق الصيدلية: تسجيل الدخول، الرئيسية، المخزن، ماسحة الفاتورة، الجرد المخزني، مردود الشراء، الإعدادات.
Emerald brand · light + dark (deep green, no black) · RTL Arabic.

الدخول التجريبي: `bakr.amer` / `1234` (MockRepo).

## Run
```
flutter pub get
flutter run
```

## Structure
```
lib/
  main.dart                 app, RTL locale, light/dark ThemeMode
  core/tokens.dart          palette, fonts, theme
  core/icons.dart           MfIcon, BrandMark, Wordmark
  core/format.dart          fmtNum / fmtMoney
  data/models.dart          Medicine, ReturnRequest, ScannedInvoice, CountLine
  data/repository.dart      MedFleetRepo + MockRepo
  widgets/common.dart       shared UI
  screens/                  splash, login, shell, home, stock, scan, count, returns, settings
```

## Backend hookup
Implement `MedFleetRepo` and set `repo = ApiRepo();` in `lib/data/repository.dart`.

| Method | Used by | Suggested endpoint |
|---|---|---|
| `login(u, p)` | Login | `POST /auth/login` |
| `medicines()` | Stock, Count | `GET /pharmacy/medicines` |
| `returns()` | Returns | `GET /pharmacy/purchase-returns` |
| `readInvoice(code)` | Scan | `GET /pharmacy/invoices/by-code/{code}` |
| `confirmInvoice(no)` | Scan | `POST /pharmacy/invoices/{no}/receive` |
| `postCount(lines, note)` | Count | `POST /pharmacy/stock-counts` |

## Not wired yet
- Real camera scanning (`mobile_scanner`)
- Biometric login (`local_auth`)
- Offline bundled fonts
- Screens marked "قيد التصميم": branch, language, new return, manual invoice number
