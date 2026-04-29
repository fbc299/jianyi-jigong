class SalaryRecord {
  final int? id;
  final String date;
  final String type;
  final double amount;
  final String? paymentMethod;
  final String? periodStart;
  final String? periodEnd;
  final String? remark;
  final String? createdAt;
  final String? updatedAt;

  SalaryRecord({
    this.id,
    required this.date,
    required this.type,
    required this.amount,
    this.paymentMethod,
    this.periodStart,
    this.periodEnd,
    this.remark,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'amount': amount,
      'payment_method': paymentMethod,
      'period_start': periodStart,
      'period_end': periodEnd,
      'remark': remark,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory SalaryRecord.fromMap(Map<String, dynamic> map) {
    return SalaryRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String?,
      periodStart: map['period_start'] as String?,
      periodEnd: map['period_end'] as String?,
      remark: map['remark'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  SalaryRecord copyWith({
    int? id,
    String? date,
    String? type,
    double? amount,
    String? paymentMethod,
    String? periodStart,
    String? periodEnd,
    String? remark,
  }) {
    return SalaryRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      remark: remark ?? this.remark,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}
