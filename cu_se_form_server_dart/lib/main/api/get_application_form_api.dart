import 'dart:io';
import 'package:cu_se_form_server_dart/main/controller/get_application_form_controller.dart';
import 'package:cu_se_form_server_dart/utility/generate_respone.dart';
import 'package:cu_se_form_share_dart/object/key/application_form_key.dart';
import 'package:cu_se_form_share_dart/object/api_object.dart';
import 'package:cu_se_form_share_dart/utility/map_filter.dart';
import 'package:cu_se_form_share_dart/utility/my_alert_message.dart';
import 'package:shelf/shelf.dart';

Future<Response> getApplicationFormApi(ApiObject? api) async {
  if (api == null) return generateResponse(message: 'ข้อมูลที่ได้รับไม่ถูกต้อง');
  final controller = GetApplicationFormController(api: api);
  try {
    if (!await controller.receiveRequest()) return generateResponse(message: controller.response.message);
    if (!await controller.validateRequest()) return generateResponse(message: controller.response.message);
    if (!await controller.findApplicationForm()) return generateResponse(message: controller.response.message);
    controller.applicationFormResponse.map = mapFilter(controller.applicationFormResponse.map, removeKey: [ApplicationFormKey.id, ApplicationFormKey.userId]);
    return generateResponse(httpStatus: HttpStatus.ok, isSuccess: true, data: {'applicationForm': controller.applicationFormResponse.map});
  } catch (e) {
    return generateResponse(httpStatus: HttpStatus.internalServerError, message: '$e (${MyAlertMessage.reportIssue})');
  }
}
