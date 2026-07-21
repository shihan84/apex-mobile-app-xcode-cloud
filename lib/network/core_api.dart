import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:apexprime_tv/configs.dart';
import 'package:apexprime_tv/network/network_utils.dart';
import 'package:apexprime_tv/screens/account_setting/model/account_setting_response.dart';
import 'package:apexprime_tv/screens/auth/model/app_configuration_res.dart';
import 'package:apexprime_tv/screens/coming_soon/model/coming_soon_response.dart';
import 'package:apexprime_tv/screens/content/model/content_model.dart';
import 'package:apexprime_tv/screens/genres/model/genres_model.dart';
import 'package:apexprime_tv/screens/home/model/dashboard_res_model.dart';
import 'package:apexprime_tv/screens/home/model/notification_count_response_model.dart';
import 'package:apexprime_tv/screens/live_tv/live_tv_details/model/live_tv_details_response.dart';
import 'package:apexprime_tv/screens/live_tv/model/live_tv_dashboard_response.dart';
import 'package:apexprime_tv/screens/payment/model/pay_per_view_model.dart';
import 'package:apexprime_tv/screens/payment/model/subscription_model.dart';
import 'package:apexprime_tv/screens/profile/model/profile_detail_resp.dart';
import 'package:apexprime_tv/screens/profile/watching_profile/model/profile_watching_model.dart';
import 'package:apexprime_tv/screens/rented_content/model/rent_content_model.dart';
import 'package:apexprime_tv/screens/review/model/review_model.dart';
import 'package:apexprime_tv/screens/search/model/search_response.dart';
import 'package:apexprime_tv/screens/setting/model/faq_model.dart';
import 'package:apexprime_tv/screens/subscription/model/invoice_model.dart';
import 'package:apexprime_tv/screens/subscription/model/rental_history_model.dart';
import 'package:apexprime_tv/screens/subscription/model/subscription_model.dart';
import 'package:apexprime_tv/screens/walk_through/model/walkthrough_model.dart';
import 'package:apexprime_tv/screens/watch_list/model/watch_list_resp.dart';
import 'package:apexprime_tv/services/local_storage_service.dart';
import 'package:apexprime_tv/utils/common_functions.dart';
import 'package:apexprime_tv/utils/constants.dart';

import '../main.dart';
import '../models/base_response_model.dart';
import '../screens/auth/model/about_page_res.dart';
import '../screens/coupon/model/coupon_list_model.dart';
import '../screens/subscription/model/subscription_plan_model.dart';
import '../utils/api_end_points.dart';
import '../utils/common_base.dart';

class CoreServiceApis {
  static Future<void> getAppConfigurations({
    bool forceSync = false,
    VoidCallback? onError,
    Function(bool)? loaderOnOff,
  }) async {
    await checkApiCallIsWithinTimeSpan(
        sharePreferencesKey: SharedPreferenceConst.LAST_APP_CONFIGURATION_CALL_TIME,
        forceSync: forceSync,
        callback: () async {
          loaderOnOff?.call(true);
          List<String> params = [];
          if (await getBoolFromLocal(SharedPreferenceConst.IS_LOGGED_IN) && loginUserData.value.id > -1) {
            params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
            params.add('${ApiRequestKeys.deviceIdKey}=${currentDevice.value.deviceId}');
          }
          params.add('${ApiRequestKeys.isAuthenticatedKey}=${isLoggedIn.isTrue.getIntBool()}');

          await getApiResponse(
            getEndPoint(
              endPoint: APIEndPoints.appConfiguration,
              params: params,
            ),
            manageApiVersion: API_VERSION > 2,
          ).then(
            (value) async {
              ConfigurationResponse configurationResponse = ConfigurationResponse.fromJson(value);

              appCurrency(configurationResponse.currency);
              appConfigs(configurationResponse);
              if (currentSubscription.value.level > -1 &&
                  currentSubscription.value.planType.isNotEmpty &&
                  currentSubscription.value.planType.any((element) => element.slug == SubscriptionTitle.videoCast)) {
                isCastingSupported(currentSubscription.value.planType.firstWhere((element) => element.slug == SubscriptionTitle.videoCast).limitationValue.getBoolInt());
              } else {
                isCastingSupported(false);
              }
              isSupportedDevice(configurationResponse.isDeviceSupported);
              isCastingAvailable(configurationResponse.isCastingAvailable);
              setBoolToLocal(SharedPreferenceConst.IS_SUPPORTED_DEVICE, configurationResponse.isDeviceSupported);

              setIntToLocal(SharedPreferenceConst.LAST_APP_CONFIGURATION_CALL_TIME, DateTime.timestamp().millisecondsSinceEpoch);
              await setBoolToLocal(SharedPreferenceConst.IS_APP_CONFIGURATION_SYNCED_ONCE, true);
              setJsonToLocal(SharedPreferenceConst.CACHE_CONFIGURATION_RESPONSE, configurationResponse.toJson());
            },
          ).onError(
            (error, stackTrace) {
              setBoolToLocal(SharedPreferenceConst.IS_APP_CONFIGURATION_SYNCED_ONCE, false);

              // Load cached config if API fails
              getCachedConfig().then((cachedConfig) {
                if (cachedConfig != null) {
                  appCurrency(cachedConfig.currency);
                  appConfigs(cachedConfig);
                  isSupportedDevice(cachedConfig.isDeviceSupported);
                  isCastingAvailable(cachedConfig.isCastingAvailable);
                } else {
                  // Use default config if no cache available
                  final defaultConfig = ConfigurationResponse(
                    applicationURL: ApplicationURL(mobileAppUrl: MobileAppUrl()),
                    currency: Currency(),
                    bannerAds: BannerAds(),
                    enableMovie: true,
                    enableTvShow: true,
                    enableLiveTv: true,
                    enableVideo: true,
                    enableContinueWatch: true,
                    enableRateUs: false,
                    isDeviceSupported: true,
                    isCastingAvailable: false,
                    isDownloadAvailable: false,
                    isGoogleLoginEnabled: true,
                    isAppleSocialLoginEnabled: true,
                    isOtpLoginEnabled: true,
                    isForceUpdate: false,
                    enableDemoLogin: true,
                  );
                  appCurrency(defaultConfig.currency);
                  appConfigs(defaultConfig);
                  isSupportedDevice(defaultConfig.isDeviceSupported);
                  isCastingAvailable(defaultConfig.isCastingAvailable);
                }
              });

              onError?.call();
            },
          ).whenComplete(() => loaderOnOff?.call(false));
        });
  }

