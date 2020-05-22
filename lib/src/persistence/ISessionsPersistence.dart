import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../data/version1/SessionV1.dart';

abstract class ISessionsPersistence {
  Future<DataPage<SessionV1>> getPageByFilter(
      String correlationId, FilterParams filter, PagingParams paging);

  Future<SessionV1> getOneById(String correlationId, String id);

  Future<SessionV1> create(String correlationId, SessionV1 item);

  Future<SessionV1> update(String correlationId, SessionV1 item);

  Future<SessionV1> updatePartially(
      String correlationId, String id, AnyValueMap data);

  Future<SessionV1> deleteById(String correlationId, String id);

  Future closeExpired(String correlationId, DateTime request_time);
}
