import 'dart:async';

import 'package:streamit_laravel/controllers/base_controller.dart';
import 'package:streamit_laravel/screens/content/model/content_model.dart';

import '../../network/core_api.dart';

class RentalListController extends BaseListController<PosterDataModel> {
  @override
  void onInit() {
    getListData(showLoader: false);
    super.onInit();
  }

  @override
  Future<void> getListData({bool showLoader = true}) async {
    await listContentFuture(
      CoreServiceApis.getPayPerViewList(
        page: currentPage.value,
        rentalList: listContent,
        lastPageCallBack: (p0) {
          isLastPage(p0);
        },
      ),
    ).catchError((e) {
      throw e;
    }).whenComplete(() => isLoading(false));
  }
}