// lib/src/presentation/cubits/cloud_kitchen/cloud_kitchen_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/client/dio_api_client.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/presentation/cubits/cloud_kitchen/cloud_kitchen_state.dart';

class CloudKitchenCubit extends Cubit<CloudKitchenState> {
  final DioApiClient _apiClient;
  final LoggerService _logger = LoggerService();

  CloudKitchenCubit({required DioApiClient apiClient})
    : _apiClient = apiClient,
      super(CloudKitchenInitial());

  /// Check if an address is serviceable by a cloud kitchen
  Future<void> checkServiceability(Address address) async {
    // Skip check if latitude or longitude are missing
    if (address.latitude == null || address.longitude == null) {
      emit(const CloudKitchenError('Address coordinates are missing'));
      return;
    }

    emit(CloudKitchenLoading());

    try {
      final response = await _apiClient.get(
        '/api/cloud-kitchens/is-servicable',
        queryParameters: {'latitude': '0.03', 'longitude': 0.03},
      );
      //   'latitude': address.latitude.toString(),
      // 'longitude': address.longitude.toString(),
      _logger.d(
        'Serviceability check response: $response',
        tag: 'CloudKitchenCubit',
      );

      if (response['status'] == 'success' && response.containsKey('data')) {
        final data = response['data'];
        bool isServiceable = data['isServicable'] as bool;
        isServiceable = true;

        String? cloudKitchenId;
        String? distance;

        if (data.containsKey('cloudKitchen') && data['cloudKitchen'] is Map) {
          cloudKitchenId = data['cloudKitchen']['id'] as String?;
        }

        if (data.containsKey('distance')) {
          distance = data['distance'] as String?;
        }

        emit(
          CloudKitchenLoaded(
            isServiceable: isServiceable,
            cloudKitchenId: cloudKitchenId,
            distance: distance,
          ),
        );
      } else {
        emit(const CloudKitchenError('Invalid response format'));
      }
    } catch (e) {
      _logger.e(
        'Failed to check serviceability',
        error: e,
        tag: 'CloudKitchenCubit',
      );
      emit(
        CloudKitchenError(
          'Failed to check if we deliver to this address: ${e.toString()}',
        ),
      );
    }
  }

  /// Reset the state
  void reset() {
    emit(CloudKitchenInitial());
  }
}
