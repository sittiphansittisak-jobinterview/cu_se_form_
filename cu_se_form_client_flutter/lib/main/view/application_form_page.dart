import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cu_se_form_client_flutter/helper/user_helper.dart';
import 'package:cu_se_form_client_flutter/main/controller/application_form_controller.dart';
import 'package:cu_se_form_client_flutter/path/page_path.dart';
import 'package:cu_se_form_client_flutter/widget/template/button/icon_button_widget.dart';
import 'package:cu_se_form_client_flutter/widget/template/loading/top_refresh_widget.dart';
import 'package:cu_se_form_client_flutter/utility/sign_out.dart';
import 'package:cu_se_form_client_flutter/widget/app_bar_widget.dart';
import 'package:cu_se_form_client_flutter/widget/drawer_widget.dart';
import 'package:cu_se_form_client_flutter/style/color_style.dart';
import 'package:cu_se_form_client_flutter/style/font_size_style.dart';
import 'package:cu_se_form_client_flutter/style/sized_box_style.dart';
import 'package:cu_se_form_client_flutter/style/space_style.dart';
import 'package:cu_se_form_client_flutter/widget/template/dialog/awesome_dialog_widget.dart';
import 'package:cu_se_form_client_flutter/widget/template/loading/circular_loading_widget.dart';
import 'package:cu_se_form_client_flutter/widget/template/text/text_widget.dart';
import 'package:cu_se_form_client_flutter/widget/application_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApplicationFormPage extends StatefulWidget {
  const ApplicationFormPage({Key? key}) : super(key: key);

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  //helper
  final BoxConstraints _formWidth = const BoxConstraints(maxWidth: 210.0 * 2.83);

  //controller
  final _controller = ApplicationFormController();
  final Rx<bool> _isGetApplicationFormLoading = Rx(false);

  //widget
  final _appBarWidget = const AppBarWidget(url: PagePath.home);
  final _drawerWidget = const DrawerWidget();
  final _titleWidget = const TextWidget(text: 'แบบฟอร์มประกอบการสมัครหลักสูตร SE', isBold: true, fontSize: FontSizeStyle.big);
  final _subTitleWidget = const TextWidget(text: 'กรุณากรอกข้อมูลตามจริงและสมบูรณ์มากที่สุดเท่าที่จะเป็นไปได้', fontSize: FontSizeStyle.basic);
  final _dividerWidget = const Divider(color: ColorStyle.primary);
  final _loadingWidget = const CircularLoadingWidget(title: 'กำลังดำเนินการ....');
  late final _applicationFormWidget = ApplicationFormWidget(isWrite: true, applicationForm: _controller.applicationForm);
  late final Widget _refreshApplicationFormButtonWidget = IconButtonWidget(icon: Icons.refresh, tooltip: 'โหลดข้อมูลใหม่', onClick: onRefresh);
  late final Widget _saveApplicationFormButtonWidget = FloatingActionButton(
      backgroundColor: ColorStyle.accent,
      tooltip: 'บันทึกข้อมูล',
      onPressed: () async {
        final (dialogType, message) = await _controller.saveApplicationForm();
        await AwesomeDialogWidget.normal(dialogType: dialogType, detail: message);
      },
      child: const Icon(Icons.save));

  Future onRefresh() async {
    if (_isGetApplicationFormLoading.value) return;
    _isGetApplicationFormLoading.value = true;
    final (dialogType, message) = await _controller.getApplicationForm();
    if (dialogType != DialogType.success) await AwesomeDialogWidget.normal(dialogType: dialogType, detail: message);
    _isGetApplicationFormLoading.value = false;
  }

  @override
  void initState() {
    super.initState();
    if (!UserHelper.isSigned.value) Future.delayed(Duration.zero, () => AwesomeDialogWidget.warning(title: 'กรุณาลงชื่อเข้าใช้').then((_) => signOut()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget,
      endDrawer: _drawerWidget,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            TopRefreshWidget(
              isInitialRefresh: UserHelper.isSigned.value,
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                padding: SpaceStyle.allBasic,
                child: Center(
                  child: Column(
                    children: [
                      SizedBoxStyle.heightBig,
                      _titleWidget,
                      _subTitleWidget,
                      Padding(padding: SpaceStyle.verticalBasic, child: _dividerWidget),
                      ConstrainedBox(constraints: _formWidth, child: Obx(() => _isGetApplicationFormLoading.value ? _loadingWidget : _applicationFormWidget)),
                    ],
                  ),
                ),
              ),
            ),
            Obx(() => _isGetApplicationFormLoading.value ? SizedBoxStyle.none : Padding(padding: SpaceStyle.allBasic, child: _refreshApplicationFormButtonWidget)),
          ],
        ),
      ),
      floatingActionButton: Obx(() => _isGetApplicationFormLoading.value ? SizedBoxStyle.none : Padding(padding: SpaceStyle.allBasic, child: _saveApplicationFormButtonWidget)),
    );
  }
}
