import 'package:get/get.dart';

Future<void> showSnackBar() async{
  Get.showSnackbar(
    const GetSnackBar(
      message: 'Something went wrong',
    ),
  );
  await Future.delayed(const Duration(seconds: 1));
  Get.back();
}