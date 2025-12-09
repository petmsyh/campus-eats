import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lounge.g.dart';

@JsonSerializable()
class Lounge extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final String universityId;
  final String campusId;
  final String? description;
  final String? logo;
  final String? accountNumber;
  final String? bankName;
  final String? accountHolderName;
  final String? opening;
  final String? closing;
  final bool isApproved;
  final bool isActive;
  @JsonKey(defaultValue: 0.0)
  final double ratingAverage;
  @JsonKey(defaultValue: 0)
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lounge({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.universityId,
    required this.campusId,
    this.description,
    this.logo,
    this.accountNumber,
    this.bankName,
    this.accountHolderName,
    this.opening,
    this.closing,
    required this.isApproved,
    required this.isActive,
    required this.ratingAverage,
    required this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lounge.fromJson(Map<String, dynamic> json) => _$LoungeFromJson(json);
  Map<String, dynamic> toJson() => _$LoungeToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        ownerId,
        universityId,
        campusId,
        description,
        logo,
        accountNumber,
        bankName,
        accountHolderName,
        opening,
        closing,
        isApproved,
        isActive,
        ratingAverage,
        ratingCount,
        createdAt,
        updatedAt,
      ];
}
