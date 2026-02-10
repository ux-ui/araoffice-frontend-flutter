import 'package:api/api.dart';
import 'package:get/get.dart';

class WindowController extends GetxController {
  final loginApiClient = Get.find<LoginApiClient>();

  final result = ''.obs;

  void login() {
    loginApiClient
        .login(userId: 'admin', password: '1234', rememberMe: false)
        .then(
            (value) => result.value = 'login api  result: ${value.toString()}');
  }

  void logout() {
    loginApiClient.logout().then(
        (value) => result.value = 'logout api  result: ${value.toString()}');
  }

  void checkSession() {
    loginApiClient.checkSession().then((value) =>
        result.value = 'checkSession api  result: ${value.toString()}');
  }
}
