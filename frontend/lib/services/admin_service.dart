import 'dart:convert';
import 'api_client.dart';

class AdminService {
  final ApiClient apiClient;

  AdminService(this.apiClient);

  // Get dashboard statistics
  Future<Map<String, dynamic>> getStats() async {
    final response = await apiClient.get('/admin/stats');
    return response['data'];
  }

  // User Management
  Future<Map<String, dynamic>> getUsers({
    String? role,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (role != null) queryParams['role'] = role;

    final response = await apiClient.get('/admin/users', queryParams: queryParams);
    return response;
  }

  Future<Map<String, dynamic>> updateUserStatus(
    String userId,
    bool isActive,
  ) async {
    final response = await apiClient.put(
      '/admin/users/$userId',
      data: {'isActive': isActive},
    );
    return response;
  }

  // Lounge Management
  Future<Map<String, dynamic>> getLounges({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status;

    final response = await apiClient.get('/admin/lounges', queryParams: queryParams);
    return response;
  }

  Future<Map<String, dynamic>> approveLounge(
    String loungeId,
    bool isApproved,
  ) async {
    final response = await apiClient.put(
      '/admin/lounges/$loungeId/approve',
      data: {'isApproved': isApproved},
    );
    return response;
  }

  // University Management
  Future<List<dynamic>> getUniversities() async {
    final response = await apiClient.get('/admin/universities');
    return response['data'];
  }

  Future<Map<String, dynamic>> createUniversity({
    required String name,
    required String code,
    required String city,
    required String region,
  }) async {
    final response = await apiClient.post(
      '/admin/universities',
      data: {
        'name': name,
        'code': code,
        'city': city,
        'region': region,
      },
    );
    return response;
  }

  // Campus Management
  Future<List<dynamic>> getCampuses({String? universityId}) async {
    final queryParams = <String, String>{};
    if (universityId != null) queryParams['universityId'] = universityId;

    final response = await apiClient.get('/admin/campuses', queryParams: queryParams);
    return response['data'];
  }

  Future<Map<String, dynamic>> createCampus({
    required String name,
    required String universityId,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    final response = await apiClient.post(
      '/admin/campuses',
      data: {
        'name': name,
        'universityId': universityId,
        'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    return response;
  }

  // Orders Management
  Future<Map<String, dynamic>> getOrders({
    String? status,
    String? loungeId,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status;
    if (loungeId != null) queryParams['loungeId'] = loungeId;

    final response = await apiClient.get('/admin/orders', queryParams: queryParams);
    return response;
  }

  // Commissions Management
  Future<Map<String, dynamic>> getCommissions({
    String? loungeId,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (loungeId != null) queryParams['loungeId'] = loungeId;
    if (status != null) queryParams['status'] = status;

    final response = await apiClient.get('/admin/commissions', queryParams: queryParams);
    return response;
  }

  // Payments Management
  Future<Map<String, dynamic>> getPayments({
    String? type,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;

    final response = await apiClient.get('/admin/payments', queryParams: queryParams);
    return response;
  }
}
