import 'dart:io';
import 'package:cu_se_form_server_dart/main/controller/sign_in_controller.dart';
import 'package:cu_se_form_server_dart/utility/generate_respone.dart';
import 'package:cu_se_form_share_dart/object/api_object.dart';
import 'package:cu_se_form_share_dart/utility/my_alert_message.dart';
import 'package:shelf/shelf.dart';

Future<Response> signInApi(ApiObject? api) async {
  if (api == null) return generateResponse(message: 'ข้อมูลที่ได้รับไม่ถูกต้อง');
  final controller = SignInController(api: api);
  try {
    if (!await controller.receiveRequest()) return generateResponse(message: controller.response.message);
    if (!await controller.validateRequest()) return generateResponse(message: controller.response.message);
    if (!await controller.validateOtp()) return generateResponse(message: controller.response.message);
    final isNewUser = !await controller.findUser(); //false = new user
    if (isNewUser) {
      if (!await controller.insertUser()) return generateResponse(httpStatus: HttpStatus.internalServerError, message: controller.response.message);
    }
    if (!await controller.updateToken()) {
      if (!await controller.cancelInsertUser()) return generateResponse(httpStatus: HttpStatus.internalServerError, message: 'เพิ่มข้อมูลบัญชีของท่านลงในระบบแล้ว กรุณาเข้าสู่ระบบใหม่อีกครั้ง (${MyAlertMessage.reportIssue})'); //worst case
      return generateResponse(httpStatus: HttpStatus.internalServerError, message: controller.response.message);
    }
    if (isNewUser && !await controller.sendEmailToNewUser()) {
      if (!await controller.cancelInsertUser()) return generateResponse(httpStatus: HttpStatus.internalServerError, message: 'เพิ่มข้อมูลบัญชีของท่านลงในระบบแล้ว กรุณาเข้าสู่ระบบใหม่อีกครั้ง (${MyAlertMessage.reportIssue})'); //worst case
      return generateResponse(httpStatus: HttpStatus.internalServerError, message: controller.response.message);
    }
    return generateResponse(httpStatus: HttpStatus.ok, isSuccess: true, data: {'user': (controller.userResponse..toMap()).map});
  } catch (e) {
    return generateResponse(httpStatus: HttpStatus.internalServerError, message: '$e (${MyAlertMessage.reportIssue})');
  }
}
