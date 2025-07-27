class ServiceModel {
  String id;
  String name;
  String detail;
  String major;
  String type;
  int? quantity;
  DateTime? addedToCartAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.detail,
    required this.major,
    required this.type,
    this.quantity, 
    this.addedToCartAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'detail': detail,
    'major': major,
    'type': type,
    'quantity': quantity,
    'addedToCartAt': addedToCartAt,
  };

  factory ServiceModel.fromMap(Map<String, dynamic> map) => ServiceModel(
    id: map['id'],
    name: map['name'],
    detail: map['detail'],
    major: map['major'],
    type: map['type'],
    quantity: map['quantity'],
    addedToCartAt: map['addedToCartAt'],
  );
}
