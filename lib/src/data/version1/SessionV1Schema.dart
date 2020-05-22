import 'package:pip_services3_commons/pip_services3_commons.dart';

class SessionV1Schema extends ObjectSchema {
  SessionV1Schema() : super() {
    withOptionalProperty('id', TypeCode.String);
    withRequiredProperty('user_id', TypeCode.String);
    withRequiredProperty('user_name', TypeCode.String);
    withOptionalProperty('active', TypeCode.Boolean);
    withOptionalProperty('open_time', TypeCode.DateTime);
    withOptionalProperty('close_time', TypeCode.DateTime);
    withOptionalProperty('request_time', TypeCode.DateTime);
    withOptionalProperty('address', TypeCode.String);
    withOptionalProperty('client', TypeCode.String);
    withOptionalProperty('user', null);
    withOptionalProperty('data', null);
  }
}
