import 'package:cu_se_form_share_dart/object/otp_object.dart';
import 'package:cu_se_form_share_dart/utility/is_email.dart';

String? signInRequestValidation({required OtpObject otp}) {
  if (!isEmail(otp.email)) return 'กรุณาเพิ่มข้อมูลอีเมลของข้อมูล OTP ให้ถูกต้อง';
  if (!otp.isOtpValueCorrect) return 'กรุณาเพิ่มข้อมูล OTP ให้ถูกต้อง (ได้จากการส่งรหัส OTP ไปที่อีเมล)';
    return null;
}