  static Future<ConfigurationResponse?> getCachedConfig() async {
    try {
      final cachedJson = await getJsonFromLocal(SharedPreferenceConst.CACHE_CONFIGURATION_RESPONSE);
      if (cachedJson != null) {
        return ConfigurationResponse.fromJson(cachedJson);
      }
    } catch (e) {
      log('Error loading cached config: $e');
    }
    return null;
  }

  static Future<DashboardDetailResponse> getDashboard() async {
    List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
    }

    DashboardDetailResponse dashboardDetailsResp = DashboardDetailResponse.fromJson(
      await getApiResponse(
        getEndPoint(
          endPoint: APIEndPoints.dashboardDetails,
          params: params,
        ),
        manageApiVersion: true,
      ),
    );

    return dashboardDetailsResp;
  }

  static Future<NotificationCountResponse> getNotificationCount() async {
    List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
    }

    NotificationCountResponse notificationCountResponse = NotificationCountResponse.fromJson(
      await getApiResponse(
        getEndPoint(
          endPoint: APIEndPoints.notificationCount,
          params: params,
        ),
      ),
    );

    return notificationCountResponse;
  }

  static Future<DashboardDetailResponse> getDashboardDetailOtherData() async {
    List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
    }

    DashboardDetailResponse dashboardDetailsResp = DashboardDetailResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.dashboardDetailsOtherData, params: params),
        manageApiVersion: true,
      ),
    );

    setJsonToLocal(
      SharedPreferenceConst.CACHE_DASHBOARD_RESPONSE,
      dashboardDetailsResp.data.toJson(),
    );
    return dashboardDetailsResp;
  }

  static Future<LiveChannelDashboardResponse> getLiveDashboard() async {
    List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
    }
    LiveChannelDashboardResponse liveChannelDashboardResp = LiveChannelDashboardResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.liveTvDashboard, params: params),
        manageApiVersion: true,
      ),
    );
    setJsonToLocal(
      SharedPreferenceConst.CACHE_LIVE_TV_DASHBOARD_RESPONSE,
      liveChannelDashboardResp.toJson(),
    );
    cachedLiveTvDashboard = liveChannelDashboardResp;
    return liveChannelDashboardResp;
  }

  // Original Search Details
  static Future<List<PosterDataModel>> searchContent({required String queryParams}) async {
    final SearchResponse searchResponse = await searchContentDetailed(queryParams: queryParams);
    return (searchResponse.movieList + searchResponse.tvShowList + searchResponse.videoList + searchResponse.seasonList + searchResponse.episodeList + searchResponse.channelList);
  }

  static Future<SearchResponse> searchContentDetailed({required String queryParams}) async {
    List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
    }
    if (queryParams.isNotEmpty) params.add(queryParams);
    return SearchResponse.fromJson(
      await getApiResponse(
        getEndPoint(
          endPoint: APIEndPoints.searchContent,
          params: params,
        ),
        manageApiVersion: API_VERSION > 2,
      ),
    );
  }

  // Popular Search List
  static Future<List<String>> getPopularSearchList({
    int page = 1,
    int perPage = 10,
    required List<String> popularSearchList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
    }
    params.add('${ApiRequestKeys.perPageKey}=$perPage');
    params.add('${ApiRequestKeys.pageKey}=$page');

    final response = await getApiResponse(
      getEndPoint(endPoint: APIEndPoints.popularSearchList, params: params),
      manageApiVersion: API_VERSION > 2,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      final List<dynamic> dataList = response['data'];
      if (page == 1) popularSearchList.clear();
      final List<String> newItems = dataList
          .map((item) {
            if (item is String) return item;
            if (item is Map<String, dynamic> && item.containsKey('search_query')) {
              return item['search_query']?.toString() ?? '';
            }
            return item.toString();
          })
          .where((item) => item.isNotEmpty)
          .toList();
      popularSearchList.addAll(newItems);
      lastPageCallBack?.call(newItems.length < perPage);
    }
    return popularSearchList;
  }

  //Profile Details Screen
  static Future<ProfileDetailResponse> getProfileDet() async {
    List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
    }
    ProfileDetailResponse profileDetailResp = ProfileDetailResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.profileDetails, params: params),
        manageApiVersion: true,
      ),
    );
    cachedProfileDetails = profileDetailResp;
    setJsonToLocal(
      SharedPreferenceConst.CACHE_PROFILE_DETAIL,
      profileDetailResp.toJson(),
    );
    return profileDetailResp;
  }

  //Account Setting Screen
  static Future<AccountSettingModel> getAccountSettingsResponse({required String deviceId}) async {
    String id = deviceId.isNotEmpty ? "?${ApiRequestKeys.deviceIdKey}=$deviceId" : "";
    return AccountSettingResponse.fromJson(
      await getApiResponse(
        "${APIEndPoints.accountSetting}$id",
      ),
    ).data;
  }

  //Live Show details
  static Future<ContentModel> getLiveContentDetails({required int contentId}) async {
    List<String> params = [];
    if (contentId > 0) params.add('${ApiRequestKeys.channelKey}=$contentId');

    params.add('${ApiRequestKeys.deviceIdKey}=${currentDevice.value.deviceId}');
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
    }
    LiveShowDetailResponse contentResponse = LiveShowDetailResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.liveTvDetails, params: params),
        method: HttpMethodType.GET,
        manageApiVersion: API_VERSION > 2,
      ),
    );
    return contentResponse.data;
  }

