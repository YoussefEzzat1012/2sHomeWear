import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 0)
class CustomerModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String city;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] is String ? json['phone'] : '',
      email: json['email'] is String ? json['email'] : '',
      city: json['city'] is String ? json['city'] : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'city': city,
    };
  }

  CustomerModel copyWith({
    String? phone,
  }) {
    return CustomerModel(
      id: id,
      name: name,
      phone: phone ?? this.phone,
      email: email,
      city: city,
    );
  }
}
