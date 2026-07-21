import 'package:get/get.dart';
import 'package:apexprime_tv/controllers/base_controller.dart';
import 'package:apexprime_tv/models/base_response_model.dart';
import 'package:apexprime_tv/network/core_api.dart';
import 'package:apexprime_tv/screens/content/model/content_model.dart';
import 'package:apexprime_tv/screens/slider/slider_controller.dart';
import 'package:apexprime_tv/utils/api_end_points.dart';

class ContentListController extends BaseListController<PosterDataModel> {
  SliderController sliderController = SliderController();
  ArgumentModel argumentData = ArgumentModel(boolArgument: true);

  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<void> init() async {
    currentPage(1);
    if (Get.arguments is ArgumentModel) {
      argumentData = Get.arguments as ArgumentModel;
      argumentData.stringArgument += '&${ApiRequestKeys.isReleasedKey}=1';
      update([argumentData]);
      await Future.wait(
        [
          //Managed default banner for content list only when intArgument is -1(which is default)
          sliderController.getBanner(type: argumentData.stringArgument, showLoader: true),
          getListData(showLoader: false),
        ],
      );
    }
  }

  @override
  Future<void> getListData({bool showLoader = true}) async {
    setLoading(showLoader);

    await listContentFuture(
      CoreServiceApis.getContentList(
        type: argumentData.stringArgument,
        page: currentPage.value,
        contentList: listContent,
        lastPageCallBack: (p0) {
          isLastPage(p0);
        },
      ),
    ).catchError((e) {
      throw e;
    }).whenComplete(() => setLoading(false));
  }
}