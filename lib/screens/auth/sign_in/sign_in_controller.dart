// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_dialog_widget.dart';
import 'package:streamit_laravel/controllers/base_controller.dart';
import 'package:streamit_laravel/network/auth_apis.dart';
import 'package:streamit_laravel/screens/profile/watching_profile/watching_profile_screen.dart';
import 'package:streamit_laravel/services/local_storage_service.dart';
import 'package:streamit_laravel/services/notification_service.dart';
import 'package:streamit_laravel/utils/api_end_points.dart';

import '../../../configs.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../../utils/common_functions.dart';
import '../../../utils/constants.dart';
import '../components/device_list_component.dart';
import '../model/error_model.dart';
import '../services/social_logins.dart';
import '../sign_up/signup_screen.dart';

class SignInController extends BaseController {
  final GlobalKey<FormState> signInformKey = GlobalKey();

  RxBool isBtnEnable = false.obs;
  RxBool isRememberMe = true.obs;
  RxBool isNormalLogin = true.obs;

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  Worker? _appConfigWorker;

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  @override
  void onInit() {
    _appConfigWorker = ever(appConfigs, (_) async {
      await _applyDemoCredentialState();
    });
    init();
    super.onInit();
  }

  Future<void> init() async {
    getBtnEnable();
    getInitialData();
    await _applyDemoCredentialState();
  }

  Future<void> getInitialData() async {
    final isRememberMeValue = await getBoolFromLocal(SharedPreferenceConst.IS_REMEMBER_ME);
    if (isRememberMeValue == true) {
      isRememberMe(true);
      final savedPassword = await getStringFromLocal(SharedPreferenceConst.USER_PASSWORD);
      final savedLoginRequest = await getJsonFromLocal(SharedPreferenceConst.LOGIN_REQUEST);
      if (savedPassword != null && savedPassword.isNotEmpty) {
        passwordCont.text = savedPassword;
      }
      if (savedLoginRequest != null && savedLoginRequest[ApiRequestKeys.email] != null) {
        emailCont.text = savedLoginRequest[ApiRequestKeys.email];
      }
    } else {
      isRememberMe(false);
    }
    getBtnEnable();
  }

  void getBtnEnable() {
    isBtnEnable(emailCont.text.isNotEmpty && passwordCont.text.isNotEmpty);
  }

  Future<void> _applyDemoCredentialState() async {
    final bool shouldShowDemoCredentials = appConfigs.value.enableDemoLogin && await isIqonicProduct;

    if (shouldShowDemoCredentials) {
      emailCont.text = Constants.DEFAULT_EMAIL;
      passwordCont.text = Constants.DEFAULT_PASS;
    } else {
      if (emailCont.text == Constants.DEFAULT_EMAIL) emailCont.clear();
      if (passwordCont.text == Constants.DEFAULT_PASS) passwordCont.clear();
    }
    getBtnEnable();
  }

  Future<void> loginAPICall({required Map<String, dynamic> request, required bool isSocialLogin, bool isNormalLogin = false}) async {
    await AuthServiceApis.loginUser(request: request, isSocialLogin: isSocialLogin)
        .then((value) async {
          handleLoginResponse(isSocialLogin: isSocialLogin, isNormalLogin: isNormalLogin);
        })
        .whenComplete(
          () => setLoading(false),
        )
        .catchError((e) async {
          if (e is Map<String, dynamic> && e.containsKey('status_code') && e['status_code'] == 404) {
            var res = await Get.to(() => SignUpScreen());
            if (res == true) {
              Get.off(() => WatchingProfileScreen(), arguments: Get.arguments);
            }
          } else {
            errorSnackBar(error: e);

            if (e is Map<String, dynamic> && e.containsKey('status_code') && e['status_code'] == 406 && e.containsKey('response')) {
              final ErrorModel errorData = ErrorModel.fromJson(e['response']);
              Get.bottomSheet(
                isScrollControlled: true,
                enableDrag: false,
                AppDialogWidget(
                  child: DeviceListComponent(
                    loggedInDeviceList: errorData.otherDevice,
                    onLogout: (logoutAll, deviceId, deviceName) {
                      Navigator.pop(Get.context!);
                      if (logoutAll) {
                        logOutAll(errorData.otherDevice.first.userId).then(
                          (value) {
                            loginAPICall(request: request, isSocialLogin: isSocialLogin);
                          },
                        );
                      } else {
                        deviceLogOut(
                          device: deviceId,
                          userId: errorData.otherDevice.first.userId.toInt(),
                        ).then(
                          (value) {
                            loginAPICall(request: request, isSocialLogin: isSocialLogin);
                          },
                        );
                      }
                    },
                  ),
                ),
              );
            }
          }
        });
  }

  Future<void> saveForm({bool isNormalLogin = false}) async {
    if (isLoading.isTrue) return;

    hideKeyBoardWithoutContext();
    setLoading(true);
    final Map<String, dynamic> req = {
      ApiRequestKeys.email: emailCont.text.trim(),
      ApiRequestKeys.password: passwordCont.text.trim(),
      ApiRequestKeys.deviceIdKey: currentDevice.value.deviceId,
      ApiRequestKeys.deviceNameKey: currentDevice.value.deviceName,
      ApiRequestKeys.platformKey: currentDevice.value.platform,
    };

    await loginAPICall(isSocialLogin: false, request: req, isNormalLogin: isNormalLogin);
  }

