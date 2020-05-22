import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

import '../../src/data/version1/SessionV1.dart';
import '../../src/persistence/ISessionsPersistence.dart';
import './ISessionsController.dart';
import './SessionsCommandSet.dart';

class SessionsController
    implements
        ISessionsController,
        IConfigurable,
        IReferenceable,
        ICommandable,
        IOpenable {
  static final ConfigParams _defaultConfig = ConfigParams.fromTuples([
    'dependencies.persistence',
    'pip-services-sessions:persistence:*:*:1.0',
    'options.cleanup_interval',
    900000,
    'options.expire_timeout',
    24 * 3600000
  ]);
  ISessionsPersistence persistence;
  SessionsCommandSet commandSet;
  DependencyResolver dependencyResolver =
      DependencyResolver(SessionsController._defaultConfig);
  final CompositeLogger _logger = CompositeLogger();

  num _expireTimeout = 24 * 3600000;
  num _cleanupInterval = 900000;
  FixedRateTimer _cleanupTimer;

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    dependencyResolver.configure(config);

    _expireTimeout =
        config.getAsLongWithDefault('options.expire_timeout', _expireTimeout);
    _cleanupInterval = config.getAsLongWithDefault(
        'options.cleanup_interval', _cleanupInterval);

    _logger.configure(config);
  }

  /// Set references to component.
  ///
  /// - [references]    references parameters to be set.
  @override
  void setReferences(IReferences references) {
    _logger.setReferences(references);
    dependencyResolver.setReferences(references);
    persistence =
        dependencyResolver.getOneRequired<ISessionsPersistence>('persistence');
  }

  /// Gets a command set.
  ///
  /// Return Command set
  @override
  CommandSet getCommandSet() {
    commandSet ??= SessionsCommandSet(this);
    return commandSet;
  }

  /// Сhecks if the session is open
  ///
  /// Return bool checking result
  @override
  bool isOpen() {
    return _cleanupTimer != null;
  }

  /// Opens the session.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			    Future that receives error or null no errors occured.
  @override
  Future open(String correlationId) async {
    if (isOpen()) {
      return Future.delayed(Duration(), () {
        _cleanupTimer = FixedRateTimer(() {
          _logger.info(correlationId, 'Closing expired user sessions');
          closeExpiredSessions(correlationId);
        }, _cleanupInterval);
        _cleanupTimer.start();
      });
    }
  }

  /// Closes session and frees used resources.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			  Future that receives error or null no errors occured.
  @override
  Future close(String correlationId) async {
    if (_cleanupTimer != null) {
      var result = await _cleanupTimer.close(correlationId);
      _cleanupTimer = null;
      Future.delayed(Duration(), () {
        return result;
      });
    }
  }

  /// Gets a page of sessions retrieved by a given filter.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [filter]            (optional) a filter function to filter items
  /// - [paging]            (optional) paging parameters
  /// Return         Future that receives a data page
  /// Throws error.
  @override
  Future<DataPage<SessionV1>> getSessions(
      String correlationId, FilterParams filter, PagingParams paging) {
    return persistence.getPageByFilter(correlationId, filter, paging);
  }

  /// Gets an session by its unique id.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [id]                an id of session to be retrieved.
  /// Return         Future that receives session or error.
  @override
  Future<SessionV1> getSessionById(String correlationId, String id) {
    return persistence.getOneById(correlationId, id);
  }

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
  @override
  Future<SessionV1> openSession(String correlationId, String user_id,
      String user_name, String address, String client, user, data) {
    var session = SessionV1(
        id: IdGenerator.nextLong(),
        user_id: user_id,
        user_name: user_name,
        address: address,
        client: client);
    session.user = user;
    session.data = data;
    return persistence.create(correlationId, session);
  }

  /// Updates a session's data.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [data]              an data to be updated.
  /// Return         (optional) Future that receives updated session
  /// Throws error.
  @override
  Future<SessionV1> storeSessionData(
      String correlationId, String sessionId, data) {
    return persistence.updatePartially(correlationId, sessionId,
        AnyValueMap.fromValue({'request_time': DateTime.now(), 'data': data}));
  }

  /// Updates a session's user.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [user]              an user to be updated.
  /// Return         (optional) Future that receives updated session
  /// Throws error.
  @override
  Future<SessionV1> updateSessionUser(
      String correlationId, String sessionId, user) {
    return persistence.updatePartially(correlationId, sessionId,
        AnyValueMap.fromValue({'request_time': DateTime.now(), 'user': user}));
  }

  /// Close a session by it's id.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [sessionId]                an id of the session to be closed
  /// Return                Future that receives closed session
  /// Throws error.
  @override
  Future<SessionV1> closeSession(String correlationId, String sessionId) {
    return persistence.updatePartially(
        correlationId,
        sessionId,
        AnyValueMap.fromValue({
          'active': false,
          'request_time': DateTime.now(),
          'close_time': DateTime.now(),
          'data': null,
          'user': null
        }));
  }

  /// Close an expired sessions.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// Return                Future that receives null for success
  /// Throws error.
  @override
  Future closeExpiredSessions(String correlationId) {
    var now = DateTime.now().millisecondsSinceEpoch;
    var diff = now - _expireTimeout;
    var requestTime = DateTime.fromMillisecondsSinceEpoch(diff);
    return persistence.closeExpired(correlationId, requestTime);
  }

  /// Deleted an session by it's unique id.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [sessionId]                an id of the session to be deleted
  /// Return                Future that receives deleted session
  /// Throws error.
  @override
  Future<SessionV1> deleteSessionById(String correlationId, String sessionId) {
    return persistence.deleteById(correlationId, sessionId);
  }
}
