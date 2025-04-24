// lib/src/presentation/cubits/banner/banner_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/banner_entity.dart';

abstract class BannerState extends Equatable {
  const BannerState();

  @override
  List<Object?> get props => [];
}

class BannerInitial extends BannerState {}

class BannerLoading extends BannerState {}

class BannerLoaded extends BannerState {
  final List<Banner> banners;
  final Map<String, List<Banner>> bannersByCategory;

  const BannerLoaded({required this.banners, required this.bannersByCategory});

  @override
  List<Object?> get props => [banners, bannersByCategory];

  bool get hasBanners => banners.isNotEmpty;

  List<Banner> getBannersForCategory(String category) {
    return bannersByCategory[category] ?? [];
  }

  bool hasCategory(String category) {
    return bannersByCategory.containsKey(category) &&
        bannersByCategory[category]!.isNotEmpty;
  }
}

class BannerError extends BannerState {
  final String message;

  const BannerError(this.message);

  @override
  List<Object?> get props => [message];
}
