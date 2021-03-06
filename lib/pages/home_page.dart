import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../routers/application.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {

  int page = 1;
  List<Map> hotGoodsList = [];

  GlobalKey<RefreshFooterState> _footerkey = new GlobalKey<RefreshFooterState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  String homePageContent = '正在获取数据';
  @override
  Widget build(BuildContext context) {
    var formData = {'lon':'115.02932', 'lat':'35.76189'};
    return Scaffold(
      appBar: AppBar(title: Text('百姓生活+')),
      body: FutureBuilder(
        future: request('homePageContent', formData:formData),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // 数据处理
            var  data = json.decode(snapshot.data.toString());
            List<Map> swiper = (data['data']['slides'] as List).cast();
            List<Map> navigatorList = (data['data']['category'] as List).cast();
            String adPicture = data['data']['advertesPicture']['PICTURE_ADDRESS'];
            String leaderImage = data['data']['shopInfo']['leaderImage'];
            String leaderPhone = data['data']['shopInfo']['leaderPhone'];
            List<Map> recommendList = (data['data']['recommend'] as List).cast();
            String floor1Title = data['data']['floor1Pic']['PICTURE_ADDRESS'];
            String floor2Title = data['data']['floor2Pic']['PICTURE_ADDRESS'];
            String floor3Title = data['data']['floor3Pic']['PICTURE_ADDRESS'];
            List<Map> floor1 = (data['data']['floor1'] as List).cast();
            List<Map> floor2 = (data['data']['floor2'] as List).cast();
            List<Map> floor3 = (data['data']['floor3'] as List).cast();

            return EasyRefresh(
              refreshFooter: ClassicsFooter(
                key: _footerkey,
                bgColor: Colors.white,
                textColor: Colors.pink,
                moreInfoColor: Colors.pink,
                showMore: true,
                noMoreText: '',
                moreInfo: '加载中...',
                loadReadyText: '上拉加载'
              ),
              child: ListView(
                children: <Widget>[
                  SwiperDiy(swiperDataList: swiper),
                  TopNavigator(navigatorList: navigatorList),
                  AdBanner(adPicture: adPicture),
                  LeaderPhone(leaderImage: leaderImage, leaderPhone: leaderPhone),
                  Recommend(recommendList:recommendList),
                  FloorTitle(pictureAddress: floor1Title),
                  FloorContent(floorGoodsList: floor1),
                  FloorTitle(pictureAddress: floor2Title),
                  FloorContent(floorGoodsList: floor2),
                  FloorTitle(pictureAddress: floor3Title),
                  FloorContent(floorGoodsList: floor3),
                  _hotGoods()
                ],
              ),
              loadMore: () async {
                print('开始加载更多...');
                
                var formData = {'page': page};
                await request('homePageBelowConten', formData: formData).then((val) {
                  var data = json.decode(val.toString());
                  List<Map> newGoodsList = (data['data'] as List).cast();
                  setState(() {
                    hotGoodsList.addAll(newGoodsList);
                    page++;
                  });
                });
              }
            );
          } else {
            return Center(
              child: Text('加载中...')
            );
          }
        },
      )
    );
  }

  Widget hotTitle = Container(
    margin:EdgeInsets.only(top:10),
    alignment:Alignment.center,
    color: Colors.transparent,
    padding: EdgeInsets.all(5),
    child: Text('火爆专区')
  );

  Widget _wrapList() {
    // 流式布局要判断数据长度，如果为0会报错
    if (hotGoodsList.length != 0) {
      List<Widget> listWidget = hotGoodsList.map((val) {
        return InkWell(
          onTap: () {
            Application.router.navigateTo(context, '/detail?id=${val["goodsId"]}');
          },
          child: Container(
            width: ScreenUtil().setWidth(372),
            color: Colors.white,
            padding: EdgeInsets.all(5),
            margin:EdgeInsets.only(bottom:3),
            child: Column(
              children: <Widget>[
                Image.network(val['image'], width:ScreenUtil().setWidth(370)),
                Text(
                  val['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color:Colors.pink, fontSize:ScreenUtil().setSp(26))
                ),
                Row(
                  children: <Widget>[
                    Text('￥${val['mallPrice']}'),
                    Text(
                      '￥${val['price']}',
                      style: TextStyle(color:Colors.black26,decoration:TextDecoration.lineThrough)
                    ),
                  ],
                )
              ],
            )
          )
        );
      }).toList();

      return Wrap(
        spacing: 2, // 每行的列数
        children: listWidget
      );
    } else {
      return Text('');
    }
  }

  Widget _hotGoods() {
    return Container(
      child: Column(
        children: <Widget>[
          hotTitle,
          _wrapList()
        ]
      ),
    );
  }
}

// 首页轮播组件
class SwiperDiy extends StatelessWidget {
  
  final List swiperDataList;

  SwiperDiy({this.swiperDataList});