// Add/Edit Rating
  static Future<BaseResponseModel> addRating({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.saveRating,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  static Future<BaseResponseModel> deleteRating({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.deleteRating,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  // Save Download API
  static Future<BaseResponseModel> saveDownload({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.saveDownload,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  static Future<BaseResponseModel> deleteFromDownload({required List<int> idList}) async {
    List<String> params = [];
    params.add('${ApiRequestKeys.idKey}=${idList.join(',')}');
    return BaseResponseModel.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.deleteDownloads, params: params),
        method: HttpMethodType.POST,
      ),
    );
  }

  // Save Continue Watch List API
  static Future<BaseResponseModel> saveContinueWatch({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.saveContinueWatch,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  // Like Movie
  static Future<BaseResponseModel> likeContent({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.saveLikes,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  // Watch List Movie
  static Future<BaseResponseModel> saveWatchList({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.saveWatchlist,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  // Store View Movie
  static Future<BaseResponseModel> storeViewDetails({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.saveEntertainmentViews,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  // Save Reminder
  static Future<BaseResponseModel> saveReminder({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.saveReminder,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  // Save Reminder
  static Future<BaseResponseModel> deleteReminder({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.deleteReminder,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  // Save Subscription Details
  static Future<SubscriptionResponseModel> saveSubscriptionDetails({required Map request}) async {
    return SubscriptionResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.saveSubscriptionDetails,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  // Cancel Subscription Details
  static Future<SubscriptionResponseModel> cancelSubscription({required Map request}) async {
    return SubscriptionResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.cancelSubscription,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  //Get Genres List
  static Future<List<GenreModel>> getGenresList({
    int page = 1,
    required List<GenreModel> genresList,
    Function(bool)? lastPageCallBack,
  }) async {
    int perPage = determinePerPage();
    final genresDetails = GenresResponse.fromJson(
      await getApiResponse(
        "${APIEndPoints.genresDetails}?${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page",
      ),
    );
    if (page == 1) genresList.clear();
    genresList.addAll(genresDetails.data);
    lastPageCallBack?.call(genresDetails.data.length != perPage);
    return genresList.obs;
  }

  //Get Actor List
  static Future<RxList<Cast>> getActorsList({
    String param = "",
    int page = 1,
    required List<Cast> actorList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    if (param.isNotEmpty) params.add(param);
    int perPage = determinePerPage(perPage: 21);
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');
    // TODO: Fix CastListResponse type
    // final actorDetails = CastListResponse.fromJson(
    //   await getApiResponse(
    //     getEndPoint(endPoint: APIEndPoints.actorDetails, params: params),
    //   ),
    // );
    // if (page == 1) actorList.clear();
    // actorList.addAll(actorDetails.data);
    // lastPageCallBack?.call(actorDetails.data.length != perPage);
    cachedPersonList(actorList);
    return actorList.obs;
  }

  static Future<List<PosterDataModel>> getSliderList({required String type}) async {
    List<String> params = [];
    params.add('${ApiRequestKeys.bannerTypeKey}=$type');
    if (loginUserData.value.id > -1) {
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
    }

    final dynamic rawResponse = await getApiResponse(
      getEndPoint(
        endPoint: APIEndPoints.bannerList,
        params: params,
      ),
      manageApiVersion: API_VERSION > 2,
    );

    final SliderResponse response = _parseSliderResponse(_ensureMap(rawResponse));
    cachedSliderList = response.data.slider.obs;
    return response.data.slider;
  }

// Movie List API
  static Future<RxList<PosterDataModel>> getChannelList({
    int page = 1,
    int category = -1,
    required List<PosterDataModel> getChannelList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    int perPage = determinePerPage(perPage: 20);
    final userID = loginUserData.value.id;
    if (userID > -1) params.add('${ApiRequestKeys.userIdKey}=$userID');
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');
    if (category > -1) params.add('${ApiRequestKeys.categoryIdKey}=$category');
    if (loginUserData.value.id > -1) {
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
    }
    ChannelResponse channelResponse = ChannelResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.channelList, params: params),
        manageApiVersion: API_VERSION > 2,
      ),
    );
    if (page == 1) getChannelList.clear();
    getChannelList.addAll(channelResponse.data.channel);
    lastPageCallBack?.call(channelResponse.data.channel.length != perPage);
    return getChannelList.obs;
  }

  // Plan List API
  static Future<List<SubscriptionPlanModel>> getPlanList({
    int page = 1,
    required List<SubscriptionPlanModel> subscriptionPlanList,
    Function(bool)? lastPageCallBack,
  }) async {
    int perPage = determinePerPage();
    final SubscriptionResponse subscriptionResponse = SubscriptionResponse.fromJson(
      await getApiResponse(
        getEndPoint(
          endPoint: APIEndPoints.planLists,
          page: page,
          perPages: perPage,
        ),
      ),
    );
    if (page == 1) subscriptionPlanList.clear();
    subscriptionPlanList.addAll(subscriptionResponse.data);
    lastPageCallBack?.call(subscriptionResponse.data.length != perPage);
    return subscriptionPlanList;
  }

  //Get Coming Soon List
  static Future<RxList<ComingSoonModel>> getComingSoonList({
    int page = 1,
    String type = '',
    required List<ComingSoonModel> getComingSoonList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
    }
    if (type.isNotEmpty) {
      params.add('${ApiRequestKeys.typeKey}=$type');
    }

    int perPage = determinePerPage();
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');
    ComingSoonResponse comingSoonDetails = ComingSoonResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.comingSoon, params: params),
      ),
    );
    if (page == 1) getComingSoonList.clear();
    getComingSoonList.addAll(comingSoonDetails.data);
    lastPageCallBack?.call(comingSoonDetails.data.length != perPage);
    cachedComingSoonList(getComingSoonList);

    return getComingSoonList.obs;
  }

  //Get Continue Watching List

  static Future<RxList<PosterDataModel>> getContinueWatchingList({
    int page = 1,
    required List<PosterDataModel> continueWatchList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    int perPage = determinePerPage();
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
    }
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');

    final dynamic rawResponse = await getApiResponse(
      getEndPoint(endPoint: APIEndPoints.continueWatchList, params: params),
      manageApiVersion: API_VERSION > 2,
    );
    final ThumbnailListResponse listResponse = await compute(_parseContinueWatchResponse, _ensureMap(rawResponse));
    if (page == 1) continueWatchList.clear();
    continueWatchList.addAll(listResponse.data);
    lastPageCallBack?.call(listResponse.data.length != perPage);
    return continueWatchList.obs;
  }

//region Remove from Continue Watching
  static Future<BaseResponseModel> removeContinueWatching({required int continueWatchingId}) async {
    List<String> params = [];
    params.add('id=$continueWatchingId');
    return BaseResponseModel.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.deleteContinueWatch, params: params),
        method: HttpMethodType.POST,
      ),
    );
  }

//Get Watch List
  static Future<RxList<PosterDataModel>> getWatchList({
    int page = 1,
    String type = '',
    required List<PosterDataModel> watchList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    int perPage = determinePerPage();
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
    }
    if (type.isNotEmpty) {
      params.add('${ApiRequestKeys.typeKey}=$type');
    }
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');

    final dynamic rawResponse = await getApiResponse(
      getEndPoint(endPoint: APIEndPoints.watchList, params: params),
      manageApiVersion: true,
    );
    final ListResponse listResponse = await compute(_parseWatchListResponse, _ensureMap(rawResponse));
    if (page == 1) watchList.clear();
    watchList.addAll(listResponse.data);
    lastPageCallBack?.call(listResponse.data.length != perPage);
    return watchList.obs;
  }

  static Future<BaseResponseModel> deleteFromWatchlist({
    List<int> idList = const [],
    Map<String, dynamic>? request,
  }) async {
    List<String> params = [];
    if (idList.isNotEmpty) {
      params.add('${ApiRequestKeys.idKey}=${idList.join(',')}');
      params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      params.add('${ApiRequestKeys.isAjaxKey}=1');
    } else if (request != null) {
      request.forEach(
        (key, value) {
          params.add('$key=$value');
        },
      );
    }

    return BaseResponseModel.fromJson(
      await getApiResponse(
        getEndPoint(
          endPoint: APIEndPoints.deleteWatchList,
          params: params,
        ),
        method: HttpMethodType.POST,
      ),
    );
  }

//Get Episodes List
  static Future<List<PosterDataModel>> getEpisodesList({
    int page = 1,
    int perPage = Constants.episodePerPage,
    required int showId,
    int seasonId = -1,
    required List<PosterDataModel> episodeList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
    }

    if (seasonId > -1) params.add('${ApiRequestKeys.seasonIdKey}=$seasonId');
    if (showId > -1) params.add('${ApiRequestKeys.tvShowIdKey}=$showId');
    ListResponse it = ListResponse.fromEpisodeJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.episodeList, params: params),
        manageApiVersion: API_VERSION > 2,
      ),
    );
    if (page == 1) episodeList.clear();

    lastPageCallBack?.call(it.data.length < perPage);
    episodeList.addAll(it.data);

    return episodeList;
  }

//Get Review List
  static Future<List<ReviewModel>> getReviewList({
    int page = 1,
    int contentId = -1,
    required List<ReviewModel> reviewList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    int perPage = determinePerPage();
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');
    if (contentId > -1) params.add('${ApiRequestKeys.entertainmentIdKey}=$contentId');
    ReviewResponse reviewDetails = ReviewResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.reviewDetails, params: params),
      ),
    );
    if (page == 1) reviewList.clear();
    reviewList.addAll(reviewDetails.data);
    lastPageCallBack?.call(reviewDetails.data.length != perPage);
    return reviewList;
  }

  //Page List Setting Screen
  static Future<List<AboutDataModel>> getPageList() async {
    return AboutPageResponse.fromJson(
      await getApiResponse(APIEndPoints.pageList),
    ).data;
  }

  static Future<BaseResponseModel> saveViewCompleted({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.saveEntertainmentCompletedView,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

//region Watching Profile
// Watching Profile List
  static Future<List<WatchingProfileModel>> getWatchingProfileList({
    int page = 1,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
    }
    int perPage = determinePerPage();
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');
    WatchingProfileResponse profileResponseModel = WatchingProfileResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.watchingProfileList, params: params),
      ),
    );
    if (page == 1) accountProfiles.clear();
    accountProfiles.addAll(profileResponseModel.data);
    lastPageCallBack?.call(profileResponseModel.data.length != perPage);
    return accountProfiles;
  }

// Watching Edit Profile

  static Future<WatchingProfileResponse> updateWatchProfile({
    required Map<String, dynamic> request,
    String imageFile = '',
  }) async {
    WatchingProfileResponse baseResponse = WatchingProfileResponse.fromJson(
      await getMultiPartResponse(
        endPoint: getEndPoint(endPoint: APIEndPoints.saveUserProfile),
        request: request,
        filePaths: [imageFile],
        fileKey: ApiRequestKeys.fileUrl,
      ),
    );

    return baseResponse;
  }

// Watching Delete Profile
  static Future<BaseResponseModel> deleteWatchingProfile({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.deleteWatchingProfile,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  /// Search Apis
// Save search
  static Future<WatchingProfileResponse> saveSearch({required Map request}) async {
    return WatchingProfileResponse.fromJson(
      await getApiResponse(
        APIEndPoints.saveSearch,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

// Clear All
  static Future<WatchingProfileResponse> clearAll() async {
    return WatchingProfileResponse.fromJson(
      await getApiResponse(
        "${APIEndPoints.deleteSearch}?${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}&type=clear_all",
      ),
    );
  }

// Particular Search Delete
  static Future<BaseResponseModel> deleteFromSearchHistory(int id) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        "${APIEndPoints.deleteSearch}?${ApiRequestKeys.userIdKey}=${loginUserData.value.id}&${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}&${ApiRequestKeys.idKey}=$id",
      ),
    );
  }

  static Future<List<FAQModel>> getFAQList({
    int page = 1,
    required List<FAQModel> faqList,
    Function(bool)? lastPageCallBack,
  }) async {
    int perPage = determinePerPage();
    List<String> params = [];
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');
    FAQResponse res = FAQResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.faqList, params: params),
      ),
    );
    if (page == 1) faqList.clear();
    lastPageCallBack?.call(res.data.length != perPage);
    faqList.addAll(res.data);

    return faqList;
  }

// Plan List API
  static Future<RxList<SubscriptionPlanModel>> getSubscriptionHistory({
    int page = 1,
    required List<SubscriptionPlanModel> subscriptionHistoryList,
    Function(bool)? lastPageCallBack,
  }) async {
    int perPage = determinePerPage();
    List<String> params = [];
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');
    SubscriptionResponse profileResponseModel = SubscriptionResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.subscriptionHistory, params: params),
      ),
    );
    if (page == 1) subscriptionHistoryList.clear();
    subscriptionHistoryList.addAll(profileResponseModel.data);
    lastPageCallBack?.call(profileResponseModel.data.length != perPage);
    return subscriptionHistoryList.obs;
  }

