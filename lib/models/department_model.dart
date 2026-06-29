import 'package:hive/hive.dart';

part 'department_model.g.dart';

@HiveType(typeId: 1)
class DepartmentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String year;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String? iconUrl;

  @HiveField(5)
  final double price;

  @HiveField(6)
  final bool isDefault;

  @HiveField(7)
  final int examCount;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final bool isActive;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.year,
    this.description,
    this.iconUrl,
    required this.price,
    this.isDefault = false,
    this.examCount = 0,
    required this.createdAt,
    this.isActive = true,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      year: json['year'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      price: (json['price'] as num).toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
      examCount: json['exam_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'year': year,
        'description': description,
        'icon_url': iconUrl,
        'price': price,
        'is_default': isDefault,
        'exam_count': examCount,
        'created_at': createdAt.toIso8601String(),
        'is_active': isActive,
      };

  DepartmentModel copyWith({
    String? name,
    String? description,
    double? price,
    bool? isDefault,
    int? examCount,
    bool? isActive,
  }) {
    return DepartmentModel(
      id: id,
      name: name ?? this.name,
      year: year,
      description: description ?? this.description,
      iconUrl: iconUrl,
      price: price ?? this.price,
      isDefault: isDefault ?? this.isDefault,
      examCount: examCount ?? this.examCount,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
