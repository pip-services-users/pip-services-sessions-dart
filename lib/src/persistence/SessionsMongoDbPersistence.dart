import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_mongodb/pip_services3_mongodb.dart';

import '../data/version1/SessionV1.dart';
import './ISessionsPersistence.dart';

class SessionsMongoDbPersistence
    extends IdentifiableMongoDbPersistence<SessionV1, String>
    implements ISessionsPersistence {
  SessionsMongoDbPersistence() : super('sessions') {
    maxPageSize = 1000;
  }

  dynamic composeFilter(FilterParams filter) {
    filter = filter ?? FilterParams();

    var criteria = [];

    var id = filter.getAsNullableString('id');
    if (id != null) {
      criteria.add({'_id': id});
    }

    var userId = filter.getAsNullableString('user_id');
    if (userId != null) {
      criteria.add({'user_id': userId});
    }

    var active = filter.getAsNullableBoolean('active');
    if (active != null) {
      criteria.add({'active': active});
    }

    var fromTime = filter.getAsNullableDateTime('from_time');
    if (fromTime != null) {
      criteria.add({
        'request_time': {r'$gte': fromTime}
      });
    }

    var toTime = filter.getAsNullableDateTime('to_time');
    if (toTime != null) {
      criteria.add({
        'request_time': {r'$lt': toTime}
      });
    }

    return criteria.isNotEmpty ? {r'$and': criteria} : null;
  }

  @override
  Future<DataPage<SessionV1>> getPageByFilter(
      String correlationId, FilterParams filter, PagingParams paging) async {
    return super.getPageByFilterEx(correlationId, composeFilter(filter), paging,
        null); // sort '-request_time', { user: 0, data: 0 }
  }

  @override
  Future<SessionV1> create(String correlationId, SessionV1 item) async {
    if (item == null) {
      return null;
    }

    var now = DateTime.now();
    item.open_time = now;
    item.request_time = now;
    item.active = item.active ?? true;

    return super.create(correlationId, item);
  }

  @override
  Future<SessionV1> update(String correlationId, SessionV1 item) async {
    if (item == null) {
      return null;
    }

    var now = DateTime.now();
    item.request_time = now;
    item.active = item.active ?? true;

    return super.update(correlationId, item);
  }

  @override
  Future closeExpired(String correlationId, DateTime request_time) async {
    var criteria = {
      'request_time': {r'$lt': request_time},
      'active': true
    };
    var newItem = {
      r'$set': {
        'active': false,
        'request_time': DateTime.now(),
        'close_time': DateTime.now(),
        'user': null,
        'data': null
      }
    };

    var result = await collection.update(criteria, newItem, multiUpdate: true);
    if (result != null && result['ok'] == 1.0) {
      logger.debug(correlationId, 'Closed %d expired sessions', []);
    }
  }
}
