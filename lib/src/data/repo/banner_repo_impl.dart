// lib/src/data/repo/banner_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/banner_entity.dart';
import 'package:foodam/src/domain/repo/banner_repo.dart';

class BannerRepositoryImpl implements BannerRepository {
  final RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final LoggerService _logger = LoggerService();

  BannerRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Banner>>> getBanners({String? category}) async {
    if (await networkInfo.isConnected) {
      try {
        final banners = await remoteDataSource.getBanners(category: category);
        _logger.i('Got ${banners.length} banners from API');
        return Right(banners.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        _logger.e('Server exception while getting banners', error: e);
        return Left(ServerFailure(e.message));
      } catch (e) {
        _logger.e('Unexpected error while getting banners', error: e);
        return Left(UnexpectedFailure());
      }
    } else {
      _logger.w('Network not available for banner fetch');
      return Left(NetworkFailure());
    }
  }
}
