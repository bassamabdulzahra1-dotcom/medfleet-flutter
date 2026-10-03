import 'models.dart';

/// All server access goes through this interface.
/// Replace [MockRepo] with a real implementation (Dio/http) when the API is ready.
abstract class MedFleetRepo {
  Future<bool> login(String username, String password);
  Future<List<Medicine>> medicines();
  Future<List<ReturnRequest>> returns();

  /// Called after the camera decodes an invoice barcode/QR.
  Future<ScannedInvoice> readInvoice(String code);
  Future<void> confirmInvoice(String invoiceNo);

  /// Posts the stock-count differences to accounting.
  Future<void> postCount(List<CountLine> lines, String note);
}

MedFleetRepo repo = MockRepo();

class MockRepo implements MedFleetRepo {
  static const _meds = <Medicine>[
    Medicine(id: '1', name: 'باراسيتامول 500 ملغ', lot: 'B2209', expiry: '08/2027', qty: 240, daysLeft: 620, price: 1500),
    Medicine(id: '2', name: 'أموكسيسيلين 250 ملغ', lot: 'A1187', expiry: '11/2026', qty: 36, daysLeft: 24, price: 4250),
    Medicine(id: '3', name: 'أوميبرازول 20 ملغ', lot: 'C0412', expiry: '09/2027', qty: 112, daysLeft: 690, price: 3000),
    Medicine(id: '4', name: 'إيبوبروفين 400 ملغ', lot: 'C5502', expiry: '11/2026', qty: 58, daysLeft: 41, price: 2000),
    Medicine(id: '5', name: 'ميتفورمين 850 ملغ', lot: 'D3340', expiry: '02/2028', qty: 18, daysLeft: 880, price: 2750),
    Medicine(id: '6', name: 'سيتريزين 10 ملغ', lot: '07731', expiry: '03/2026', qty: 9, daysLeft: -200, price: 1750),
    Medicine(id: '7', name: 'فيتامين د3 1000 وحدة', lot: 'E7710', expiry: '06/2028', qty: 95, daysLeft: 980, price: 6500),
    Medicine(id: '8', name: 'سالبيوتامول بخاخ', lot: 'F1029', expiry: '01/2027', qty: 7, daysLeft: 90, price: 5500),
  ];

  static const _returns = <ReturnRequest>[
    ReturnRequest(id: 'RT-2041', supplier: 'شركة النور للأدوية', items: 6, value: 184500, status: ReturnStatus.pending),
    ReturnRequest(id: 'RT-2038', supplier: 'مذخر الرافدين', items: 3, value: 92000, status: ReturnStatus.pending),
    ReturnRequest(id: 'RT-2029', supplier: 'شركة دجلة الطبية', items: 11, value: 410750, status: ReturnStatus.pending),
    ReturnRequest(id: 'RT-2011', supplier: 'شركة النور للأدوية', items: 4, value: 76000, status: ReturnStatus.approved),
    ReturnRequest(id: 'RT-1996', supplier: 'مذخر بغداد', items: 2, value: 35500, status: ReturnStatus.rejected),
  ];

  Future<T> _d<T>(T v, [int ms = 600]) => Future.delayed(Duration(milliseconds: ms), () => v);

  @override
  Future<bool> login(String u, String p) =>
      _d(u.trim().toLowerCase() == 'bakr.amer' && p == '1234', 900);

  @override
  Future<List<Medicine>> medicines() => _d(_meds, 200);

  @override
  Future<List<ReturnRequest>> returns() => _d(_returns, 200);

  @override
  Future<ScannedInvoice> readInvoice(String code) => _d(
      const ScannedInvoice(no: 'INV-13147', supplier: 'شركة النور للأدوية', items: 24, total: 1285000), 300);

  @override
  Future<void> confirmInvoice(String invoiceNo) => _d(null, 700);

  @override
  Future<void> postCount(List<CountLine> lines, String note) => _d(null, 900);
}
