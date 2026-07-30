import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_services.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _api = ApiServices.instance;
  final _storage = StorageServices.instance;

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final response = await _api.postServices(
        url: AppApiUrl.instance.singIn,
        body: {"email": email, "password": password},
      );

      if (response == null || response["success"] != true) {
        return Left(ServerFailure(response?["message"] ?? "Login failed"));
      }

      final data = response["data"];
      final token = data["token"] as String;
      final userJson = data["user"];

      await _storage.setToken(token);
      await _storage.setLogDedData(userJson);

      final user = User(
        id: userJson["_id"] ?? "",
        email: userJson["email"] ?? "",
        name: userJson["name"] ?? "",
      );

      return Right(user);
    } catch (e) {
      return Left(ServerFailure("Something went wrong. Please try again."));
    }
  }
}