import 'package:mongo_dart/mongo_dart.dart';
import 'package:cu_se_form_server_dart/setting/mongodb.dart';
import 'package:cu_se_form_share_dart/object/key/user_key.dart';

class UserModel {
  static Future<ObjectId?> insertOne(Mongodb mongodb, {required Map<String, dynamic> map}) async {
    final writeResult = await mongodb.userCollection.insertOne(map);
    if (!writeResult.isSuccess || writeResult.nInserted != 1 || writeResult.id is! ObjectId) return null;
    return writeResult.id;
  }

  static Future<Map<String, dynamic>?> findOneById(Mongodb mongodb, {required ObjectId id}) async {
    return await mongodb.userCollection.findOne(where.id(id));
  }

  static Future<Map<String, dynamic>?> findOneByEmail(Mongodb mongodb, {required String email}) async {
    return await mongodb.userCollection.findOne(where.eq(UserKey.email, email));
  }

  static Future<bool> removeOne(Mongodb mongodb, {required ObjectId id}) async {
    final writeResult = await mongodb.userCollection.deleteOne(where.id(id));
    return writeResult.isSuccess && writeResult.nRemoved == 1;
  }

  static Future<bool> updateJwt(Mongodb mongodb, {required ObjectId id, required String refreshJwt, required String accessJwt}) async {
    final writeResult = await mongodb.userCollection.updateOne(where.id(id), modify.set(UserKey.refreshJwt, refreshJwt).set(UserKey.accessJwt, accessJwt));
    return writeResult.isSuccess && writeResult.nModified == 1;
  }
}
