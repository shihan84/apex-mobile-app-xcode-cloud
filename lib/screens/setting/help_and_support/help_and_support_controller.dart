import 'package:apexprime_tv/controllers/base_controller.dart';
import 'package:apexprime_tv/main.dart';
import 'package:apexprime_tv/network/core_api.dart';
import 'package:apexprime_tv/screens/auth/model/about_page_res.dart';
import 'package:apexprime_tv/services/local_storage_service.dart';
import 'package:apexprime_tv/utils/common_functions.dart';
import 'package:apexprime_tv/utils/constants.dart';

class HelpAndSupportController extends BaseListController<AboutDataModel> {
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    getListData(showLoader: false);
    super.onReady();
  }

  @override
  Future<void> getListData({bool showLoader = true}) async {
    setLoading(showLoader);
    await listContentFuture(CoreServiceApis.getPageList()).then((value) {
      isLastPage(true);
      listContent(value);
      if (!listContent.any((element) => element.slug == AppPages.faq)) {
        listContent.add(
          AboutDataModel(
            slug: AppPages.faq,
            name: locale.value.faqs,
          ),
        );
      }
      appPageList(value); // data in the observable list
      setIntToLocal(SharedPreferenceConst.PAGE_LAST_CALL_TIME, DateTime.timestamp().millisecondsSinceEpoch);
    }).catchError((e) {
      throw e;
    }).whenComplete(() => setLoading(false));
  }
}