import 'dart:async';

import 'package:get/get.dart';
import 'package:apexprime_tv/controllers/base_controller.dart';
import 'package:apexprime_tv/models/base_response_model.dart';
import 'package:apexprime_tv/network/core_api.dart';
import 'package:apexprime_tv/screens/content/model/content_model.dart';
import 'package:apexprime_tv/utils/api_end_points.dart';
import 'package:apexprime_tv/utils/constants.dart';

import '../../../utils/common_functions.dart';

class GenresDetailsController extends BaseListController<PosterDataModel> {
  ArgumentModel argumentData = ArgumentModel();
  RxList<String> availableFilter = <String>[].obs;

  RxInt currentFilterIndex = 0.obs;

  @override
  void onInit() {
    updateFilterTabs();
    ever(appConfigs, (_) => updateFilterTabs());
    getListData(showLoader: false);
    super.onInit();
  }

  void updateFilterTabs() {
    final List<String> tabs = <String>[ApiRequestKeys.allKey];
    if (appConfigs.value.enableMovie) tabs.add(VideoType.movie);
    if (appConfigs.value.enableTvShow) tabs.add(VideoType.tvshow);

    if (tabs.length == 2) tabs.removeWhere((element) => element == ApiRequestKeys.allKey);
    if (tabs.length > 1) availableFilter.assignAll(tabs);
  }

  String get currentFilterParam {
    final String filterType = availableFilter.isNotEmpty ? availableFilter[currentFilterIndex.value] : ApiRequestKeys.allKey;
    if (filterType == ApiRequestKeys.allKey) {
      return '${VideoType.movie},${VideoType.tvshow}';
    }
    return filterType;
  }

  @override
  Future<void> getListData({bool showLoader = true, String params = ''}) async {
    if (Get.arguments is ArgumentModel) {
      argumentData = Get.arguments as ArgumentModel;
      argumentData.stringArgument += '&${ApiRequestKeys.isReleasedKey}=1';
      update([argumentData]);
    }
    String newParams = argumentData.stringArgument;

    final queryParams = '$newParams&${ApiRequestKeys.searchTypeKey}=${currentFilterParam}';

    setLoading(showLoader);

    await listContentFuture(CoreServiceApis.searchContent(queryParams: queryParams)).then((value) {
      isLastPage(true);
      listContent(value);
      listContent.shuffle();
    }).catchError((e) {
      throw e;
    }).whenComplete(() => setLoading(false));
  }
}