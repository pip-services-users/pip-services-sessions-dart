import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_data/pip_services3_data.dart';
import '../../pip_services_sessions.dart';
import '../data/version1/SessionV1.dart';
import './ISessionsPersistence.dart';

class SessionsMemoryPersistence
    extends IdentifiableMemoryPersistence<SessionV1, String>
    implements ISessionsPersistence {
  SessionsMemoryPersistence() : super() {
    maxPageSize = 1000;
  }

  Function composeFilter(FilterParams filter) {
    filter = filter ?? FilterParams();

    var id = filter.getAsNullableString('id');
    var userId = filter.getAsNullableString('user_id');
    var active = filter.getAsNullableBoolean('active');
    var fromTime = filter.getAsNullableDateTime('from_time');
    var toTime = filter.getAsNullableDateTime('to_time');

    return (item) {
      if (id != null && item.id != id) {
        return false;
      }
      if (userId != null && item.user_id != userId) {
        return false;
      }
      if (active != null && item.active != active) {
        return false;
      }
      if (fromTime != null && item.request_time >= fromTime) {
        return false;
      }
      if (toTime != null && item.request_time < toTime) {
        return false;
      }
      return true;
    };
  }

  @override
  Future<DataPage<SessionV1>> getPageByFilter(
      String correlationId, FilterParams filter, PagingParams paging) async {
    var page = await super
        .getPageByFilterEx(correlationId, composeFilter(filter), paging, null);
    // Remove cached data
    var removed = page.data.map((s) {
      var map = s.toJson();
      map.remove('data');
      map.remove('user');
      return map;
    });
    var sessions = removed.map((e) {
      var session = SessionV1();
      session.fromJson(e);
      return session;
    });

    return DataPage(sessions.toList(), sessions.length);
  }

  @override
  Future<SessionV1> create(String correlationId, SessionV1 item) {
    if (item == null) {
      return null;
    }

    var now = DateTime.now();
    item.open_time = now;
    item.request_time = now;

    return super.create(correlationId, item);
  }

  @override
  Future closeExpired(String correlationId, DateTime request_time) async {
    var time = request_time.millisecondsSinceEpoch;
    var now = DateTime.now();
    var count = 0;

    for (var item in items) {
      if (item.active && item.request_time.millisecondsSinceEpoch < time) {
        item.active = false;
        item.close_time = now;
        item.request_time = now;
        item.data = null;
        item.user = null;

        count++;
      }
    }

    if (count > 0) {
      logger.debug(correlationId, 'Closed %d expired sessions', [count]);

      await save(correlationId);
    } else {
      return null;
    }
  }
}