  @override
  Widget build(BuildContext context) {
    // print('设备宽:${ScreenUtil.screenWidth}');
    // print('设备高:${ScreenUtil.screenHeight}');
    // print('设备像素密度:${ScreenUtil.pixelRatio}');

    return Container(
      height: ScreenUtil().setHeight(333),
      width:ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              Application.router.navigateTo(context, '/detail?id=${swiperDataList[index]["goodsId"]}');
            },
            child: Image.network('${swiperDataList[index]["image"]}', fit:BoxFit.fill)
          );
        },
        itemCount: swiperDataList.length,
        pagination: SwiperPagination(),
        autoplay: true
      )
    );
  }
}

// 顶部导航-网格组件
class TopNavigator extends StatelessWidget {
  final List navigatorList;

  TopNavigator({Key key, this.navigatorList}) : super(key: key);

  Widget _gridViewItemUI(BuildContext context, item) {
    return InkWell(
      onTap: (){
        print('点击了导航');
      },
      child: Column(
        children: <Widget>[
          Image.network(item['image'], width:ScreenUtil().setWidth(95)),
          Text(item['mallCategoryName'])
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this.navigatorList.length > 10) {
      // this.navigatorList.removeRange(10, this.navigatorList.length);
      this.navigatorList.removeLast();
    }
    return Container(
      height:ScreenUtil().setHeight(320),
      padding:EdgeInsets.all(3),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        padding:EdgeInsets.all(5),
        children: navigatorList.map((item){
          return _gridViewItemUI(context, item);
        }).toList(),
      )
    );
  }
}

// 广告区域
class AdBanner extends StatelessWidget {
  final String adPicture;

  AdBanner({Key key, this.adPicture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(adPicture),
    );
  }
}

// 店长电话
class LeaderPhone extends StatelessWidget {
  final String leaderImage; // 店长图片
  final String leaderPhone; // 店长电话

  LeaderPhone({Key key, this.leaderImage, this.leaderPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launchURL,
        child:Image.network(leaderImage),
      ),
    );
  }

  void _launchURL() async {
    String url = 'tel:' + leaderPhone;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'url不能进行访问，异常';
    }
  }
}

// 商品推荐
class Recommend extends StatelessWidget {
  final List recommendList;

  Recommend({Key key, this.recommendList}) : super(key: key);

  // 标题
  Widget _titleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10, 2, 0, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom:BorderSide(width: .5, color: Colors.black12)
        )
      ),
      child: Text(
        '商品推荐',
        style: TextStyle(color: Colors.pink)
      )
    );
  }

  // 商品 item
  Widget _item(context, index) {
    return InkWell(
      onTap: (){
        Application.router.navigateTo(context, '/detail?id=${recommendList[index]["goodsId"]}');
      },
      child:Container(
        height: ScreenUtil().setHeight(330),
        width: ScreenUtil().setWidth(250),
        padding:EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(width: .5, color: Colors.black12)
          )
        ),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index]['image']),
            Text('￥${recommendList[index]["mallPrice"]}'),
            Text(
              '￥${recommendList[index]["Price"]}',
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey
              )
            ),
          ],
        )
      )
    );
  }

  // 横向列表
  Widget _recommendList() {
    return Container(
      height: ScreenUtil().setHeight(350),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendList.length,
        itemBuilder: (context, index) {
          return _item(context, index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(450),
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          _titleWidget(),
          _recommendList()
        ],
      )
    );
  }
}

// 楼层标题
class FloorTitle extends StatelessWidget {
  final String pictureAddress;

  FloorTitle({Key key, this.pictureAddress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:EdgeInsets.all(8),
      child: Image.network(pictureAddress),
    );
  }
}

// 楼层商品列表
class FloorContent extends StatelessWidget {
  final List floorGoodsList;

  FloorContent({Key key, this.floorGoodsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _firstRow(context),
          _otherGoods(context)
        ],
      ),
    );
  }

  // 第一行商品
  Widget _firstRow(context) {
    return Row(
      children: <Widget>[
        _goodsItem(context, floorGoodsList[0]),
        Column(
          children: <Widget>[
            _goodsItem(context, floorGoodsList[1]),
            _goodsItem(context, floorGoodsList[2])
          ],
        )
      ],
    );
  }

  // 第二行商品
  Widget _otherGoods(context) {
    return Row(
      children: <Widget>[
        _goodsItem(context, floorGoodsList[3]),
        _goodsItem(context, floorGoodsList[4])
      ],
    );
  }

  // 单个商品
  Widget _goodsItem(BuildContext context, Map goods) {
    return Container(
      width:ScreenUtil().setWidth(375),
      child: InkWell(
        onTap: (){
          Application.router.navigateTo(context, '/detail?id=${goods["goodsId"]}');
        },
        child: Image.network(goods['image'])
      )
    );
  }
}
