import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evfinder/utils.dart';
import 'package:evfinder/views/home/tab/tab_booking.dart';
import 'package:evfinder/views/home/tab/tab_home.dart';
import 'package:evfinder/views/home/tab/tab_profile.dart';
import 'package:evfinder/views/home/tab/tab_map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../base/color_data.dart';
import '../../base/constant.dart';
import '../../base/resizer/fetch_pixels.dart';
import '../../base/widget_utils.dart';
import '../../models/model_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  void close() {
    Constant.closeApp();
  }

  List<Widget> tabList = [
    TabHome(),
    MapPage(),
    TabBooking(),
    TabProfile(),
  ];

  List<ModelItem> itemList = [
    ModelItem("home-selected.png", "home.png", "Home"),
    ModelItem("map-selected.png", "map.png", "Map"),
    ModelItem("calendar-selected.png", "calendar.png", "Booking"),
    ModelItem("user-selected.png", "user.png", "Profile"),
  ];

  int position = 0;

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: SafeArea(
            child: tabList[position],
          ),
          bottomNavigationBar: bottomNavigationBar(),
        ),
        onWillPop: () async {
          close();
          return false;
        });
  }

  Container bottomNavigationBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelHeight(20)),
      height: FetchPixels.getPixelHeight(80),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
        color: Color(0xff9dd1ea),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.generate(itemList.length, (index) {
          ModelItem modelItem = itemList[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                position = index;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getAssetImage(
                  position == index ? modelItem.selectedImage ?? "" : modelItem.image ?? '',
                  width: 36,
                  height: 36,
                ),
                SizedBox(height: 4),
                Text(
                  modelItem.label ?? '',
                  style: SafeGoogleFont(
                    'Lato',
                    color: position == index ? Colors.white : Color(0xff2d366f),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

}
