// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      loungeId: json['loungeId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      paymentId: json['paymentId'] as String?,
      contractId: json['contractId'] as String?,
      qrCode: json['qrCode'] as String,
      qrCodeImage: json['qrCodeImage'] as String?,
      estimatedReadyTime: json['estimatedReadyTime'] == null
          ? null
          : DateTime.parse(json['estimatedReadyTime'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      commission: (json['commission'] as num).toDouble(),
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'loungeId': instance.loungeId,
      'items': instance.items,
      'totalPrice': instance.totalPrice,
      'status': instance.status,
      'paymentMethod': instance.paymentMethod,
      'paymentId': instance.paymentId,
      'contractId': instance.contractId,
      'qrCode': instance.qrCode,
      'qrCodeImage': instance.qrCodeImage,
      'estimatedReadyTime': instance.estimatedReadyTime?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'commission': instance.commission,
      'notes': instance.notes,
      'cancellationReason': instance.cancellationReason,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
      foodId: json['foodId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      estimatedTime: (json['estimatedTime'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'foodId': instance.foodId,
      'name': instance.name,
      'quantity': instance.quantity,
      'price': instance.price,
      'subtotal': instance.subtotal,
      'estimatedTime': instance.estimatedTime,
    };
