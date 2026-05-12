class FarmAnimal {
  final int? id;
  final String name;
  final String type;
  final String age;
  final String riskLevel;
  final String diseaseType;
  final String diseaseDuration;
  final String createdAt;
  final String updatedAt;

  const FarmAnimal({
    this.id,
    required this.name,
    required this.type,
    required this.age,
    this.riskLevel = 'Unknown',
    this.diseaseType = 'Not diagnosed',
    this.diseaseDuration = 'Unknown',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'age': age,
      'risk_level': riskLevel,
      'disease_type': diseaseType,
      'disease_duration': diseaseDuration,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory FarmAnimal.fromMap(Map<String, dynamic> map) {
    return FarmAnimal(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      age: map['age'] as String,
      riskLevel: map['risk_level'] as String? ?? 'Unknown',
      diseaseType: map['disease_type'] as String? ?? 'Not diagnosed',
      diseaseDuration: map['disease_duration'] as String? ?? 'Unknown',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  FarmAnimal copyWith({
    int? id,
    String? name,
    String? type,
    String? age,
    String? riskLevel,
    String? diseaseType,
    String? diseaseDuration,
    String? createdAt,
    String? updatedAt,
  }) {
    return FarmAnimal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      age: age ?? this.age,
      riskLevel: riskLevel ?? this.riskLevel,
      diseaseType: diseaseType ?? this.diseaseType,
      diseaseDuration: diseaseDuration ?? this.diseaseDuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}