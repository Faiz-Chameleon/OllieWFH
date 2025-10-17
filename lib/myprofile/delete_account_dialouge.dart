import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/request_status.dart';

void showDeleteAccountDialog(BuildContext context) {
  final UserController userController = Get.put(UserController());
  final TextEditingController controller = TextEditingController();
  bool isDeleteTyped = false;

  showDialog(
    context: context,
    barrierDismissible: false, // user must interact with dialog
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Confirm Delete Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Type "delete" to confirm account deletion.'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  onChanged: (value) {
                    setState(() {
                      isDeleteTyped = value.trim().toLowerCase() == 'delete';
                    });
                  },
                  decoration: const InputDecoration(hintText: 'Type delete here', border: OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: isDeleteTyped && userController.deleteAccountStatus.value != RequestStatus.loading
                    ? () async {
                        await userController.deleteAccount();
                      }
                    : null,
                child: Obx(() {
                  if (userController.deleteAccountStatus.value == RequestStatus.loading) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    );
                  } else {
                    return const Text('Delete');
                  }
                }),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> deleteAccount() async {
  final storage = FlutterSecureStorage();
  final requiredToken = await storage.read(key: 'userToken');

  if (requiredToken == null || requiredToken.isEmpty) {
    print('No token found, cannot delete account');
    return; // exit early if token is missing
  }

  try {
    var headers = {'x-access-token': requiredToken};

    var request = http.Request('DELETE', Uri.parse('https://api.theollie.app/api/v1/user/auth/userDeleteAcccount'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      print('Deleted successfully: $respStr');
    } else {
      print('Failed: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
