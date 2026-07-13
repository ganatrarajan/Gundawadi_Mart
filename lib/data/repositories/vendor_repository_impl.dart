import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../models/vendor_model.dart';

class VendorRepositoryImpl implements VendorRepository {
  final DioClient _dioClient;

  VendorRepositoryImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> getVendors({String search = '', int page = 1}) async {
    final response = await _dioClient.get(
      ApiEndpoints.vendors,
      queryParameters: {
        'search': search,
        'page': page,
      },
    );

    final rawData = response.data;
    List<dynamic> list = [];
    int currentPage = 1;
    int lastPage = 1;
    int total = 0;

    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      if (rawData['data'] is List) {
        list = rawData['data'];
      }
      
      currentPage = int.tryParse(rawData['current_page']?.toString() ?? '') ?? 1;
      lastPage = int.tryParse(rawData['last_page']?.toString() ?? '') ?? 1;
      total = int.tryParse(rawData['total']?.toString() ?? '') ?? list.length;
      
      if (rawData['meta'] is Map) {
        final meta = rawData['meta'] as Map;
        currentPage = int.tryParse(meta['current_page']?.toString() ?? '') ?? currentPage;
        lastPage = int.tryParse(meta['last_page']?.toString() ?? '') ?? lastPage;
        total = int.tryParse(meta['total']?.toString() ?? '') ?? total;
      }
    }

    final vendors = list.map((json) => VendorModel.fromJson(json as Map<String, dynamic>)).toList();
    
    return {
      'vendors': vendors,
      'currentPage': currentPage,
      'lastPage': lastPage,
      'total': total,
    };
  }

  @override
  Future<VendorModel> getVendorDetails(int id) async {
    final response = await _dioClient.get(ApiEndpoints.vendorDetails(id));
    return VendorModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
