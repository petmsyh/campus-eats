import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order extends Equatable {
  final String id;
  final String userId;
  final String loungeId;
  final List<OrderItem> items;
  final double totalPrice;
  final String status;
  final String paymentMethod;
  final String? paymentId;
  final String? contractId;
  final String qrCode;
  final String? qrCodeImage;
  final DateTime? estimatedReadyTime;
  final DateTime? deliveredAt;
  final double commission;
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.loungeId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    this.paymentId,
    this.contractId,
    required this.qrCode,
    this.qrCodeImage,
    this.estimatedReadyTime,
    this.deliveredAt,
    required this.commission,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        loungeId,
        items,
        totalPrice,
        status,
        paymentMethod,
        paymentId,
        contractId,
        qrCode,
        qrCodeImage,
        estimatedReadyTime,
        deliveredAt,
        commission,
        notes,
        cancellationReason,
        createdAt,
        updatedAt,
      ];
}

@JsonSerializable()
class OrderItem extends Equatable {
  final String foodId;
  final String name;
  final int quantity;
  final double price;
  final double subtotal;
  final int? estimatedTime;

  const OrderItem({
    required this.foodId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.estimatedTime,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  @override
  List<Object?> get props => [foodId, name, quantity, price, subtotal, estimatedTime];
}

// Order Status
enum OrderStatus {
  pending,
  preparing,
  ready,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
