import 'api_client.dart';

class ReferenceService {
  final ApiClient apiClient;

  ReferenceService(this.apiClient);

  Future<List<dynamic>> getUniversities() async {
    final response = await apiClient.get('/reference/universities');
    return response['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getCampuses({String? universityId}) async {
    final response = await apiClient.get(
      '/reference/campuses',
      queryParams: universityId != null ? {'universityId': universityId} : null,
    );
    return response['data'] as List<dynamic>;
  }
}
