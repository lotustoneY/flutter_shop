import 'package:flutter/material.dart';
import '../model/details.dart';
import '../service/service_method.dart';
import 'dart:convert';

class DetailsInfoProvide with ChangeNotifier {
  DetailsModel goodsInfo = null;

  // 详情-评论 tabBar
  bool isLeft = true;
  bool isRight = false;

  //  tabBar 的切换方法
  changeLeftAndRight(String changeState) {
    if (changeState == 'left') {
      isLeft = true;
      isRight = false;
    } else {
      isLeft = false;
      isRight = true;
    }

    notifyListeners();
  }

  // 从后台获取商品数据
  getGoodsInfo (String id) async {
    var formData = {'goodId': id};
    await request('getGoodDetailById', formData:formData).then((val){
      var responseData = json.decode(val.toString());
      goodsInfo = DetailsModel.fromJson(responseData);

      notifyListeners();
    });
  }
}