//Get Coupon List
  static Future<RxList<CouponDataModel>> getCouponListApi({
    int page = 1,
    String couponCode = "",
    required String planId,
    required List<CouponDataModel> couponList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    int perPage = determinePerPage();
    params.add('${ApiRequestKeys.planIdKey}=$planId');
    if (couponCode.isNotEmpty) params.add('${ApiRequestKeys.couponCode}=$couponCode');
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');

    CouponListResponse couponListResponse = CouponListResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.couponList, params: params),
      ),
    );
    if (page == 1) couponList.clear();
    couponList.addAll(couponListResponse.data);
    lastPageCallBack?.call(couponListResponse.data.length != perPage);
    return couponList.obs;
  }

  static Future<BaseResponseModel> changePin(Map<String, dynamic> request) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.changePin),
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  static Future<BaseResponseModel> getPinChangeOTP() async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        "${APIEndPoints.sendOtp}?${ApiRequestKeys.userIdKey}=${loginUserData.value.id}",
      ),
    );
  }

  static Future<BaseResponseModel> verifyOtp(Map<String, dynamic> request) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.verifyOtp),
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  static Future<BaseResponseModel> updateParentalLock(Map<String, dynamic> request) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.updateParentalLock),
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

// QR Code Scan Link TV API
  static Future<BaseResponseModel> linkWebAndTv({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.linkTv,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  static Future<PayPerViewModel> saveRentDetails({required Map request}) async {
    return PayPerViewModel.fromJson(await getApiResponse(APIEndPoints.saveRentDetails, request: request, method: HttpMethodType.POST));
  }

  static Future<RxList<PosterDataModel>> getRentedContent({
    int page = 1,
    int actorId = -1,
    int genresId = -1,
    String language = "",
    required List<PosterDataModel> rentedContentList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    int perPage = determinePerPage();
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
    }

    RentedContent movieList = RentedContent.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.rentedContentList, params: params),
        manageApiVersion: API_VERSION > 2,
      ),
    );
    if (page == 1) rentedContentList.clear();
    rentedContentList.addAll(movieList.data.movies + movieList.data.tvshows + movieList.data.videos + movieList.data.episodes);
    lastPageCallBack?.call((movieList.data.movies.length + movieList.data.tvshows.length + movieList.data.videos.length + movieList.data.episodes.length) != perPage);
    return rentedContentList.obs;
  }

  static Future<RxList<PosterDataModel>> getPayPerViewList({
    int page = 1,
    required List<PosterDataModel> rentalList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    int perPage = determinePerPage();
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
    }

    ListResponse payPerViewList = ListResponse.fromListJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.payPerViewList, params: params),
        manageApiVersion: API_VERSION > 2,
      ),
    );
    if (page == 1) rentalList.clear();
    rentalList.addAll(payPerViewList.data);
    lastPageCallBack?.call(payPerViewList.data.length != perPage);
    return rentalList.obs;
  }

  static Future<BaseResponseModel> startDate({required Map request}) async {
    return BaseResponseModel.fromJson(
      await getApiResponse(
        APIEndPoints.startDate,
        request: request,
        method: HttpMethodType.POST,
      ),
    );
  }

  static Future<RxList<RentalHistoryItem>> getRentalHistory({
    int page = 1,
    required List<RentalHistoryItem> rentalList,
    Function(bool)? lastPageCallBack,
  }) async {
    int perPage = determinePerPage();
    List<String> params = [];
    params.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
    }

    RentalHistoryModel res = RentalHistoryModel.fromJson(
      await getApiResponse(
        getEndPoint(
          endPoint: APIEndPoints.rentalHistory,
          params: params,
        ),
      ),
    );
    if (page == 1) rentalList.clear();
    lastPageCallBack?.call(res.data.length != perPage);
    rentalList.addAll(res.data);

    return rentalList.obs;
  }

  static Future<InvoiceResponse> downloadInvoice({required int id}) async {
    return InvoiceResponse.fromJson(
      await getApiResponse(
        '${APIEndPoints.downloadInvoice}/$id',
        method: HttpMethodType.GET,
      ),
    );
  }

  static Future<InvoiceResponse> payPerViewInvoice({required int id}) async {
    return InvoiceResponse.fromJson(
      await getApiResponse(
        '${APIEndPoints.payPerViewInvoice}/$id',
        method: HttpMethodType.GET,
      ),
    );
  }

  static Future<PaymentMethodModel> getAvailablePaymentMethods() async {
    return PaymentMethodModel.fromJson(
      await getApiResponse(
        APIEndPoints.paymentMethod,
        method: HttpMethodType.GET,
        manageApiVersion: API_VERSION > 2,
      ),
    );
  }

  static Future<ContentModel> getContentDetails({
    required int contentId,
    required String type,
    int tvShowId = 0,
    int seasonId = 0,
    bool requiresReleasedDataOnly = true,
  }) async {
    List<String> params = [];
    if (contentId > 0) params.add('${ApiRequestKeys.idKey}=$contentId');
    if (type.isNotEmpty) params.add('${ApiRequestKeys.typeKey}=$type');
    if (requiresReleasedDataOnly) params.add('${ApiRequestKeys.isReleasedKey}=1');

    if (tvShowId > 0) {
      params.add('${ApiRequestKeys.tvShowIdKey}=$tvShowId');
    }
    if (seasonId > 0) {
      params.add('${ApiRequestKeys.seasonIdKey}=$seasonId');
    }

    params.add('${ApiRequestKeys.deviceIdKey}=${currentDevice.value.deviceId}');
    if (loginUserData.value.id > -1) {
      params.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) params.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('${ApiRequestKeys.isRestrictedKey}=0');
    }
    ContentResponse contentResponse = ContentResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.contentDetails, params: params),
        method: HttpMethodType.GET,
        manageApiVersion: API_VERSION > 2,
      ),
    );
    return contentResponse.data;
  }

  static Future<List<PosterDataModel>> getContentList({
    int page = 1,
    String params = "",
    required String type,
    required List<PosterDataModel> contentList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> newParams = [];
    int perPage = determinePerPage();

    if (type.isNotEmpty) newParams.add('${ApiRequestKeys.typeKey}=$type');
    if (params.isNotEmpty) newParams.add(params);
    if (loginUserData.value.id > -1) {
      newParams.add('${ApiRequestKeys.userIdKey}=${loginUserData.value.id}');
      if (selectedAccountProfile.value.id > 0) newParams.add('${ApiRequestKeys.profileIdKey}=${selectedAccountProfile.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) newParams.add('${ApiRequestKeys.isRestrictedKey}=0');
    }

    newParams.add('${ApiRequestKeys.perPageKey}=$perPage&${ApiRequestKeys.pageKey}=$page');

    ListResponse movieList = ListResponse.fromListJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.contentList, params: newParams),
        manageApiVersion: API_VERSION > 2,
      ),
    );
    if (page == 1) contentList.clear();
    contentList.addAll(movieList.data);
    lastPageCallBack?.call(movieList.data.validate().length != perPage);
    return contentList;
  }

  static Future<List<WalkthroughModel>> getOnboardingData() async {
    WalkthroughListResponse contentListResponse = WalkthroughListResponse.fromJson(
      await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.onboardingList),
      ),
    );
    return contentListResponse.data;
  }

  static Future<Cast> getCastDetails({required String param}) async {
    // TODO: Fix CastResponse type
    // CastResponse castResponse = CastResponse.fromJson(
    //   await getApiResponse(
    //     getEndPoint(endPoint: APIEndPoints.castDetails, params: [param]),
    //     manageApiVersion: true,
    //   ),
    // );
    // return castResponse.data;
    throw UnimplementedError('CastResponse type needs to be defined');
  }

  // Shorts APIs
  static Future<BaseResponseModel> getShorts({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      List<String> params = ['${ApiRequestKeys.pageKey}=$page', '${ApiRequestKeys.perPageKey}=$limit'];
      if (queryParams != null) {
        queryParams.forEach((key, value) {
          params.add('$key=$value');
        });
      }

      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.shortsList, params: params),
        method: HttpMethodType.GET,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getShorts Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get shorts');
    }
  }

  static Future<BaseResponseModel> getTrendingShorts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.shortsTrending, params: ['${ApiRequestKeys.pageKey}=$page', '${ApiRequestKeys.perPageKey}=$limit']),
        method: HttpMethodType.GET,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getTrendingShorts Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get trending shorts');
    }
  }

  static Future<BaseResponseModel> getFeaturedShorts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.shortsFeatured, params: ['${ApiRequestKeys.pageKey}=$page', '${ApiRequestKeys.perPageKey}=$limit']),
        method: HttpMethodType.GET,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getFeaturedShorts Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get featured shorts');
    }
  }

  static Future<BaseResponseModel> likeShort(int shortId) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.shortLike.replaceAll('{id}', shortId.toString())),
        method: HttpMethodType.POST,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('likeShort Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to like short');
    }
  }

  static Future<BaseResponseModel> shareShort(int shortId) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.shortShare.replaceAll('{id}', shortId.toString())),
        method: HttpMethodType.POST,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('shareShort Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to share short');
    }
  }

  // Music APIs
  static Future<BaseResponseModel> getMusic({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      List<String> params = ['${ApiRequestKeys.pageKey}=$page', '${ApiRequestKeys.perPageKey}=$limit'];
      if (queryParams != null) {
        queryParams.forEach((key, value) {
          params.add('$key=$value');
        });
      }

      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.musicList, params: params),
        method: HttpMethodType.GET,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getMusic Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get music');
    }
  }

  static Future<BaseResponseModel> getTrendingMusic({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.musicTrending, params: ['${ApiRequestKeys.pageKey}=$page', '${ApiRequestKeys.perPageKey}=$limit']),
        method: HttpMethodType.GET,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getTrendingMusic Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get trending music');
    }
  }

  static Future<BaseResponseModel> getFeaturedMusic({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.musicFeatured, params: ['${ApiRequestKeys.pageKey}=$page', '${ApiRequestKeys.perPageKey}=$limit']),
        method: HttpMethodType.GET,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getFeaturedMusic Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get featured music');
    }
  }

  static Future<BaseResponseModel> searchMusic(String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.musicSearch, params: ['${ApiRequestKeys.searchQueryKey}=$query', '${ApiRequestKeys.pageKey}=$page', '${ApiRequestKeys.perPageKey}=$limit']),
        method: HttpMethodType.GET,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('searchMusic Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to search music');
    }
  }

  static Future<BaseResponseModel> getPlaylists() async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.playlistsList),
        method: HttpMethodType.GET,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getPlaylists Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get playlists');
    }
  }

  static Future<BaseResponseModel> getFeaturedPlaylists() async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.playlistsFeatured),
        method: HttpMethodType.GET,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getFeaturedPlaylists Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get featured playlists');
    }
  }

  static Future<BaseResponseModel> likeMusic(int musicId) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.musicLike.replaceAll('{id}', musicId.toString())),
        method: HttpMethodType.POST,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('likeMusic Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to like music');
    }
  }

  static Future<BaseResponseModel> playMusic(int musicId) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.musicPlay.replaceAll('{id}', musicId.toString())),
        method: HttpMethodType.POST,
      );

      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('playMusic Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to play music');
    }
  }

  static Future<BaseResponseModel> getAlbums({int page = 1, int limit = 20}) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.musicAlbums, params: ['page=$page', 'per_page=$limit']),
      );
      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getAlbums Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get albums');
    }
  }

  static Future<BaseResponseModel> getAlbumDetail(int albumId) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.musicAlbumDetail.replaceAll('{id}', albumId.toString())),
      );
      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getAlbumDetail Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get album');
    }
  }

  static Future<BaseResponseModel> getPlaylistDetail(int playlistId) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.musicPlaylistDetail.replaceAll('{id}', playlistId.toString())),
      );
      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getPlaylistDetail Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get playlist');
    }
  }

  static Future<BaseResponseModel> searchMusicGlobal(String query) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: APIEndPoints.musicGlobalSearch, params: ['q=${Uri.encodeComponent(query)}']),
      );
      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('searchMusicGlobal Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to search');
    }
  }

  static Future<BaseResponseModel> getMusicLyrics(int trackId) async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: 'music/tracks/$trackId/lyrics'),
      );
      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getMusicLyrics Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get lyrics');
    }
  }

  static Future<BaseResponseModel> getTracksByArtist(String artistName) async {
    try {
      final encoded = Uri.encodeComponent(artistName);
      final response = await getApiResponse(
        getEndPoint(endPoint: 'music/artist/$encoded'),
      );
      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getTracksByArtist Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get artist tracks');
    }
  }

  static Future<BaseResponseModel> getTracksByGenre(String genre) async {
    try {
      final encoded = Uri.encodeComponent(genre);
      final response = await getApiResponse(
        getEndPoint(endPoint: 'music/genre/$encoded'),
      );
      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getTracksByGenre Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get genre tracks');
    }
  }

  static Future<BaseResponseModel> getMusicCategories() async {
    try {
      final response = await getApiResponse(
        getEndPoint(endPoint: 'music/categories'),
      );
      return BaseResponseModel.fromJson(response);
    } catch (e) {
      log('getMusicCategories Error: $e');
      return BaseResponseModel(status: false, message: 'Failed to get categories');
    }
  }
}

// Helper functions
Map<String, dynamic> _ensureMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

SliderResponse _parseSliderResponse(Map<String, dynamic> json) => SliderResponse.fromJson(json);

ThumbnailListResponse _parseContinueWatchResponse(Map<String, dynamic> json) => ThumbnailListResponse.fromContinueWatchJson(json);

ListResponse _parseWatchListResponse(Map<String, dynamic> json) => ListResponse.fromListJson(json);