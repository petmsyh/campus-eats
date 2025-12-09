import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String universityId;
  final String campusId;
  final double walletBalance;
  final bool isActive;
  final bool isVerified;
  final String? fcmToken;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    required this.universityId,
    required this.campusId,
    required this.walletBalance,
    required this.isActive,
    required this.isVerified,
    this.fcmToken,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? universityId,
    String? campusId,
    double? walletBalance,
    bool? isActive,
    bool? isVerified,
    String? fcmToken,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      universityId: universityId ?? this.universityId,
      campusId: campusId ?? this.campusId,
      walletBalance: walletBalance ?? this.walletBalance,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      fcmToken: fcmToken ?? this.fcmToken,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        role,
        universityId,
        campusId,
        walletBalance,
        isActive,
        isVerified,
        fcmToken,
        lastLogin,
        createdAt,
        updatedAt,
      ];
}
