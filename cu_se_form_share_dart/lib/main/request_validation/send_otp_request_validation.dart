import 'package:cu_se_form_share_dart/object/otp_object.dart';
import 'package:cu_se_form_share_dart/utility/is_email.dart';

String? sendOtpRequestValidation({required OtpObject otp}) {
  if (!isEmail(otp.email)) return 'กรุณาเพิ่มข้อมูลอีเมลให้ถูกต้อง';
  return null;
}
