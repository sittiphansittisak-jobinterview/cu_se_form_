import 'package:cu_se_form_share_dart/object/application_form_object.dart';
import 'package:cu_se_form_share_dart/utility/is_string_empty.dart';

String? saveApplicationFormRequestValidation({required ApplicationFormObject applicationForm}) {
  if (isStringEmpty(applicationForm.name)) return 'กรุณาเพิ่มข้อมูลชื่อในแบบฟอร์ม';
  if (isStringEmpty(applicationForm.surname)) return 'กรุณาเพิ่มข้อมูลนามสกุุลในแบบฟอร์ม';
  if (isStringEmpty(applicationForm.studyType)) return 'กรุณาเพิ่มข้อมูลภาคเรียนในแบบฟอร์ม';
  if (isStringEmpty(applicationForm.studyPlan)) return 'กรุณาเพิ่มข้อมูลแผนการเรียนในแบบฟอร์ม';
  if (applicationForm.hasPublishedPaper == true && (applicationForm.researchExperienceList ?? []).isEmpty) return 'หากเคยตีพิมพ์บทความวิชาการ กรุณาเพิ่มข้อมูลรายชื่อบทความและแหล่งตีพิมพ์อย่างน้อย 1 รายการ';
  if (applicationForm.hasPublishedPaper == null) return 'กรุณาเพิ่มข้อมูลว่าเคยตีพิมพ์บทความวิชาการหรือไม่ในแบบฟอร์ม';
  if (isStringEmpty(applicationForm.researchInterests)) return 'กรุณาเพิ่มข้อมูลด้านที่อยากทำวิทยานิพนธ์/โครงงานมหาบัณฑิตในแบบฟอร์ม';
  if ([applicationForm.proposedResearchMethodologyList ?? []].isEmpty) return 'กรุณาเพิ่มข้อมูลหัวข้อวิทยานิพนธ์/โครงงานมหาบัณฑิตที่ต้องการทำอย่างน้อย 1 รายการในแบบฟอร์ม';
  for (final proposedResearchMethodology in applicationForm.proposedResearchMethodologyList!) {
    if (isStringEmpty(proposedResearchMethodology)) return 'กรุณาเพิ่มข้อมูลรายละเอียดของหัวข้อวิทยานิพนธ์/โครงงานมหาบัณฑิตที่ต้องการทำในแบบฟอร์ม';
  }
  return null;
}
