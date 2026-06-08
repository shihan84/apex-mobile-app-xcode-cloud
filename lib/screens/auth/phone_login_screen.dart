import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_scaffold.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_functions.dart';
import 'sign_in/sign_in_controller.dart';

class PhoneLoginScreen extends StatelessWidget {
  PhoneLoginScreen({super.key});
  final SignInController c = Get.find<SignInController>();

  @override
  Widget build(BuildContext context) {
    return NewAppScaffold(
      hideAppBar: true,
      scaffoldBackgroundColor: appScreenBackgroundDark,
      isLoading: c.isLoading,
      body: Column(children: [
        100.height,
        Text('Phone Login', style: boldTextStyle(size: 20)),
        40.height,
        AppTextField(
          controller: c.phoneCont,
          textFieldType: TextFieldType.PHONE,
          decoration: inputDecoration(context, hintText: 'Mobile Number'),
          onChanged: (_) => c.getBtnEnable(),
        ),
        30.height,
        Obx(() => AppButton(
          text: 'Send OTP',
          color: appColorPrimary,
          onTap: c.isBtnEnable.value ? () => c.onLoginPressed() : null,
        )),
        20.height,
        TextButton(onPressed: () => Get.back(), child: Text('Back')),
      ]).paddingAll(16),
    );
  }
}
