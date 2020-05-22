import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../../src/logic/ISessionsController.dart';

class SessionsCommandSet extends CommandSet {
  ISessionsController _controller;

  SessionsCommandSet(ISessionsController controller) : super() {
    _controller = controller;

    addCommand(_makeGetSessionsCommand());
    addCommand(_makeGetSessionByIdCommand());
    addCommand(_makeOpenSessionCommand());
    addCommand(_makeStoreSessionDataCommand());
    addCommand(_makeUpdateSessionUserCommand());
    addCommand(_makeCloseSessionCommand());
    addCommand(_makeCloseExpiredSessionsCommand());
    addCommand(_makeDeleteSessionByIdCommand());
  }

  ICommand _makeGetSessionsCommand() {
    return Command(
        'get_sessions',
        ObjectSchema(true)
            .withOptionalProperty('filter', FilterParamsSchema())
            .withOptionalProperty('paging', PagingParamsSchema()),
        (String correlationId, Parameters args) {
      var filter = FilterParams.fromValue(args.get('filter'));
      var paging = PagingParams.fromValue(args.get('paging'));
      return _controller.getSessions(correlationId, filter, paging);
    });
  }

  ICommand _makeGetSessionByIdCommand() {
    return Command('get_session_by_id',
        ObjectSchema(true).withRequiredProperty('session_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var sessionId = args.getAsString('session_id');
      return _controller.getSessionById(correlationId, sessionId);
    });
  }

  ICommand _makeOpenSessionCommand() {
    return Command(
        'open_session',
        ObjectSchema(true)
            .withRequiredProperty('user_id', TypeCode.String)
            .withOptionalProperty('user_name', TypeCode.String)
            .withOptionalProperty('address', TypeCode.String)
            .withOptionalProperty('client', TypeCode.String)
            .withOptionalProperty('user', null)
            .withOptionalProperty('data', null),
        (String correlationId, Parameters args) {
      var userId = args.getAsNullableString('user_id');
      var userName = args.getAsNullableString('user_name');
      var address = args.getAsNullableString('address');
      var client = args.getAsNullableString('client');
      var user = args.get('user');
      var data = args.get('data');
      return _controller.openSession(
          correlationId, userId, userName, address, client, user, data);
    });
  }

  ICommand _makeStoreSessionDataCommand() {
    return Command(
        'store_session_data',
        ObjectSchema(true)
            .withRequiredProperty('session_id', TypeCode.String)
            .withRequiredProperty('data', null),
        (String correlationId, Parameters args) {
      var sessionId = args.getAsNullableString('session_id');
      var data = args.get('data');
      return _controller.storeSessionData(correlationId, sessionId, data);
    });
  }

  ICommand _makeUpdateSessionUserCommand() {
    return Command(
        'update_session_user',
        ObjectSchema(true)
            .withRequiredProperty('session_id', TypeCode.String)
            .withRequiredProperty('user', null),
        (String correlationId, Parameters args) {
      var sessionId = args.getAsNullableString('session_id');
      var user = args.get('user');
      return _controller.updateSessionUser(correlationId, sessionId, user);
    });
  }

  ICommand _makeCloseSessionCommand() {
    return Command('close_session',
        ObjectSchema(true).withRequiredProperty('session_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var sessionId = args.getAsNullableString('session_id');
      return _controller.closeSession(correlationId, sessionId);
    });
  }

  ICommand _makeCloseExpiredSessionsCommand() {
    return Command('close_expired_sessions', ObjectSchema(true),
        (String correlationId, Parameters args) {
      return _controller.closeExpiredSessions(correlationId);
    });
  }

  ICommand _makeDeleteSessionByIdCommand() {
    return Command('delete_session_by_id',
        ObjectSchema(true).withRequiredProperty('session_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var sessionId = args.getAsString('session_id');
      return _controller.deleteSessionById(correlationId, sessionId);
    });
  }
}
