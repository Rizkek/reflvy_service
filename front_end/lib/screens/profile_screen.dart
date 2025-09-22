import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final user = authController.currentUser.value;
        
        if (user == null) {
          return const Center(
            child: Text('User not found'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user.profileImage != null 
                    ? NetworkImage(user.profileImage!) 
                    : null,
                child: user.profileImage == null 
                    ? Text(
                        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user.fullName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                user.email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final success = await authController.logout();
                  if (success) {
                    Get.offAllNamed('/login');
                  }
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      }),
    );
  }
}