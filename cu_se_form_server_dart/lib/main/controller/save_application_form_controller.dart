import 'package:cu_se_form_server_dart/main/model/application_form_model.dart';
import 'package:cu_se_form_server_dart/helper/controller_helper.dart';
import 'package:cu_se_form_server_dart/setting/mongodb.dart';
import 'package:cu_se_form_server_dart/setting/token_setting.dart';
import 'package:cu_se_form_share_dart/object/application_form_object.dart';
import 'package:cu_se_form_share_dart/object/token_object.dart';
import 'package:cu_se_form_share_dart/object/api_object.dart';
import 'package:cu_se_form_share_dart/main/request_validation/save_application_form_request_validation.dart';

class SaveApplicationFormController {
  SaveApplicationFormController({required ApiObject api}) : _api = api;

  final ApiObject _api;
  final _mongodb = Mongodb();

  //request
  final _tokenRequest = TokenObject();
  final _applicationFormRequest = ApplicationFormObject();

  //response
  final response = ControllerHelper();

  Future<bool> receiveRequest() async {
    final jwt = _api.jwt;
    final applicationFormMap = _api.data?['applicationForm'];
    if (jwt is! String) return response.failed('ข้อมูล Token ไม่ถูกต้อง');
    if (applicationFormMap is! Map<String, dynamic>) response.failed('ข้อมูลใบสมัครไม่ถูกต้อง');

    _tokenRequest.jwt = jwt;
    _applicationFormRequest.map = applicationFormMap;
    if (!_applicationFormRequest.toObject()) return response.failed('แปลงข้อมูลใบสมัครไม่สำเร็จ');
    return true;
  }

  Future<bool> validateRequest() async {
    if (!_tokenRequest.decode(secretKey: TokenSetting.accessTokenSecretKey)) return response.failed('ข้อมูลโทเค็นไม่ถูกต้อง กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
    if (_tokenRequest.isExpired) return response.failed('โทเค็นหมดอายุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
    if (response.isFailed(() => saveApplicationFormRequestValidation(applicationForm: _applicationFormRequest))) return false;
    return true;
  }

  Future<bool> replaceApplicationForm() async {
    _applicationFormRequest.userId = _tokenRequest.userId!;
    _applicationFormRequest.toMap();
    await _mongodb.openDb();
    final isReplaced = await ApplicationFormModel.replaceOneByUserId(_mongodb, userId: _tokenRequest.userId!, map: _applicationFormRequest.map!);
    await _mongodb.closeDb();
    if (!isReplaced) return response.failed('บันทึกข้อมูลไม่สำเร็จ'); //worst case
    return true;
  }
}
