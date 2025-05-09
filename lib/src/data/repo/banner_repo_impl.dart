// lib/src/data/repo/banner_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/banner_entity.dart';
import 'package:foodam/src/domain/repo/banner_repo.dart';

class BannerRepositoryImpl implements BannerRepository {
  final RemoteDataSource remoteDataSource;

  BannerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Banner>>> getBanners({String? category}) async {
    try {
      final banners = await remoteDataSource.getBanners(category: category);
      return Right(banners.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
