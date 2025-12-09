import 'api_client.dart';

class LoungeService {
  final ApiClient apiClient;

  LoungeService(this.apiClient);

  // Get lounge orders
  Future<Map<String, dynamic>> getOrders({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status;

    final response = await apiClient.get('/orders', queryParams: queryParams);
    return response;
  }

  // Get order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    final response = await apiClient.get('/orders/$orderId');
    return response['data'];
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    final response = await apiClient.put(
      '/orders/$orderId/status',
      data: {'status': status},
    );
    return response;
  }

  // Verify QR code
  Future<Map<String, dynamic>> verifyQRCode(String qrCode) async {
    final response = await apiClient.post(
      '/orders/verify-qr',
      data: {'qrCode': qrCode},
    );
    return response;
  }

  // Food Menu Management
  Future<List<dynamic>> getFoods(String loungeId) async {
    final response = await apiClient.get(
      '/foods',
      queryParams: {'loungeId': loungeId},
    );
    return response['data'];
  }

  Future<Map<String, dynamic>> createFood({
    required String loungeId,
    required String name,
    required String category,
    required double price,
    required int estimatedTime,
    String? description,
    String? image,
    List<String>? ingredients,
    List<String>? allergens,
    bool? isVegetarian,
    String? spicyLevel,
  }) async {
    final response = await apiClient.post(
      '/foods',
      data: {
        'loungeId': loungeId,
        'name': name,
        'category': category,
        'price': price,
        'estimatedTime': estimatedTime,
        if (description != null) 'description': description,
        if (image != null) 'image': image,
        if (ingredients != null) 'ingredients': ingredients,
        if (allergens != null) 'allergens': allergens,
        if (isVegetarian != null) 'isVegetarian': isVegetarian,
        if (spicyLevel != null) 'spicyLevel': spicyLevel,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> updateFood({
    required String foodId,
    String? name,
    String? description,
    String? category,
    double? price,
    String? image,
    int? estimatedTime,
    bool? isAvailable,
    List<String>? ingredients,
    List<String>? allergens,
    bool? isVegetarian,
    String? spicyLevel,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (category != null) data['category'] = category;
    if (price != null) data['price'] = price;
    if (image != null) data['image'] = image;
    if (estimatedTime != null) data['estimatedTime'] = estimatedTime;
    if (isAvailable != null) data['isAvailable'] = isAvailable;
    if (ingredients != null) data['ingredients'] = ingredients;
    if (allergens != null) data['allergens'] = allergens;
    if (isVegetarian != null) data['isVegetarian'] = isVegetarian;
    if (spicyLevel != null) data['spicyLevel'] = spicyLevel;

    final response = await apiClient.put('/foods/$foodId', data: data);
    return response;
  }

  Future<void> deleteFood(String foodId) async {
    await apiClient.delete('/foods/$foodId');
  }

  Future<Map<String, dynamic>?> getMyLounge() async {
    final response = await apiClient.get('/lounges/my');
    final lounges = (response['data'] as List?) ?? [];
    if (lounges.isEmpty) return null;
    return Map<String, dynamic>.from(lounges.first as Map);
  }

  // Commission Management
  Future<Map<String, dynamic>> getCommissions({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiClient.get(
      '/commissions',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getCommissionStats() async {
    final response = await apiClient.get('/commissions/stats');
    return response['data'];
  }

  // Update lounge profile
  Future<Map<String, dynamic>> updateLounge({
    required String loungeId,
    String? name,
    String? description,
    String? logo,
    Map<String, String>? bankAccount,
    List<Map<String, String>>? bankAccounts,
    List<Map<String, String>>? wallets,
    Map<String, String>? operatingHours,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (logo != null) data['logo'] = logo;
    if (bankAccount != null) data['bankAccount'] = bankAccount;
    if (bankAccounts != null) data['bankAccounts'] = bankAccounts;
    if (wallets != null) data['wallets'] = wallets;
    if (operatingHours != null) data['operatingHours'] = operatingHours;

    final response = await apiClient.put('/lounges/$loungeId', data: data);
    return response;
  }

  Future<Map<String, dynamic>> getLoungeProfile(String loungeId) async {
    final response = await apiClient.get('/lounges/$loungeId/profile');
    return response['data'];
  }
}
