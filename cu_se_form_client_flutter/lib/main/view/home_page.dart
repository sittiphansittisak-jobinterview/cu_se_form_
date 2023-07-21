import 'package:cu_se_form_client_flutter/helper/user_helper.dart';
import 'package:cu_se_form_client_flutter/main/controller/home_controller.dart';
import 'package:cu_se_form_client_flutter/path/page_path.dart';
import 'package:cu_se_form_client_flutter/widget/drawer_widget.dart';
import 'package:cu_se_form_client_flutter/setting/image_path.dart';
import 'package:cu_se_form_client_flutter/style/color_style.dart';
import 'package:cu_se_form_client_flutter/style/font_size_style.dart';
import 'package:cu_se_form_client_flutter/style/sized_box_style.dart';
import 'package:cu_se_form_client_flutter/style/space_style.dart';
import 'package:cu_se_form_client_flutter/widget/template/card/image_card_widget.dart';
import 'package:cu_se_form_client_flutter/widget/template/loading/circular_loading_widget.dart';
import 'package:cu_se_form_client_flutter/widget/template/text/text_widget.dart';
import 'package:cu_se_form_client_flutter/widget/app_bar_widget.dart';
import 'package:cu_se_form_client_flutter/widget/sign_in_by_otp_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //helper
  final _topicTextColor = ColorStyle.light;

  //controller
  final _controller = HomeController();
  bool _isInitialPageFinished = false;

  //widget
  final _appBarWidget = const AppBarWidget();
  final _drawerWidget = const DrawerWidget();
  final _preparePageLoadingWidget = const CircularLoadingWidget(title: 'กำลังตรวจสอบประวัติการใช้งาน....');
  late final _topicWidget = TextWidget(text: "ยินดีต้อนรับสู่ CU SE", color: _topicTextColor, fontSize: FontSizeStyle.large, isBold: true);
  late final _sendOtpWidget = SignInByOtpWidget(otp: _controller.otp, onSendOtp: _controller.sendOtpRequest, onSignIn: _controller.sendSignInRequest);
  late final _applicationFormMenuWidget = ImageCardWidget(title: 'แบบฟอร์มประกอบการสมัครหลักสูตร SE', bgColor: ColorStyle.applicationFormMenu, image: ImagePath.applicationFormMenu, onClick: () => Get.toNamed(PagePath.applicationForm));

  @override
  void initState() {
    super.initState();
    _controller.initial().then((_) => setState(() => _isInitialPageFinished = true));
  }

  @override
  Widget build(BuildContext context) {
    //widget
    final subTopicWidget = Obx(() => TextWidget(text: UserHelper.isSigned.value ? "กรุณาเลือกแบบฟอร์มที่ต้องการสร้าง" : "กรุณาใช้รหัส OTP ในการลงชื่อเข้าใช้ โดยรหัส OTP มีอายุการใช้งาน 5 นาที", color: _topicTextColor));

    return Scaffold(
      appBar: _appBarWidget,
      endDrawer: _drawerWidget,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                padding: SpaceStyle.allBasic,
                color: ColorStyle.primary,
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBoxStyle.heightLarge,
                    _topicWidget,
                    SizedBoxStyle.heightSmall,
                    if (_isInitialPageFinished) subTopicWidget,
                    SizedBoxStyle.heightLarge,
                  ],
                ),
              ),
              SizedBoxStyle.heightBasic,
              !_isInitialPageFinished
                  ? _preparePageLoadingWidget
                  : Obx(() => UserHelper.isSigned.value
                      ? Wrap(
                          children: [
                            _applicationFormMenuWidget,
                          ].map((e) => Padding(padding: SpaceStyle.allBasic, child: e)).toList(),
                        )
                      : ConstrainedBox(constraints: const BoxConstraints(maxWidth: 210.0 * 2.83), child: _sendOtpWidget)),
            ],
          ),
        ),
      ),
    );
  }
}
