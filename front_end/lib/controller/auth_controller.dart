import 'package:get/get.dart';
import 'package:front_end/route/const.dart';
import 'package:front_end/route/route.dart';

class AuthController extends GetConnect {
  // Example login API logic using GetConnect
  // Example logout logic
  static Future<void> logout() async {
    // TODO: Implement real logout logic (e.g., clear token, call API, etc)
    // await GetConnect().post('https://yourapi.com/logout', {});
    // Remove token from storage, etc.
    // For now, just dummy
    return;
  }

  static Future<bool> login(String username, String password) async {
    // final response = await GetConnect().post(
    //   'https://yourapi.com/login',
    //   {'username': username, 'password': password},
    // );
    // if (response.statusCode == 200) {
    //   // Handle success, save token, etc.
    //   return true;
    // } else {
    //   // Show error
    //   return false;
    // }
    return true; // Dummy always success for now
  }

  // Example register API logic using GetConnect
  /*
  nanti logika registernya adalah
  1. pertamanya hit ke firebase abis dari firebase dapet token jwt, gender, usia
  2. fe dapet 3 hal itu terus baru hit ke backend golang
  3. kalo udah berhasil hit be golang nanti baru fe hit ulang ke firebase buat verifikasi email
  kenapa kok gk di backend aja? biar komputasinya gk berat cenah
  */
  static Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    // final response = await GetConnect().post(
    //   'https://yourapi.com/register',
    //   {
    //     'username': username,
    //     'email': email,
    //     'password': password,
    //     'first_name': firstName,
    //     'last_name': lastName,
    //   },
    // );
    // if (response.statusCode == 200) {
    //   // Handle success
    //   return true;
    // } else {
    //   // Show error
    //   return false;
    // }
    return true; // Dummy always success for now
  }
}
