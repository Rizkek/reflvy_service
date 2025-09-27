import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ProfileApiService {
  
  // Get user profile data from API
  static Future<Map<String, dynamic>> getProfile(String jwtToken) async {
    try {
      final response = await http.get(
        Uri.parse(ApiUrls.profileDetails),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return {
          'success': true,
          'data': responseData,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token tidak valid atau sudah expired',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Profile tidak ditemukan',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error koneksi: ${e.toString()}',
      };
    }
  }

  // Update user profile data to API (if needed in the future)
  static Future<Map<String, dynamic>> updateProfile(
    String jwtToken, 
    Map<String, dynamic> profileData
  ) async {
    try {
      final response = await http.put(
        Uri.parse(ApiUrls.profileDetails),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return {
          'success': true,
          'data': responseData,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token tidak valid atau sudah expired',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal update profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error koneksi: ${e.toString()}',
      };
    }
  }
}