import 'package:flutter/material.dart';
import '../../data/models/vendor_model.dart';
import '../../domain/repositories/vendor_repository.dart';

class VendorProvider extends ChangeNotifier {
  final VendorRepository _vendorRepository;

  List<VendorModel> _vendors = [];
  VendorModel? _selectedVendor;
  
  bool _isLoadingVendors = false;
  bool _isLoadingDetails = false;
  String? _error;
  
  int _currentPage = 1;
  int _lastPage = 1;
  String _currentSearch = '';

  VendorProvider(this._vendorRepository);

  List<VendorModel> get vendors => _vendors;
  VendorModel? get selectedVendor => _selectedVendor;
  bool get isLoadingVendors => _isLoadingVendors;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMore => _currentPage < _lastPage;

  // Fetch Vendors
  Future<void> fetchVendors({String search = '', bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _vendors.clear();
    } else {
      if (_currentPage > 1 && !hasMore) return;
    }

    _isLoadingVendors = true;
    _error = null;
    _currentSearch = search;
    notifyListeners();

    try {
      final result = await _vendorRepository.getVendors(
        search: _currentSearch,
        page: _currentPage,
      );

      final List<VendorModel> fetchedVendors = result['vendors'];
      if (isRefresh) {
        _vendors = fetchedVendors;
      } else {
        _vendors.addAll(fetchedVendors);
      }

      _currentPage = result['currentPage'] + 1;
      _lastPage = result['lastPage'];
      _isLoadingVendors = false;
      notifyListeners();
    } catch (e) {
      _isLoadingVendors = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Fetch Vendor details + products catalog
  Future<void> fetchVendorDetails(int id) async {
    _isLoadingDetails = true;
    _error = null;
    _selectedVendor = null;
    notifyListeners();

    try {
      _selectedVendor = await _vendorRepository.getVendorDetails(id);
      _isLoadingDetails = false;
      notifyListeners();
    } catch (e) {
      _isLoadingDetails = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
