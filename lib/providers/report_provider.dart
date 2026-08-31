import 'package:flutter/material.dart';

import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  bool _isLoading = false;
  String? _errorMessage;

  double _totalCredit = 0;
  double _totalDebit = 0;
  double _balance = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalCredit => _totalCredit;
  double get totalDebit => _totalDebit;
  double get balance => _balance;

  Future<void> loadReports() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _totalCredit = await _reportService.getTotalCredit();
      _totalDebit = await _reportService.getTotalDebit();
      _balance = await _reportService.getBalance();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}