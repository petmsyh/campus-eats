import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'food.g.dart';

@JsonSerializable()
class Food extends Equatable {
  final String id;
  final String loungeId;
  final String name;
  final String? description;
  final String category;
  final double price;
  final String? image;
  final int estimatedTime;
  final bool isAvailable;
  final List<String>? ingredients;
  final List<String>? allergens;
  final bool isVegetarian;
  final String spicyLevel;
  @JsonKey(defaultValue: 0.0)
  final double ratingAverage;
  @JsonKey(defaultValue: 0)
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Food({
    required this.id,
    required this.loungeId,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    this.image,
    required this.estimatedTime,
    required this.isAvailable,
    this.ingredients,
    this.allergens,
    required this.isVegetarian,
    required this.spicyLevel,
    required this.ratingAverage,
    required this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);
  Map<String, dynamic> toJson() => _$FoodToJson(this);

  @override
  List<Object?> get props => [
        id,
        loungeId,
        name,
        description,
        category,
        price,
        image,
        estimatedTime,
        isAvailable,
        ingredients,
        allergens,
        isVegetarian,
        spicyLevel,
        ratingAverage,
        ratingCount,
        createdAt,
        updatedAt,
      ];
}

// Categories
enum FoodCategory {
  breakfast,
  lunch,
  dinner,
  snacks,
  drinks,
  dessert,
}

// Spicy Levels
enum SpicyLevel {
  none,
  mild,
  medium,
  hot,
  veryHot,
}
