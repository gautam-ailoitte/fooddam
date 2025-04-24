// lib/src/presentation/cubits/banner/banner_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/banner_entity.dart';
import 'package:foodam/src/domain/usecase/banner_usecase.dart';
import 'package:foodam/src/presentation/cubits/banner/banner_state.dart';

class BannerCubit extends Cubit<BannerState> {
  final BannerUseCase _bannerUseCase;
  final LoggerService _logger = LoggerService();

  BannerCubit({required BannerUseCase bannerUseCase})
    : _bannerUseCase = bannerUseCase,
      super(BannerInitial());

  /// Load banners, optionally filtered by category
  Future<void> loadBanners({String? category}) async {
    _logger.d('Loading banners', tag: 'BannerCubit');

    emit(BannerLoading());

    final result = await _bannerUseCase.getBanners(category: category);

    result.fold(
      (failure) {
        _logger.e('Failed to get banners: ${failure.message}', error: failure);
        emit(BannerError('Failed to load banners'));
      },
      (banners) {
        _logger.i('Banners loaded: ${banners.length} banners');

        // Sort banners by index
        final sortedBanners = _bannerUseCase.sortByIndex(banners);

        // Group banners by category
        final Map<String, List<Banner>> bannersByCategory = {};
        // print(banners.toString());

        for (final banner in sortedBanners) {
          final category = banner.category.toLowerCase();
          if (!bannersByCategory.containsKey(category)) {
            bannersByCategory[category] = [];
          }
          bannersByCategory[category]!.add(banner);
        }

        // Sort each category by index
        bannersByCategory.forEach((key, value) {
          bannersByCategory[key] = _bannerUseCase.sortByIndex(value);
        });

        emit(
          BannerLoaded(
            banners: sortedBanners,
            bannersByCategory: bannersByCategory,
          ),
        );
      },
    );
  }
}
