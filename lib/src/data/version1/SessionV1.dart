import 'package:pip_services3_commons/pip_services3_commons.dart';

class SessionV1 implements IStringIdentifiable {
  @override
  /* Identification */
  String id;
  String user_id;
  String user_name;

  /* Session info */
  bool active;
  DateTime open_time;
  DateTime close_time;
  DateTime request_time;
  String address;
  String client;

  /* Cached content */
  var user;
  var data;

  SessionV1(
      {String id,
      String user_id,
      String user_name,
      bool active,
      DateTime open_time,
      DateTime close_time,
      DateTime request_time,
      String address,
      String client,
      var user,
      var data})
      : id = id ?? IdGenerator.nextLong(),
        user_id = user_id,
        user_name = user_name,
        active = active,
        open_time = open_time ?? DateTime.now(),
        close_time = close_time,
        request_time = request_time ?? DateTime.now(),
        address = address,
        client = client,
        user = user,
        data = data;

  void fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user_id = json['user_id'];
    user_name = json['user_name'];
    active = json['active'];
    var open_time_json = json['open_time'];
    var close_time_json = json['close_time'];
    var request_time_json = json['request_time'];
    open_time =
        open_time_json != null ? DateTime.tryParse(open_time_json) : null;
    close_time =
        close_time_json != null ? DateTime.tryParse(close_time_json) : null;
    request_time =
        request_time_json != null ? DateTime.tryParse(request_time_json) : null;
    address = json['address'];
    client = json['client'];
    user = json['user'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': user_id,
      'user_name': user_name,
      'active': active,
      'open_time': open_time != null ? open_time.toIso8601String() : open_time,
      'close_time':
          close_time != null ? close_time.toIso8601String() : close_time,
      'request_time':
          request_time != null ? request_time.toIso8601String() : request_time,
      'address': address,
      'client': client,
      'user': user,
      'data': data
    };
  }
}
