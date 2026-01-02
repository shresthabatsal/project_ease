import 'package:dartz/dartz.dart';
import 'package:project_ease/core/error/failures.dart';

abstract interface class UsecaseWithParams<SuccessType, ParamsType> {
  Future<Either<Failure, SuccessType>> call(ParamsType params);
}

abstract interface class UsecaseWithoutParams<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}