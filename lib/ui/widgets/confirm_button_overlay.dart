import 'package:background_locator/background_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:slidable_button/slidable_button.dart';

class ConfirmButtonOverlay extends StatefulWidget {
  @override
  _ConfirmButtonOverlayState createState() => _ConfirmButtonOverlayState();
}

class _ConfirmButtonOverlayState extends State<ConfirmButtonOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  Future<void> onStop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    final _isRunning = await BackgroundLocator.isServiceRunning();
    print(_isRunning.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.fromLTRB(
          0, 0, 0, MediaQuery.of(context).size.height / 5.2),
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: SlidableButton(
            width: MediaQuery.of(context).size.width / 2,
            buttonWidth: 50.0,
            height: 50,
            color: Colors.grey.withOpacity(0.6),
            buttonColor: Colors.blueGrey,
            dismissible: false,
            label: Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
            onChanged: (position) async {
              if (position == SlidableButtonPosition.right) {
                print('Button is on the right');
                Vibrate.vibrate();
                Navigator.pop(context, true);
              } else {
                print('Button is on the left');
              }
            },
          ),
        ),
      ),
    );
  }
}
