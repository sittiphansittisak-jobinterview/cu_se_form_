import 'package:cu_se_form_server_dart/main/model/otp_model.dart';
import 'package:cu_se_form_server_dart/main/model/user_model.dart';
import 'package:cu_se_form_server_dart/helper/controller_helper.dart';
import 'package:cu_se_form_server_dart/setting/mongodb.dart';
import 'package:cu_se_form_server_dart/setting/token_setting.dart';
import 'package:cu_se_form_server_dart/utility/send_email.dart';
import 'package:cu_se_form_share_dart/object/token_object.dart';
import 'package:cu_se_form_share_dart/object/user_object.dart';
import 'package:cu_se_form_share_dart/object/api_object.dart';
import 'package:cu_se_form_share_dart/main/request_validation/sign_in_request_validation.dart';
import 'package:cu_se_form_share_dart/utility/my_alert_message.dart';
import 'package:cu_se_form_share_dart/utility/thai_date_time.dart';
import 'package:cu_se_form_share_dart/object/otp_object.dart';

class SignInController {
  SignInController({required ApiObject api}) : _api = api;

  final ApiObject _api;
  final _mongodb = Mongodb();

  //request
  final _otpRequest = OtpObject();

  //response
  final response = ControllerHelper();
  final userResponse = UserObject();

  Future<bool> receiveRequest() async {
    final otpMap = _api.data?['otp'];
    if (otpMap is! Map<String, dynamic>) return response.failed('ข้อมูล OTP ไม่ถูกต้อง');

    _otpRequest.map = otpMap;
    if (!_otpRequest.toObject()) return response.failed('แปลงข้อมูล OTP ไม่สำเร็จ');
    return true;
  }

  Future<bool> validateRequest() async {
    if (response.isFailed(() => signInRequestValidation(otp: _otpRequest))) return false;
    return true;
  }

  Future<bool> validateOtp() async {
    await _mongodb.openDb();
    final isUpdated = await OtpModel.updateToUseOtp(_mongodb, note: 'ใช้ลงชื่อเข้าสู่ระบบ', email: _otpRequest.email!, otpRef: _otpRequest.otpRef!, otpValue: _otpRequest.otpValue!, expireAt: DateTime.now().toUtc());
    await _mongodb.closeDb();
    if (!isUpdated) return response.failed('OTP ไม่ถูกต้องหรือถูกใช้/หมดอายุแล้ว');
    return true;
  }

  Future<bool> findUser() async {
    await _mongodb.openDb();
    userResponse.map = await UserModel.findOneByEmail(_mongodb, email: _otpRequest.email!);
    await _mongodb.closeDb();
    if (userResponse.map == null) return response.failed('ไม่พบข้อมูลบัญชีผู้ใช้');
    userResponse.toObject();
    return true;
  }

  Future<bool> insertUser() async {
    userResponse.createAt = DateTime.now().toUtc();
    userResponse.email = _otpRequest.email;
    userResponse.toMap();
    await _mongodb.openDb();
    userResponse.id = await UserModel.insertOne(_mongodb, map: userResponse.map!);
    if (userResponse.id == null) return response.failed('เกิดข้อผิดพลาดระหว่างเพิ่มข้อมูลบัญชีผู้ใช้หรือมีข้อมูลในระบบแล้ว (${MyAlertMessage.reportIssue})'); //worst case
    await _mongodb.closeDb();
    return true;
  }

  Future<bool> updateToken() async {
    final refreshToken = TokenObject(userId: userResponse.id);
    final accessToken = TokenObject(userId: userResponse.id);
    if (!refreshToken.encode(secretKey: TokenSetting.refreshTokenSecretKey, expireTime: TokenSetting.refreshTokenExpireTime) || !accessToken.encode(secretKey: TokenSetting.accessTokenSecretKey, expireTime: TokenSetting.accessTokenExpireTime)) return response.failed('เกิดข้อผิดพลาดระหว่างสร้างโทเค็น');
    userResponse.refreshJwt = refreshToken.jwt;
    userResponse.accessJwt = accessToken.jwt;

    await _mongodb.openDb();
    final isUpdated = await UserModel.updateJwt(_mongodb, id: userResponse.id!, refreshJwt: userResponse.refreshJwt!, accessJwt: userResponse.accessJwt!);
    await _mongodb.closeDb();
    if (!isUpdated) return response.failed('เกิดข้อผิดพลาดระหว่างอัพเดทโทเค็นหรือไม่พบข้อมูลบัญชีผู้ใช้');
    return true;
  }

  Future<bool> sendEmailToNewUser() async {
    final subject = 'สมาชิกใหม่';
    final body = 'ยินดีต้อนรับสมาชิกใหม่เข้าสู่ CU SE form'
        '\nเราพบว่าคุณพึ่งเข้าร่วม CU SE form เมื่อ ${thaiDateTime(userResponse.createAt) ?? '-'}'
        '\n\n*****หากนี่ไม่ใช่คุณ ${MyAlertMessage.reportIssue}*****';
    if (!await sendEmail(emailTarget: _otpRequest.email, subject: subject, body: body)) return response.failed('ส่งอีเมลแจ้งการเป็นสมาชิกใหม่ไม่สำเร็จ/อีเมลผู้ใช้ไม่ถูกต้อง');
    return true;
  }

  //cancel
  Future<bool> cancelInsertUser() async {
    await _mongodb.openDb();
    if (!await UserModel.removeOne(_mongodb, id: userResponse.id!)) return false;
    await _mongodb.closeDb();
    return true;
  }
}
