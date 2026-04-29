class Worker {
  final int? id;
  final String name;
  final String? phone;
  final String? skill;
  final double? dailyRate;
  final String? remark;
  final String? createdAt;

  Worker({
    this.id,
    required this.name,
    this.phone,
    this.skill,
    this.dailyRate,
    this.remark,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'skill': skill,
      'daily_rate': dailyRate,
      'remark': remark,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      skill: map['skill'] as String?,
      dailyRate: map['daily_rate'] as double?,
      remark: map['remark'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}
