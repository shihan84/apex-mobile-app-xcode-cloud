// ignore_for_file: constant_identifier_names

import 'package:country_picker/country_picker.dart';
import 'package:apexprime_tv/generated/assets.dart';

const APP_NAME = 'ApexPrimeTV';
const APP_MINI_LOGO_URL = Assets.assetsAppMiniLogo;
const APP_LOGO_URL = Assets.assetsAppLoader;
const APP_FONT_FAMILY = 'Roboto';
const DEFAULT_LANGUAGE = 'en';
const AUTO_SLIDER_SECOND = 6000;
const CUSTOM_AD_AUTO_SLIDER_SECOND_VIDEO = 30000;
const CUSTOM_AD_AUTO_SLIDER_SECOND_IMAGE = 30000;
const LIVE_AUTO_SLIDER_SECOND = 5;

const API_VERSION = 3;

///DO NOT ADD SLASH HERE
const DOMAIN_URL = 'https://apexprimetv.com';

const BASE_URL = '$DOMAIN_URL/api/';

const APP_APPSTORE_URL = '';
const APP_PLAY_STORE_URL = 'https://play.google.com/store/apps/details?id=com.apexprime.ott';

///LOCAL VIDEO TYPE URL
const LOCAL_VIDEO_DOMAIN_URL = '$DOMAIN_URL/storage/ApexPrimeTv-laravel/';

//Note: For FIREBASE_SERVER_CLIENT_ID ---> Go to android/app/google-services.json
// - Find press ctrl+F and look for "client_type": 3
// "client_id" in same object has be pasted here

const FIREBASE_SERVER_CLIENT_ID = '903667670865-amn509gdkug9nf13uvu9j9on1lqeka8n.apps.googleusercontent.com';

//region STRIPE
const STRIPE_URL = 'https://api.stripe.com/v1/payment_intents';
const STRIPE_merchantIdentifier = "merchant.flutter.stripe.test";
const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';
const STRIPE_CURRENCY_CODE = 'INR';
//endregion

//region RazorPay
const String commonSupportedCurrency = 'INR';
//endregion

//region  PAYSTACK
const String payStackCurrency = "NGN";
//endregion

// PAYPAl
const String payPalSupportedCurrency = 'USD';
//endregion

//ADs
// Android
const INTERSTITIAL_AD_ID = "ca-app-pub-3940256099942544/1033173712";
const BANNER_AD_ID = "ca-app-pub-3940256099942544/9214589741";
// IOS
const IOS_INTERSTITIAL_AD_ID = "ca-app-pub-3940256099942544/4411468910";
const IOS_BANNER_AD_ID = "ca-app-pub-3940256099942544/2934735716";

//region defaultCountry
Country get defaultCountry => Country(
      phoneCode: '91',
      countryCode: 'IN',
      e164Sc: 91,
      geographic: true,
      level: 1,
      name: 'India',
      example: '23456789',
      displayName: 'India (IN) [+91]',
      displayNameNoCountryCode: 'India (IN)',
      e164Key: '91-IN-0',
      fullExampleWithPlusSign: '+919123456789',
    );
//endregion