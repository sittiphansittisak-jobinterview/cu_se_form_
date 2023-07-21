import 'dart:math';
import 'package:cu_se_form_client_flutter/setting/image_path.dart';
import 'package:cu_se_form_client_flutter/style/color_style.dart';
import 'package:cu_se_form_client_flutter/style/size_style.dart';
import 'package:cu_se_form_client_flutter/style/space_style.dart';
import 'package:cu_se_form_client_flutter/widget/template/image/any_image_widget.dart';
import 'package:flutter/material.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //helper
    final logoSize = SizeStyle.cardBasic.width * 0.8;
    final logoMaxSize = MediaQuery.of(context).size.width / 3;

    //widget
    final logoWidget = AnyImageWidget(imageColor: ColorStyle.secondary, iconSize: min(logoMaxSize, logoSize), image: ImagePath.logoTransparent);

    return Scaffold(
      backgroundColor: ColorStyle.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: SpaceStyle.allBig,
                constraints: BoxConstraints(maxWidth: logoMaxSize, maxHeight: logoSize),
                child: logoWidget,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
