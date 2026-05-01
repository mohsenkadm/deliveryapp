import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginRepresentative {
  final AuthRepository repository;
  LoginRepresentative(this.repository);

  Future<Either<Failure, User>> call({required String username, required String password}) {
    return repository.loginRepresentative(username: username, password: password);
  }
}
