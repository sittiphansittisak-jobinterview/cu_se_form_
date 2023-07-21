import 'dart:io';
import 'package:cu_se_form_server_dart/main/controller/save_application_form_controller.dart';
import 'package:cu_se_form_server_dart/utility/generate_respone.dart';
import 'package:cu_se_form_share_dart/object/api_object.dart';
import 'package:cu_se_form_share_dart/utility/my_alert_message.dart';
import 'package:shelf/shelf.dart';

Future<Response> saveApplicationFormApi(ApiObject? api) async {
  if (api == null) return generateResponse(message: 'ข้อมูลที่ได้รับไม่ถูกต้อง');
  final controller = SaveApplicationFormController(api: api);
  try {
    if (!await controller.receiveRequest()) return generateResponse(message: controller.response.message);
    if (!await controller.validateRequest()) return generateResponse(message: controller.response.message);
    if (!await controller.replaceApplicationForm()) return generateResponse(httpStatus: HttpStatus.internalServerError, message: controller.response.message);
    return generateResponse(httpStatus: HttpStatus.ok, isSuccess: true, message: 'บันทึกข้อมูลสำเร็จ');
  } catch (e) {
    return generateResponse(httpStatus: HttpStatus.internalServerError, message: '$e (${MyAlertMessage.reportIssue})');
  }
}
