import 'dart:io';
import 'package:cu_se_form_server_dart/main/controller/send_otp_controller.dart';
import 'package:cu_se_form_server_dart/utility/generate_respone.dart';
import 'package:cu_se_form_share_dart/object/api_object.dart';
import 'package:cu_se_form_share_dart/utility/my_alert_message.dart';
import 'package:shelf/shelf.dart';

Future<Response> sendOtpApi(ApiObject? api) async {
  if (api == null) return generateResponse(message: 'ข้อมูลที่ได้รับไม่ถูกต้อง');
  final controller = SendOtpController(api: api);
  try {
    if (!await controller.receiveRequest()) return generateResponse(message: controller.response.message);
    if (!await controller.validateRequest()) return generateResponse(message: controller.response.message);
    if (!await controller.insertOtp()) return generateResponse(httpStatus: HttpStatus.internalServerError, message: controller.response.message);
    if (!await controller.sendOtpByEmail()) {
      if (!await controller.cancelInsertOtp()) return generateResponse(httpStatus: HttpStatus.internalServerError, message: 'เพิ่มข้อมูล OTP ลงในระบบแล้ว แต่ส่งอีเมลไม่สำเร็จ กรุณาตรวจสอบอีเมล'); //worst case
      return generateResponse(httpStatus: HttpStatus.internalServerError, message: controller.response.message);
    }
    return generateResponse(httpStatus: HttpStatus.ok, isSuccess: true, data: {'otpRef': controller.otpRefResponse}, message: 'ระบบได้ส่งรหัส OTP ไปยังอีเมลดังกล่าวแล้ว หากไม่ได้รับอีเมลกรุณาตรวจสอบอีเมลและลองใหม่อีกครั้ง');
  } catch (e) {
    return generateResponse(httpStatus: HttpStatus.internalServerError, message: '$e (${MyAlertMessage.reportIssue})');
  }
}
