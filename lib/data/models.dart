enum MedStatus { ok, soon, low, expired }

class Medicine {
  final String id; // barcode / id
  final String name;
  final String lot;
  final String expiry; // MM/YYYY
  final int qty;
  final int daysLeft; // negative = already expired
  final int price; // IQD

  const Medicine({
    required this.id,
    required this.name,
    required this.lot,
    required this.expiry,
    required this.qty,
    required this.daysLeft,
    required this.price,
  });

  MedStatus get status {
    if (daysLeft < 0) return MedStatus.expired;
    if (daysLeft <= 60) return MedStatus.soon;
    if (qty <= 20) return MedStatus.low;
    return MedStatus.ok;
  }

  // TODO(api): factory Medicine.fromJson(Map<String, dynamic> j)
}

enum ReturnStatus { pending, approved, rejected }

class ReturnRequest {
  final String id;
  final String supplier;
  final int items;
  final int value; // IQD
  final ReturnStatus status;
  const ReturnRequest({
    required this.id,
    required this.supplier,
    required this.items,
    required this.value,
    required this.status,
  });
}

class ScannedInvoice {
  final String no;
  final String supplier;
  final int items;
  final int total; // IQD
  const ScannedInvoice({
    required this.no,
    required this.supplier,
    required this.items,
    required this.total,
  });
}

/// One line in a stock count: the medicine and how many were physically counted.
class CountLine {
  final Medicine med;
  int counted;
  CountLine(this.med, this.counted);

  int get diff => counted - med.qty;
  int get value => diff * med.price;
}
