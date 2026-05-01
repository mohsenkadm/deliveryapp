import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class RegisterCustomer {
  final AuthRepository repository;
  RegisterCustomer(this.repository);

  Future<Either<Failure, void>> call({
    required String fullName,
    required String username,
    required String password,
    required String phone,
    required String address,
    String? representativeId,
  }) {
    return repository.registerCustomer(
      fullName: fullName,
      username: username,
      password: password,
      phone: phone,
      address: address,
      representativeId: representativeId,
    );
  }
}
