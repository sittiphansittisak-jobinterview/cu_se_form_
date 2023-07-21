import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cu_se_form_client_flutter/helper/user_helper.dart';
import 'package:cu_se_form_client_flutter/main/model/user_model.dart';
import 'package:cu_se_form_client_flutter/utility/sign_in.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:cu_se_form_share_dart/object/key/otp_key.dart';
import 'package:cu_se_form_share_dart/object/otp_object.dart';
import 'package:cu_se_form_share_dart/object/user_object.dart';
import 'package:cu_se_form_share_dart/object/api_object.dart';
import 'package:cu_se_form_share_dart/path/api_path.dart';
import 'package:cu_se_form_share_dart/utility/map_filter.dart';
import 'package:cu_se_form_share_dart/main/request_validation/send_otp_request_validation.dart';
import 'package:cu_se_form_share_dart/utility/my_alert_message.dart';
import 'package:cu_se_form_share_dart/main/request_validation/sign_in_request_validation.dart';

class HomeController {
  final otp = OtpObject();

  //prepare default data
  Future initial() async {
    otp.email = UserModel.getEmail();
  }

  Future<(DialogType, String)> sendOtpRequest() async {
    String? message = sendOtpRequestValidation(otp: otp);
    if (message != null) return (DialogType.warning, message);

    final otpMap = mapFilter((otp..toMap()).map, allowKey: [OtpKey.email]);
    if (otpMap == null) return (DialogType.error, 'เตรียมข้อมูลไม่สำเร็จ');

    if (!await InternetConnection().hasInternetAccess) return (DialogType.error, 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต');
    final api = ApiObject(url: ApiPath.root + ApiPath.sendOtp);
    api.parameterBody.addAll({'otp': otpMap});
    if (!await api.sendPostFormDataRequest()) return (DialogType.error, api.message ?? 'ดำเนินการไม่สำเร็จ (ไม่ได้รับข้อความแสดงข้อผิดพลาด)');

    final otpRef = api.data?['otpRef'];
    if (otpRef is! String) return (DialogType.error, 'ข้อมูลที่ได้รับจากเซิฟเวอร์ไม่ถูกต้อง ${MyAlertMessage.reportIssue}');
    otp.otpRef = otpRef;
    return (DialogType.success, api.message ?? 'ระบบได้ส่งรหัส OTP ไปยังอีเมลดังกล่าวแล้ว หากไม่ได้รับอีเมลกรุณาตรวจสอบอีเมลและลองใหม่อีกครั้ง');
  }

  Future<(DialogType, String)> sendSignInRequest() async {
    String? message = signInRequestValidation(otp: otp);
    if (message != null) return (DialogType.warning, message);

    final otpMap = mapFilter((otp..toMap()).map, allowKey: [OtpKey.email, OtpKey.otpRef, OtpKey.otpValue]);
    if (otpMap == null) return (DialogType.error, 'เตรียมข้อมูลไม่สำเร็จ');

    if (!await InternetConnection().hasInternetAccess) return (DialogType.error, 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต');
    final api = ApiObject(url: ApiPath.root + ApiPath.signIn);
    api.parameterBody.addAll({'otp': otpMap});
    if (!await api.sendPostFormDataRequest()) return (DialogType.error, api.message ?? 'ดำเนินการไม่สำเร็จ (ไม่ได้รับข้อความแสดงข้อผิดพลาด)');

    final userMap = api.data?['user'];
    if (userMap is! Map<String, dynamic>) return (DialogType.error, 'ข้อมูลที่ได้รับจากเซิฟเวอร์ไม่ถูกต้อง ${MyAlertMessage.reportIssue}');
    final user = UserObject()..map = userMap;
    if (!user.toObject()) return (DialogType.error, 'แปลงข้อมูลที่ได้รับจากเซิฟเวอร์ไม่สำเร็จ ${MyAlertMessage.reportIssue}');

    if (!await signIn(refreshJwt: user.refreshJwt, accessJwt: user.accessJwt)) return (DialogType.error, 'บันทึกโทเค็นไม่สำเร็จ ${MyAlertMessage.reportIssue}');
    UserHelper.email.value = otp.email;
    await UserModel.setEmail(otp.email);
    return (DialogType.success, api.message ?? '');
  }
}
