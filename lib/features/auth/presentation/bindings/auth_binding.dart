import 'package:get/get.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../controllers/auth_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthRepositoryImpl());
    Get.lazyPut<AuthRepository>(() => Get.find<AuthRepositoryImpl>());
    Get.lazyPut(() => LoginUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => AuthController(loginUseCase: Get.find<LoginUseCase>()));
  }
}
