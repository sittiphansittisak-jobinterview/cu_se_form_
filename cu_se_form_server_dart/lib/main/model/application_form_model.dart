import 'package:mongo_dart/mongo_dart.dart';
import 'package:cu_se_form_server_dart/setting/mongodb.dart';
import 'package:cu_se_form_share_dart/object/key/application_form_key.dart';

class ApplicationFormModel {
  static Future<bool> replaceOneByUserId(Mongodb mongodb, {required ObjectId userId, required Map<String, dynamic> map}) async {
    final WriteResult writeResult = await mongodb.applicationFormCollection.replaceOne(where.eq(ApplicationFormKey.userId, userId), map, upsert: true);
    return writeResult.isSuccess && writeResult.nMatched == 1;
  }

  static Future<Map<String, dynamic>?> findOneByUserId(Mongodb mongodb, {required ObjectId userId}) async {
    return await mongodb.applicationFormCollection.findOne(where.eq(ApplicationFormKey.userId, userId));
  }
}
