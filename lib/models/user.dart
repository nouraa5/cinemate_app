import 'package:crypto/crypto.dart';
import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String password; // Hashed
  final String gender;
  final String dateOfBirth;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.gender,
    required this.dateOfBirth,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
    String? gender,
    String? dateOfBirth,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  // Convert user data to a map (for database storage)
  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'password': password, // Already hashed
      'gender': gender,
      'date_of_birth': dateOfBirth,
    };
    if (includeId) {
      map['id'] = id as String;
    }
    return map;
  }

  // Create user from database map
  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        phoneNumber: map['phone_number'],
        password: map['password'],
        gender: map['gender'],
        dateOfBirth: map['date_of_birth'],
      );

  // Hash password using SHA-256
  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
