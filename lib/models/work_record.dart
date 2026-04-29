class WorkRecord {
  final int? id;
  final String date;
  final String type;
  final double? hours;
  final double? days;
  final double? quantity;
  final double? unitPrice;
  final double totalAmount;
  final int? projectId;
  final int? workerId;
  final String? remark;
  final String? createdAt;
  final String? updatedAt;

  WorkRecord({
    this.id,
    required this.date,
    required this.type,
    this.hours,
    this.days,
    this.quantity,
    this.unitPrice,
    required this.totalAmount,
    this.projectId,
    this.workerId,
    this.remark,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'hours': hours,
      'days': days,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'project_id': projectId,
      'worker_id': workerId,
      'remark': remark,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory WorkRecord.fromMap(Map<String, dynamic> map) {
    return WorkRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      type: map['type'] as String,
      hours: map['hours'] as double?,
      days: map['days'] as double?,
      quantity: map['quantity'] as double?,
      unitPrice: map['unit_price'] as double?,
      totalAmount: (map['total_amount'] as num).toDouble(),
      projectId: map['project_id'] as int?,
      workerId: map['worker_id'] as int?,
      remark: map['remark'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  WorkRecord copyWith({
    int? id,
    String? date,
    String? type,
    double? hours,
    double? days,
    double? quantity,
    double? unitPrice,
    double? totalAmount,
    int? projectId,
    int? workerId,
    String? remark,
  }) {
    return WorkRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      hours: hours ?? this.hours,
      days: days ?? this.days,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      projectId: projectId ?? this.projectId,
      workerId: workerId ?? this.workerId,
      remark: remark ?? this.remark,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}
