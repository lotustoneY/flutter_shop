import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../provide/details_info.dart';
import './details_page/details_top_area.dart';
import './details_page/details_explain.dart';
import './details_page/details_tabbar.dart';
import './details_page/details_web.dart';
import './details_page/details_bottom.dart';

class DetailsPage extends StatelessWidget {
  final String goodsId;

  DetailsPage(this.goodsId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('商品详情'),
      ),
      body: FutureBuilder(
        future: _getBackInfo(context),
        builder: (context, snapshort) {
          if (snapshort.hasData) {
            return Stack(
              children: <Widget>[
                // 内容区
                Container(
                  // column 会溢出，ListView 不会溢出
                  child: ListView(
                    children: <Widget>[
                      DetailsTopArea(), // 图片和信息
                      DetailsExplain(), // 说明
                      DetailsTabbar(), // TabBar
                      DetailsWeb(), // 商品详情
                    ],
                  )
                ),
                // 购物车 Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: DetailsBottom()
                )
              ],
            );
          } else {
            return Text('加载中...');
          }
        },
      )
    );
  }

  Future _getBackInfo(BuildContext context) async {
    await Provide.value<DetailsInfoProvide>(context).getGoodsInfo(goodsId);
    return '加载完成';
  }
}
