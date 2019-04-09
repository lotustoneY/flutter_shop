import 'package:flutter/material.dart';
import '../model/category.dart';

class ChildCategory with ChangeNotifier {
  List<BxMallSubDto> childCategoryList = [];
  int childIndex = 0; // 子类高亮索引
  String categoryId = '4'; // 大类ID，默认白酒-4
  String subId = ''; // 小类ID，默认空
  int page = 1; // 列表页数
  String noMoreText = ''; // 无更多时提示信息

  // 大类切换
  getChildCategory (List<BxMallSubDto> list, String id) {
    page = 1; // 切换大类页面重置
    noMoreText = '';
    childIndex = 0; // 点击大类时子类归零
    categoryId = id;
    BxMallSubDto all = BxMallSubDto();

    all.mallCategoryId = '00';
    all.mallSubId = '';
    all.mallSubName = '全部';
    all.comments = 'null';

    childCategoryList = [all];
    childCategoryList.addAll(list);

    notifyListeners(); // 监听
  }

  // 改变子类索引
  changeChildIndex(index, String id) {
    page = 1; // 切换大类页面重置
    noMoreText = '';
    childIndex = index;
    subId = id;
    notifyListeners();
  }

  // 增加 Page 的方法
  addPage() {
    page++;

  }
  // 改变 noMoreText 的方法
  changeNoMoreText(String text) {
    noMoreText = text;
    notifyListeners();
  }
}
