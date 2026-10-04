# MedFleet (مدفليت) — Flutter

تطبيق الصيدلية مربوط على `https://medfleet.net/api/v1/`.
الدخول بحساب مدفليت الحقيقي (نفس يوزر تطبيق iOS).

## Run
```
flutter pub get
flutter run
```

## API
| Method | Screen | Endpoint |
|---|---|---|
| `login` | Login | `POST /auth/login` |
| `medicines` | Stock, Home, Count | `GET /buyer/inventory` |
| `returns` | Returns | `GET /buyer/purchase-returns` |
| `recentScans` / `preview` / `confirm` | Scan | `GET /buyer/scans`, `POST /buyer/scan/preview`, `POST /buyer/scan/commit` |
| `postCount` | Count | `POST /buyer/inventory/audit/commit` |
| `logout` | Settings | `POST /auth/logout` |
