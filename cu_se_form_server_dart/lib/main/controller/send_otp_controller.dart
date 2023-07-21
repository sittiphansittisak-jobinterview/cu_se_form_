import 'package:cu_se_form_server_dart/helper/controller_helper.dart';
import 'package:cu_se_form_server_dart/main/model/otp_model.dart';
import 'package:cu_se_form_server_dart/setting/mongodb.dart';
import 'package:cu_se_form_server_dart/utility/send_email.dart';
import 'package:cu_se_form_share_dart/object/api_object.dart';
import 'package:cu_se_form_share_dart/utility/thai_date_time.dart';
import 'package:cu_se_form_share_dart/object/otp_object.dart';
import 'package:cu_se_form_share_dart/main/request_validation/send_otp_request_validation.dart';

class SendOtpController {
  SendOtpController({required ApiObject api}) : _api = api;

  final ApiObject _api;
  final _mongodb = Mongodb();
  final _delayBeforeExpire = 5;

  //request
  final _otpRequest = OtpObject();

  //response
  final response = ControllerHelper();
  String? otpRefResponse;

  Future<bool> receiveRequest() async {
    final otpMap = _api.data?['otp'];
    if (otpMap is! Map<String, dynamic>) return response.failed('ข้อมูล OTP ไม่ถูกต้อง');

    _otpRequest.map = otpMap;
    if (!_otpRequest.toObject()) return response.failed('แปลงข้อมูล OTP ไม่สำเร็จ');
    return true;
  }

  Future<bool> validateRequest() async {
    if (response.isFailed(() => sendOtpRequestValidation(otp: _otpRequest))) return false;
    final beforeExpireOneMin = DateTime.now().toUtc().subtract(Duration(minutes: 1));
    final otpLimitPerOneMin = 5;
    await _mongodb.openDb();
    final int countInHalfDay = await OtpModel.countOtpCreatedBeforeThis(_mongodb, email: _otpRequest.email!, createAt: beforeExpireOneMin);
    await _mongodb.closeDb();
    if (countInHalfDay >= otpLimitPerOneMin) return response.failed('มีการขอส่ง OTP มากเกินไป โปรดรอสักครู่แล้วลองอีกครั้ง'); //prevent spammer
    return true;
  }

  Future<bool> insertOtp() async {
    final now = DateTime.now().toUtc();
    _otpRequest.createAt = now;
    _otpRequest.expireAt = now.add(Duration(minutes: _delayBeforeExpire));
    _otpRequest.isUsed = false;
    otpRefResponse = (_otpRequest..generateOtpRef()).otpRef;
    _otpRequest.generateOtpValue();
    _otpRequest.toMap();
    await _mongodb.openDb();
    _otpRequest.id = await OtpModel.insertOne(_mongodb, map: _otpRequest.map!);
    await _mongodb.closeDb();
    if (_otpRequest.id == null) return response.failed('เกิดข้อผิดพลาดระหว่างบันทึก OTP');
    return true;
  }

  Future<bool> sendOtpByEmail() async {
    final subject = 'รหัส OTP';
    final body = 'รหัสอ้างอิง: ${_otpRequest.otpRef}'
        '\nรหัส OTP: ${_otpRequest.otpValue}'
        '\nรหัสจะหมดอายุเมื่อ ${thaiDateTime(_otpRequest.expireAt) ?? '-'} (มีอายุการใช้งาน $_delayBeforeExpire นาที)';
    if (!await sendEmail(emailTarget: _otpRequest.email, subject: subject, body: body)) return response.failed('ส่งอีเมลไม่สำเร็จ');
    return true;
  }

  //cancel

  Future<bool> cancelInsertOtp() async {
    await _mongodb.openDb();
    if (!await OtpModel.removeOne(_mongodb, id: _otpRequest.id!)) return false;
    await _mongodb.closeDb();
    return true;
  }
}
