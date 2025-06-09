// lib/core/service/sim_data_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_sim_data/sim_data.dart';
import 'package:flutter_sim_data/sim_data_model.dart';

class SimDataService {
  static final SimDataService _instance = SimDataService._internal();
  factory SimDataService() => _instance;
  SimDataService._internal();

  final SimData _simDataPlugin = SimData();
  List<SimDataModel>? _cachedSimData;
  bool _permissionRequested = false;
  bool _permissionGranted = false;

  /// Get all SIM data from device
  Future<List<SimDataModel>?> getSimData() async {
    try {
      if (_cachedSimData != null) {
        return _cachedSimData;
      }

      debugPrint('🔍 SimDataService: Fetching SIM data...');
      final simData = await _simDataPlugin.getSimData();

      if (simData.isNotEmpty) {
        _cachedSimData = simData;
        _permissionGranted = true;
        debugPrint('✅ SimDataService: Found ${simData.length} SIM(s)');

        // Log SIM details for debugging
        for (int i = 0; i < simData.length; i++) {
          final sim = simData[i];
          debugPrint(
            '📱 SIM $i: ${sim.carrierName} - ${sim.phoneNumber} (Slot ${sim.simSlotIndex})',
          );
        }
      } else {
        debugPrint('⚠️ SimDataService: No SIM data found');
      }

      return simData;
    } catch (e) {
      debugPrint('❌ SimDataService: Error getting SIM data: $e');
      _permissionGranted = false;
      return null;
    } finally {
      _permissionRequested = true;
    }
  }

  /// Get primary phone number (first SIM or user selected)
  String? getPrimaryPhoneNumber() {
    if (_cachedSimData == null || _cachedSimData!.isEmpty) {
      return null;
    }

    // Return first SIM's phone number as primary
    final primarySim = _cachedSimData!.first;
    return _cleanPhoneNumber(primarySim.phoneNumber);
  }

  /// Get all available phone numbers
  List<String> getAllPhoneNumbers() {
    if (_cachedSimData == null || _cachedSimData!.isEmpty) {
      return [];
    }

    return _cachedSimData!
        .map((sim) => _cleanPhoneNumber(sim.phoneNumber))
        .where((number) => number.isNotEmpty)
        .toList();
  }

  /// Get SIM data with cleaned phone numbers for display
  List<SimDisplayModel> getSimDisplayData() {
    if (_cachedSimData == null || _cachedSimData!.isEmpty) {
      return [];
    }

    return _cachedSimData!
        .map((sim) {
          return SimDisplayModel(
            carrierName: sim.carrierName,
            phoneNumber: _cleanPhoneNumber(sim.phoneNumber),
            displayName: sim.displayName,
            simSlotIndex: sim.simSlotIndex,
            subscriptionId: sim.subscriptionId,
            isESIM: sim.isESIM,
          );
        })
        .where((sim) => sim.phoneNumber.isNotEmpty)
        .toList();
  }

  /// Clean and format phone number
  String _cleanPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';

    // Remove any non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Remove country code if present (+91)
    if (cleaned.startsWith('+91')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    }

    // Ensure it's 10 digits for Indian numbers
    if (cleaned.length == 10 && cleaned.startsWith(RegExp(r'[6-9]'))) {
      return cleaned;
    }

    return '';
  }

  /// Check if permission was requested
  bool get permissionRequested => _permissionRequested;

  /// Check if permission was granted
  bool get permissionGranted => _permissionGranted;

  /// Check if multiple SIMs available
  bool get hasMultipleSims => (_cachedSimData?.length ?? 0) > 1;

  /// Check if any SIM data available
  bool get hasSimData => (_cachedSimData?.length ?? 0) > 0;

  /// Clear cached data (for testing)
  void clearCache() {
    _cachedSimData = null;
    _permissionRequested = false;
    _permissionGranted = false;
  }
}

/// Model for displaying SIM data in UI
class SimDisplayModel {
  final String carrierName;
  final String phoneNumber;
  final String displayName;
  final int simSlotIndex;
  final int subscriptionId;
  final bool isESIM;

  SimDisplayModel({
    required this.carrierName,
    required this.phoneNumber,
    required this.displayName,
    required this.simSlotIndex,
    required this.subscriptionId,
    required this.isESIM,
  });

  String get displayText {
    if (carrierName.isNotEmpty && phoneNumber.isNotEmpty) {
      return '$phoneNumber ($carrierName)';
    } else if (phoneNumber.isNotEmpty) {
      return phoneNumber;
    } else if (carrierName.isNotEmpty) {
      return carrierName;
    }
    return 'SIM ${simSlotIndex + 1}';
  }

  String get shortDisplayText {
    return phoneNumber.isNotEmpty ? phoneNumber : 'SIM ${simSlotIndex + 1}';
  }
}