  Future<void> googleSignIn() async {
    if (isLoading.value) return;
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.first == ConnectivityResult.none) {
      toast(locale.value.yourInternetIsNotWorking, print: true);
      return;
    }

    setLoading(true);
    await GoogleSignInAuthService().signInWithGoogle().then((value) async {
      if (value != null) {
        final Map<String, dynamic> request = {
          ApiRequestKeys.email: value.email,
          ApiRequestKeys.password: value.email,
          ApiRequestKeys.firstName: value.firstName,
          ApiRequestKeys.lastName: value.lastName,
          ApiRequestKeys.mobile: value.mobile,
          ApiRequestKeys.fileUrl: value.profileImage,
          ApiRequestKeys.deviceIdKey: currentDevice.value.deviceId,
          ApiRequestKeys.deviceNameKey: currentDevice.value.deviceName,
          ApiRequestKeys.platformKey: currentDevice.value.platform,
          ApiRequestKeys.loginType: LoginTypeConst.loginTypeGoogle,
        };
        log('signInWithGoogle REQUEST: $request');

        await loginAPICall(request: request, isSocialLogin: true);
      }
    }).catchError((e) {
      setLoading(false);
      String errorMessage = '';
      if (e is GoogleSignInException) {
        errorMessage = '${e.code.name}: ${e.description ?? 'Google sign in failed'}';
      } else {
        errorMessage = e.toString();
      }
      if (errorMessage.isNotEmpty) errorSnackBar(error: errorMessage);
    }).whenComplete(() => setLoading(false));
  }

  Future<void> appleSignIn() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.first == ConnectivityResult.none) {
      toast(locale.value.yourInternetIsNotWorking, print: true);
      return;
    }
    setLoading(true);
    await GoogleSignInAuthService().signInWithApple().then((value) async {
      final Map<String, dynamic> request = {
        ApiRequestKeys.email: value.email,
        ApiRequestKeys.password: value.email,
        ApiRequestKeys.firstName: value.firstName,
        ApiRequestKeys.lastName: value.lastName,
        ApiRequestKeys.mobile: value.mobile,
        ApiRequestKeys.fileUrl: value.profileImage,
        ApiRequestKeys.deviceIdKey: currentDevice.value.deviceId,
        ApiRequestKeys.deviceNameKey: currentDevice.value.deviceName,
        ApiRequestKeys.platformKey: currentDevice.value.platform,
        ApiRequestKeys.loginType: LoginTypeConst.loginTypeApple,
      };
      log('signInWithGoogle REQUEST: $request');

      /// Social Login Api
      await loginAPICall(request: request, isSocialLogin: true);
    }).catchError((e) {
      setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void handleLoginResponse({String? password, bool isSocialLogin = false, bool isNormalLogin = false}) {
    try {
      setBoolToLocal(SharedPreferenceConst.IS_REMEMBER_ME, isRememberMe.value);

      if (isRememberMe.value && isNormalLogin) {
        setStringToLocal(SharedPreferenceConst.USER_PASSWORD, passwordCont.text);
        final loginRequest = {
          ApiRequestKeys.email: emailCont.text.trim(),
          ApiRequestKeys.password: passwordCont.text.trim(),
        };
        setJsonToLocal(SharedPreferenceConst.LOGIN_REQUEST, loginRequest);
      } else if (!isRememberMe.value) {
        removeValue(SharedPreferenceConst.USER_PASSWORD);
        removeValue(SharedPreferenceConst.LOGIN_REQUEST);
      }

      Get.off(() => WatchingProfileScreen(), arguments: Get.arguments);
      NotificationService().subscribeTopic();

      setLoading(false);
    } catch (e) {
      log("Error  ==> $e");
    }
  }

  Future<void> deviceLogOut({required String device, required int userId}) async {
    setLoading(true);
    await AuthServiceApis.deviceLogoutApiWithoutAuth(deviceId: device, userId: userId).then((value) {
      successSnackBar(value.message);
      // Close bottom sheet after success
      if (Get.isBottomSheetOpen ?? false) Get.back();
    }).catchError((e) {
      errorSnackBar(error: e);
      // Close bottom sheet after error
      if (Get.isBottomSheetOpen ?? false) Get.back();
    }).whenComplete(() {
      setLoading(false);
    });
  }

  Future<void> logOutAll(int userId) async {
    if (isLoading.value) return;
    setLoading(true);
    await AuthServiceApis.logOutAllAPIWithoutAuth(userId: userId).then((value) async {
      successSnackBar(value.message);
    }).catchError((e) {
      errorSnackBar(error: e);
    }).whenComplete(() {
      setLoading(false);
    });
  }

  @override
  void onClose() {
    _appConfigWorker?.dispose();
    emailCont.dispose();
    passwordCont.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}