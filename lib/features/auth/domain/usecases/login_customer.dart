import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginCustomer {
  final AuthRepository repository;
  LoginCustomer(this.repository);

  Future<Either<Failure, User>> call({required String username, required String password}) {
    return repository.loginCustomer(username: username, password: password);
  }
}
