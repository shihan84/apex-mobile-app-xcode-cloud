import 'package:get/get.dart';
import 'package:streamit_laravel/controllers/base_controller.dart';
import 'package:streamit_laravel/models/base_response_model.dart';
import 'package:streamit_laravel/network/core_api.dart';
import 'package:streamit_laravel/screens/content/model/content_model.dart';
import 'package:streamit_laravel/utils/api_end_points.dart';
import 'package:streamit_laravel/utils/common_functions.dart';
import 'package:streamit_laravel/utils/constants.dart';

class FilteredContentListController extends BaseListController<PosterDataModel> {
  ArgumentModel argumentData = ArgumentModel();

  RxList<String> availableFilter = <String>[].obs;

  RxInt currentFilterIndex = 0.obs;

  @override
  void onInit() {
    updateFilterTabs();
    ever(appConfigs, (_) => updateFilterTabs());
    argumentData = Get.arguments as ArgumentModel;
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
      if (argumentData.intArgument == 0) {
        return '';
      } else if (appConfigs.value.enableVideo && argumentData.intArgument == -1) {
        return '${VideoType.movie},${VideoType.tvshow},${VideoType.video}';
      }

      return '${VideoType.movie},${VideoType.tvshow}';
    }
    return filterType;
  }

  @override
  Future<void> getListData({bool showLoader = true, String params = ''}) async {
    if (Get.arguments is ArgumentModel) {
      argumentData = Get.arguments as ArgumentModel;
      update([argumentData]);
    }
    String newParams = argumentData.stringArgument;

    final queryParams = '$newParams&${ApiRequestKeys.isReleasedKey}=1&${currentFilterParam.isNotEmpty ? '${ApiRequestKeys.searchTypeKey}=${currentFilterParam}' : ''}';

    setLoading(showLoader);
    await listContentFuture(CoreServiceApis.searchContent(queryParams: queryParams))
        .then(
          (value) {
            isLastPage(true);
            listContent(value);
          },
        )
        .whenComplete(() => setLoading(false))
        .catchError((e) {
          throw e;
        });
  }

  @override
  void onClose() {
    super.onClose();
  }
}