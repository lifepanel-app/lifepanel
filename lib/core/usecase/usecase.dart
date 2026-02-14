import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

/// Base use case contract.
///
/// Every use case has a single [call] method.
/// [Type] is the return type, [Params] is the input parameter type.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use when a use case takes no parameters.
class NoParams {
  const NoParams();
}
