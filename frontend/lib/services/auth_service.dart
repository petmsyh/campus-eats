import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  // Register new user
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String phone,
    required String password,
    required String universityId,
    required String campusId,
    String? email,
    String role = 'user',
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'name': name,
          'phone': phone,
          'password': password,
          'universityId': universityId,
          'campusId': campusId,
          'email': email,
          'role': role,
        },
      );

      return ApiResponse.fromJson(response, null);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Verify OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-otp',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        (data) => Map<String, dynamic>.from(data as Map),
      );
      final token = response['data']?['token'];
      if (token is String) {
        _apiClient.setAccessToken(token);
      }

      return apiResponse;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // Login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        (data) => Map<String, dynamic>.from(data as Map),
      );
      final token = response['data']?['token'];
      if (token is String) {
        _apiClient.setAccessToken(token);
      }

      return apiResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Resend OTP
  Future<ApiResponse<Map<String, dynamic>>> resendOtp({
    required String phone,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/resend-otp',
        data: {
          'phone': phone,
        },
      );

      return ApiResponse.fromJson(response, null);
    } catch (e) {
      throw Exception('Resend OTP failed: $e');
    }
  }

  // Get current user
  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');

      return ApiResponse.fromJson(
        response,
        (data) => User.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Get user failed: $e');
    }
  }
}
