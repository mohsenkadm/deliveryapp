import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginAdmin {
  final AuthRepository repository;
  LoginAdmin(this.repository);

  Future<Either<Failure, User>> call({required String username, required String password}) {
    return repository.loginAdmin(username: username, password: password);
  }
}
