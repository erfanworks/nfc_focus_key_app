import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      // TODO: Replace with actual backend API call
      await Future.delayed(const Duration(seconds: 2)); // Fake delay

      if (email.isNotEmpty && password.length >= 6) {
        return Right(
          UserModel(id: '1', email: email, name: email.split('@')[0]),
        );
      } else {
        return const Left(
          ServerFailure('Password must be at least 6 characters'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
