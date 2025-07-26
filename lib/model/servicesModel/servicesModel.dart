class ServiceModel {
  final String id;
  final String name;
  final String detail;
  final String major;
  final String type; 

  ServiceModel({
    required this.id,
    required this.name,
    required this.detail,
    required this.major,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'detail': detail,
    'major': major,
    'type': type,
  };

  factory ServiceModel.fromMap(Map<String, dynamic> map) => ServiceModel(
    id: map['id'],
    name: map['name'],
    detail: map['detail'],
    major: map['major'],
    type: map['type'],
  );
}
