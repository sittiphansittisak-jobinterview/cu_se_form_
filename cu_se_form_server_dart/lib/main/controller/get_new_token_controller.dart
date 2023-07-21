import 'package:cu_se_form_server_dart/helper/controller_helper.dart';
import 'package:cu_se_form_server_dart/main/model/user_model.dart';
import 'package:cu_se_form_server_dart/setting/mongodb.dart';
import 'package:cu_se_form_server_dart/setting/token_setting.dart';
import 'package:cu_se_form_share_dart/object/token_object.dart';
import 'package:cu_se_form_share_dart/object/user_object.dart';
import 'package:cu_se_form_share_dart/object/api_object.dart';
import 'package:cu_se_form_share_dart/utility/can_get_new_refresh_token.dart';

class GetNewTokenController {
  GetNewTokenController({required ApiObject api}) : _api = api;

  final ApiObject _api;
  final _mongodb = Mongodb();
  late final bool _canGetNewRefreshToken;
  final _user = UserObject();

  //request
  final _refreshJwtRequest = TokenObject();
  final _accessJwtRequest = TokenObject();

  //response
  final response = ControllerHelper();
  late final String refreshJwtResponse;
  late final String accessJwtResponse;

  Future<bool> receiveRequest() async {
    final refreshJwt = _api.data?['refreshJwt'];
    final accessJwt = _api.data?['accessJwt'];
    if (refreshJwt is! String) return response.failed('ข้อมูล refresh token ไม่ถูกต้อง');
    if (accessJwt is! String) return response.failed('ข้อมูล access token ไม่ถูกต้อง');

    _refreshJwtRequest.jwt = refreshJwt;
    _accessJwtRequest.jwt = accessJwt;
    return true;
  }

  Future<bool> validateRequest() async {
    if (!_refreshJwtRequest.decode(secretKey: TokenSetting.refreshTokenSecretKey)) return response.failed('ข้อมูล refresh token ไม่ถูกต้อง กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
    if (!_accessJwtRequest.decode(secretKey: TokenSetting.accessTokenSecretKey)) return response.failed('ข้อมูล access token ไม่ถูกต้อง กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
    if (_refreshJwtRequest.isExpired) return response.failed('refresh token หมดอายุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
    _canGetNewRefreshToken = canGetNewRefreshToken(_refreshJwtRequest.expireAt, isServer: true);
    if (!_canGetNewRefreshToken && !_accessJwtRequest.isExpired) return response.failed('token ยังสามารถใช้งานได้'); //prevent spam request
    if (_refreshJwtRequest.userId != _accessJwtRequest.userId) return response.failed('ข้อมูล token ผิดปกติ กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
    return true;
  }

  Future<bool> findUser() async {
    await _mongodb.openDb();
    _user.map = await UserModel.findOneById(_mongodb, id: _refreshJwtRequest.userId!);
    await _mongodb.closeDb();
    if (_user.map == null) return response.failed('ไม่พบข้อมูลบัญชีผู้ใช้');
    if (!_user.toObject()) return response.failed('ข้อมูลบัญชีผู้ใช้ผิดปกติ กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
    if (_user.refreshJwt != _refreshJwtRequest.jwt || _user.accessJwt != _accessJwtRequest.jwt) return response.failed('ข้อมูล token ไม่ตรงกัน กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
    return true;
  }

  Future<bool> updateToken() async {
    final refreshToken = TokenObject(userId: _refreshJwtRequest.userId);
    final accessToken = TokenObject(userId: _refreshJwtRequest.userId);
    if (_canGetNewRefreshToken && !refreshToken.encode(secretKey: TokenSetting.refreshTokenSecretKey, expireTime: TokenSetting.refreshTokenExpireTime)) return response.failed('เกิดข้อผิดพลาดระหว่างสร้าง refresh token');
    if (!accessToken.encode(secretKey: TokenSetting.accessTokenSecretKey, expireTime: TokenSetting.accessTokenExpireTime)) return response.failed('เกิดข้อผิดพลาดระหว่างสร้าง access token');
    refreshJwtResponse = refreshToken.jwt ?? _refreshJwtRequest.jwt!;
    accessJwtResponse = accessToken.jwt!;
    await _mongodb.openDb();
    final isUpdated = await UserModel.updateJwt(_mongodb, id: _refreshJwtRequest.userId!, refreshJwt: refreshJwtResponse, accessJwt: accessJwtResponse);
    await _mongodb.closeDb();
    if (!isUpdated) return response.failed('เกิดข้อผิดพลาดระหว่างอัพเดทโทเค็นหรือไม่พบข้อมูลบัญชีผู้ใช้');
    return true;
  }
}
