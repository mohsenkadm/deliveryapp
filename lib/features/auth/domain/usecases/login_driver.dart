import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginDriver {
  final AuthRepository repository;
  LoginDriver(this.repository);

  Future<Either<Failure, User>> call({required String username, required String password}) {
    return repository.loginDriver(username: username, password: password);
  }
}
