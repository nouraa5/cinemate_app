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
  final String? profileImage; // New field: path to profile image

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.gender,
    required this.dateOfBirth,
    this.profileImage,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
    String? gender,
    String? dateOfBirth,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'profile_image': profileImage, // Added field
    };
    if (includeId) {
      map['id'] = id.toString();
    }
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        phoneNumber: map['phone_number'],
        password: map['password'],
        gender: map['gender'],
        dateOfBirth: map['date_of_birth'],
        profileImage: map['profile_image'], // Added field
      );

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
