import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../../src/data/version1/SessionV1.dart';

abstract class ISessionsController {
  /// Gets a page of sessions retrieved by a given filter.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [filter]            (optional) a filter function to filter items
  /// - [paging]            (optional) paging parameters
  /// Return         Future that receives a data page
  /// Throws error.
  Future<DataPage<SessionV1>> getSessions(
      String correlationId, FilterParams filter, PagingParams paging);

  /// Gets an session by its unique id.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [id]                an id of session to be retrieved.
  /// Return         Future that receives session or error.
  Future<SessionV1> getSessionById(String correlationId, String sessionId);

  /// Creates a new session.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [user_id]              an user id of created session.
  /// - [user_name]              an user name of created session.
  /// - [address]              an address of created session.
  /// - [client]              a client of created session.
  /// - [user]              an user of created session.
  /// - [data]              an data of created session.
  /// Return         (optional) Future that receives created session or error.
  Future<SessionV1> openSession(
      String correlationId,
      String user_id,
      String user_name,
      String address,
      String client,
      dynamic user,
      dynamic data);

  /// Updates a session's data.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [data]              an data to be updated.
  /// Return         (optional) Future that receives updated session
  /// Throws error.
  Future<SessionV1> storeSessionData(
      String correlationId, String sessionId, dynamic data);

  /// Updates a session's user.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [user]              an user to be updated.
  /// Return         (optional) Future that receives updated session
  /// Throws error.
  Future<SessionV1> updateSessionUser(
      String correlationId, String sessionId, dynamic user);

  /// Close a session by it's id.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [sessionId]                an id of the session to be closed
  /// Return                Future that receives closed session
  /// Throws error.
  Future<SessionV1> closeSession(String correlationId, String sessionId);

  /// Close an expired sessions.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// Return                Future that receives null for success
  /// Throws error.
  Future closeExpiredSessions(String correlationId);

  /// Deleted an session by it's unique id.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [sessionId]                an id of the session to be deleted
  /// Return                Future that receives deleted session
  /// Throws error.
  Future<SessionV1> deleteSessionById(String correlationId, String sessionId);
}
