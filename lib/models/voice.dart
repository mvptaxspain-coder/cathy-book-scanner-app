class Voice {
  final String id;
  final String name;
  final String description;
  final String? audioPath;
  final DateTime createdAt;
  final bool isDefault;

  Voice({
    required this.id,
    required this.name,
    required this.description,
    this.audioPath,
    required this.createdAt,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'audioPath': audioPath,
    'createdAt': createdAt.toIso8601String(),
    'isDefault': isDefault,
  };

  factory Voice.fromJson(Map<String, dynamic> json) => Voice(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    audioPath: json['audioPath'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isDefault: json['isDefault'] as bool? ?? false,
  );
}
