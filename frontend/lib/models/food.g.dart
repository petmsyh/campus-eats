// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Food _$FoodFromJson(Map<String, dynamic> json) => Food(
      id: json['id'] as String,
      loungeId: json['loungeId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String?,
      estimatedTime: (json['estimatedTime'] as num).toInt(),
      isAvailable: json['isAvailable'] as bool,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      allergens: (json['allergens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isVegetarian: json['isVegetarian'] as bool,
      spicyLevel: json['spicyLevel'] as String,
      ratingAverage: (json['ratingAverage'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FoodToJson(Food instance) => <String, dynamic>{
      'id': instance.id,
      'loungeId': instance.loungeId,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'price': instance.price,
      'image': instance.image,
      'estimatedTime': instance.estimatedTime,
      'isAvailable': instance.isAvailable,
      'ingredients': instance.ingredients,
      'allergens': instance.allergens,
      'isVegetarian': instance.isVegetarian,
      'spicyLevel': instance.spicyLevel,
      'ratingAverage': instance.ratingAverage,
      'ratingCount': instance.ratingCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
