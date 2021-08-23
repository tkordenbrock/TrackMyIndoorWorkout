import 'fault.dart';

class UnderArmourToken {
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  int? expiresAt;
  String? scope;

  UnderArmourToken({this.accessToken, this.refreshToken, this.expiresAt, this.scope});

  factory UnderArmourToken.fromJson(Map<String, dynamic> json) => UnderArmourToken.fromMap(json);

  Map toMap() => UnderArmourToken.toJsonMap(this);

  @override
  String toString() => UnderArmourToken.toJsonMap(this).toString();

  static Map toJsonMap(UnderArmourToken model) {
    return {
      'access_token': model.accessToken ?? 'Error',
      'token_type': model.tokenType ?? 'Error',
      'refresh_token': model.refreshToken ?? 'Error',
      'expires_at': model.expiresAt ?? 'Error',
    };
  }

  static UnderArmourToken fromMap(Map<String, dynamic> map) {
    return UnderArmourToken()
      ..accessToken = map['access_token']
      ..refreshToken = map['refresh_token']
      ..tokenType = map['token_type']
      ..expiresAt = map['expires_at'];
  }

  /// Generate the header to use with http requests
  ///
  /// return {null, null} if there is not token yet
  /// stored in globals
  Map<String, String> getAuthorizationHeader(String clientId) {
    if (accessToken != null && accessToken!.length > 0 && accessToken != "Error") {
      return {
        'Authorization': 'Bearer $accessToken',
        'Api-Key': clientId,
      };
    } else {
      return {'88': '00'};
    }
  }
}

class RefreshAnswer {
  Fault? fault;
  String? accessToken;
  String? refreshToken;
  int? expiresAt;

  RefreshAnswer();

  factory RefreshAnswer.fromJson(Map<String, dynamic> json) => RefreshAnswer.fromMap(json);

  static RefreshAnswer fromMap(Map<String, dynamic> map) {
    RefreshAnswer model = RefreshAnswer()
      ..accessToken = map['access_token']
      ..refreshToken = map['refresh_token']
      ..expiresAt = map['expires_at'];

    return model;
  }
}
