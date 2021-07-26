import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_map/ui/screens/map_page.dart';

class OnBoardingScreen extends StatefulWidget {
  static String id = 'OnboardingScreen';
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  bool isPermissionGiven = false;
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) async {
    if (isPermissionGiven) {
      SharedPreferences myPrefs = await SharedPreferences.getInstance();
      myPrefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MapPage()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Permission not given"),
            content: Text("Please give location permission before procedding"),
            actions: [
              TextButton(
                child: Text("Okay"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 19.0),
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      isTopSafeArea: true,
      isBottomSafeArea: true,
      pages: [
        PageViewModel(
          title: "Welcome to map app tracker",
          body: "Here you can track your location real time",
          image: Image.asset('assets/map_loc_2.png'),
        ),
        PageViewModel(
          title: "Location Permission",
          body: "Location permission is required for using map tracker app",
          image: Image.asset('assets/map_loc.png'),
          footer: ElevatedButton(
            onPressed: () async {
              bool status = await checkGps();
              setState(() {
                isPermissionGiven = status;
              });
            },
            child: Text(
              'Get location',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          decoration: pageDecoration,
        )
      ],
      onDone: () => _onIntroEnd(context),
      nextFlex: 0,
      next: Icon(Icons.arrow_forward),
      done: Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: EdgeInsets.all(16),
      controlsPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }

  Future<bool> checkGps() async {
    var _permissionGranted = await Location().hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await Location().requestPermission();
    }
    if (_permissionGranted != PermissionStatus.granted) {
      return false;
    }
    return true;
  }
}
