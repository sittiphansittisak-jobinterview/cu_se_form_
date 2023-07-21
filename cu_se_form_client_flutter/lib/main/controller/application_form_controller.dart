import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cu_se_form_client_flutter/utility/get_new_token.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:cu_se_form_share_dart/object/application_form_object.dart';
import 'package:cu_se_form_share_dart/object/api_object.dart';
import 'package:cu_se_form_share_dart/path/api_path.dart';
import 'package:cu_se_form_share_dart/utility/map_filter.dart';
import 'package:cu_se_form_share_dart/main/request_validation/save_application_form_request_validation.dart';
import 'package:cu_se_form_share_dart/utility/my_alert_message.dart';

class ApplicationFormController {
  final applicationForm = ApplicationFormObject();

  Future<(DialogType, String)> getApplicationForm() async {
    if (!await InternetConnection().hasInternetAccess) return (DialogType.error, 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต');
    final jwt = await getNewToken();
    if (jwt == null) return (DialogType.warning, 'ข้อมูล Token ไม่ถูกต้อง');
    final api = ApiObject(url: ApiPath.root + ApiPath.getApplicationForm, jwt: jwt);
    if (!await api.sendGetRequest()) return (DialogType.error, api.message ?? 'ดำเนินการไม่สำเร็จ (ไม่ได้รับข้อความแสดงข้อผิดพลาด)');

    applicationForm.clear();
    final applicationFormMap = api.data?['applicationForm'];
    if (applicationFormMap is! Map<String, dynamic> || applicationFormMap.isEmpty || !(applicationForm..map = applicationFormMap).toObject()) {
      applicationForm.clear();
      return (DialogType.error, 'ข้อมูลที่ได้รับจากเซิฟเวอร์ไม่ถูกต้อง ${MyAlertMessage.reportIssue}');
    }
    return (DialogType.success, api.message ?? '');
  }

  Future<(DialogType, String)> saveApplicationForm() async {
    String? message = saveApplicationFormRequestValidation(applicationForm: applicationForm);
    if (message != null) return (DialogType.warning, message);

    final applicationFormMap = mapFilter((applicationForm..toMap()).map);
    if (applicationFormMap == null) return (DialogType.error, 'เตรียมข้อมูลไม่สำเร็จ');

    if (!await InternetConnection().hasInternetAccess) return (DialogType.error, 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต');
    final jwt = await getNewToken();
    if (jwt == null) return (DialogType.warning, 'ข้อมูล Token ไม่ถูกต้อง');
    final api = ApiObject(url: ApiPath.root + ApiPath.saveApplicationForm, jwt: jwt);
    api.parameterBody.addAll({'applicationForm': applicationFormMap});
    if (!await api.sendPostFormDataRequest()) return (DialogType.error, api.message ?? 'ดำเนินการไม่สำเร็จ (ไม่ได้รับข้อความแสดงข้อผิดพลาด)');

    return (DialogType.success, api.message ?? 'บันทึกข้อมูลสำเร็จ');
  }
}
