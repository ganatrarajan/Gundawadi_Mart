import '../../data/models/vendor_model.dart';

abstract class VendorRepository {
  Future<Map<String, dynamic>> getVendors({String search = '', int page = 1});
  Future<VendorModel> getVendorDetails(int id);
}
