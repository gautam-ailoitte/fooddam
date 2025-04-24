// lib/src/domain/usecase/banner_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/banner_entity.dart';
import 'package:foodam/src/domain/repo/banner_repo.dart';

class BannerUseCase {
  final BannerRepository repository;

  BannerUseCase(this.repository);

  Future<Either<Failure, List<Banner>>> getBanners({String? category}) {
    return repository.getBanners(category: category);
  }

  // Helper method to filter banners by category
  List<Banner> filterByCategory(List<Banner> banners, String category) {
    return banners
        .where(
          (banner) => banner.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  // Helper method to sort banners by index
  List<Banner> sortByIndex(List<Banner> banners) {
    final sorted = List<Banner>.from(banners);
    sorted.sort((a, b) => a.index.compareTo(b.index));
    return sorted;
  }
}
