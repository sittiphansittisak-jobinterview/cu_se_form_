import 'package:cu_se_form_server_dart/main/model/application_form_model.dart';
import 'package:cu_se_form_server_dart/helper/controller_helper.dart';
import 'package:cu_se_form_server_dart/setting/mongodb.dart';
import 'package:cu_se_form_server_dart/setting/token_setting.dart';
import 'package:cu_se_form_share_dart/object/application_form_object.dart';
import 'package:cu_se_form_share_dart/object/token_object.dart';
import 'package:cu_se_form_share_dart/object/api_object.dart';
import 'package:cu_se_form_share_dart/utility/my_alert_message.dart';

class GetApplicationFormController {
  GetApplicationFormController({required ApiObject api}) : _api = api;

  final ApiObject _api;
  final _mongodb = Mongodb();

  //request
  final _tokenRequest = TokenObject();

  //response
  final response = ControllerHelper();
  final applicationFormResponse = ApplicationFormObject();

  Future<bool> receiveRequest() async {
    final jwt = _api.jwt;
    if (jwt is! String) return response.failed('ข้อมูล Token ไม่ถูกต้อง');

    _tokenRequest.jwt = jwt;
    return true;
  }

  Future<bool> validateRequest() async {
    if (!_tokenRequest.decode(secretKey: TokenSetting.accessTokenSecretKey)) return response.failed('ข้อมูลโทเค็นไม่ถูกต้อง กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
    if (_tokenRequest.isExpired) return response.failed('โทเค็นหมดอายุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
    return true;
  }

  Future<bool> findApplicationForm() async {
    await _mongodb.openDb();
    applicationFormResponse.map = await ApplicationFormModel.findOneByUserId(_mongodb, userId: _tokenRequest.userId!);
    await _mongodb.closeDb();
    if (applicationFormResponse.map == null) return response.failed('ไม่พบข้อมูลใบงาน/ยังไม่ได้สร้างใบงานไว้');
    if (!applicationFormResponse.toObject()) return response.failed('แปลงข้อมูลใบงานไม่สำเร็จ (${MyAlertMessage.reportIssue})'); //Data from database is not match with object
    return true;
  }
}
