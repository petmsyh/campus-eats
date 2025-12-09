// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      universityId: json['universityId'] as String,
      campusId: json['campusId'] as String,
      walletBalance: (json['walletBalance'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      isVerified: json['isVerified'] as bool,
      fcmToken: json['fcmToken'] as String?,
      lastLogin: json['lastLogin'] == null
          ? null
          : DateTime.parse(json['lastLogin'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'role': instance.role,
      'universityId': instance.universityId,
      'campusId': instance.campusId,
      'walletBalance': instance.walletBalance,
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
      'fcmToken': instance.fcmToken,
      'lastLogin': instance.lastLogin?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
