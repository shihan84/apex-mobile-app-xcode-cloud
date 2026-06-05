import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';

class FirebaseAuthHandleExceptionsUtils {
  String handleException(FirebaseAuthException firebaseAuthException) {
    String message = '';
    switch (firebaseAuthException.code) {
      case 'network-request-failed':
        message = locale.value.pleaseCheckYourMobileInternetConnection;
        break;
      case 'invalid-verification-code':
        message = locale.value.pleaseEnterAValidCode;
        break;
      case 'too-many-requests':
        message = locale.value.pleaseTryAgainAfterSomeTime;
        break;
      case 'invalid-phone-number':
        message = locale.value.pleaseEnterAValidMobileNo;
        break;
      case 'app-not-authorized':
        message = 'Firebase Auth Error: app-not-authorized — SHA-1 certificate not registered in Firebase Console for this app.';
        break;
      case 'quota-exceeded':
        message = 'Firebase Auth Error: SMS quota exceeded for this project. Please try again later.';
        break;
      case 'captcha-check-failed':
        message = 'Firebase Auth Error: reCAPTCHA verification failed. Please try again.';
        break;
      case 'missing-phone-number':
        message = locale.value.pleaseEnterAValidMobileNo;
        break;
      case 'user-disabled':
        message = 'This account has been disabled. Please contact support.';
        break;
      case 'operation-not-allowed':
        message = 'Firebase Auth Error: Phone authentication is not enabled in Firebase Console.';
        break;
      case 'session-expired':
        message = 'OTP has expired. Please request a new code.';
        break;
      default:
        message = 'Auth error [${firebaseAuthException.code}]: ${firebaseAuthException.message ?? "Unknown error"}';
    }
    return message;
  }
}