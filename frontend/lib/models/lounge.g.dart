// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lounge _$LoungeFromJson(Map<String, dynamic> json) => Lounge(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      universityId: json['universityId'] as String,
      campusId: json['campusId'] as String,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      accountNumber: json['accountNumber'] as String?,
      bankName: json['bankName'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      opening: json['opening'] as String?,
      closing: json['closing'] as String?,
      isApproved: json['isApproved'] as bool,
      isActive: json['isActive'] as bool,
      ratingAverage: (json['ratingAverage'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LoungeToJson(Lounge instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerId': instance.ownerId,
      'universityId': instance.universityId,
      'campusId': instance.campusId,
      'description': instance.description,
      'logo': instance.logo,
      'accountNumber': instance.accountNumber,
      'bankName': instance.bankName,
      'accountHolderName': instance.accountHolderName,
      'opening': instance.opening,
      'closing': instance.closing,
      'isApproved': instance.isApproved,
      'isActive': instance.isActive,
      'ratingAverage': instance.ratingAverage,
      'ratingCount': instance.ratingCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
