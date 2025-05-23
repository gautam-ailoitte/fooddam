// lib/src/data/repo/calendar_repo_impl.dart (NEW)
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/repo/calendar_repo.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final RemoteDataSource remoteDataSource;
  final LoggerService _logger = LoggerService();

  CalendarRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CalculatedPlan>> getCalculatedPlan({
    required String dietaryPreference,
    required int week,
    required DateTime startDate,
  }) async {
    try {
      final planModel = await remoteDataSource.getCalculatedPlan(
        dietaryPreference: dietaryPreference,
        week: week,
        startDate: startDate,
      );

      return Right(planModel.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
