class Project {
  final int? id;
  final String name;
  final String? address;
  final String? startDate;
  final String? endDate;
  final String status;
  final String? remark;
  final String? createdAt;

  Project({
    this.id,
    required this.name,
    this.address,
    this.startDate,
    this.endDate,
    this.status = 'active',
    this.remark,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'remark': remark,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String?,
      startDate: map['start_date'] as String?,
      endDate: map['end_date'] as String?,
      status: map['status'] as String? ?? 'active',
      remark: map['remark'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}
