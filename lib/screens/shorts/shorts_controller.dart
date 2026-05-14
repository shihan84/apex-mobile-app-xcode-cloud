import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/network/core_api.dart';
import 'package:streamit_laravel/utils/common_base.dart';

import 'models/short_model.dart';

class ShortsController extends GetxController {
  RxList<Short> shorts = <Short>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    getShorts();
  }

  Future<void> getShorts({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      shorts.clear();
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await CoreServiceApis.getShorts(
        page: currentPage.value,
        limit: 20,
      );

      if (response.status) {
        if (refresh) {
          shorts.assignAll(response.data.map((item) => Short.fromJson(item)).toList());
        } else {
          shorts.addAll(response.data.map((item) => Short.fromJson(item)).toList());
        }
        
        hasMore.value = response.data.length >= 20;
        if (hasMore.value) {
          currentPage.value++;
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to load shorts';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTrendingShorts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await CoreServiceApis.getTrendingShorts();

      if (response.status) {
        shorts.assignAll(response.data.map((item) => Short.fromJson(item)).toList());
      } else {
        errorMessage.value = response.message ?? 'Failed to load trending shorts';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getFeaturedShorts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await CoreServiceApis.getFeaturedShorts();

      if (response.status) {
        shorts.assignAll(response.data.map((item) => Short.fromJson(item)).toList());
      } else {
        errorMessage.value = response.message ?? 'Failed to load featured shorts';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> likeShort(int shortId) async {
    try {
      final response = await CoreServiceApis.likeShort(shortId);
      
      if (response.status) {
        final index = shorts.indexWhere((short) => short.id == shortId);
        if (index != -1) {
          shorts[index] = shorts[index].copyWith(
            likeCount: response.data['like_count'],
            isLiked: response.data['liked'],
          );
        }
        
        toast(response.data['liked'] ? 'Short liked!' : 'Short unliked!');
      }
    } catch (e) {
      toast('Failed to like short');
      log(e.toString());
    }
  }

  Future<void> shareShort(int shortId) async {
    try {
      final response = await CoreServiceApis.shareShort(shortId);
      
      if (response.status) {
        toast('Short shared successfully!');
      }
    } catch (e) {
      toast('Failed to share short');
      log(e.toString());
    }
  }

  Future<void> refreshShorts() async {
    await getShorts(refresh: true);
  }

  void loadMoreShorts() {
    if (hasMore.value && !isLoading.value) {
      getShorts();
    }
  }
}
