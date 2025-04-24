// lib/src/domain/repo/banner_repo.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/banner_entity.dart';

abstract class BannerRepository {
  Future<Either<Failure, List<Banner>>> getBanners({String? category});
}
