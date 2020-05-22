import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services_sessions/pip_services_sessions.dart';

var httpConfig = ConfigParams.fromTuples([
  'connection.protocol',
  'http',
  'connection.host',
  'localhost',
  'connection.port',
  3000
]);

void main() {
  group('SessionsHttpServiceV1', () {
    SessionsMemoryPersistence persistence;
    SessionsController controller;
    SessionsHttpServiceV1 service;
    http.Client rest;
    String url;

    setUp(() async {
      url = 'http://localhost:3000';
      rest = http.Client();

      persistence = SessionsMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = SessionsController();
      controller.configure(ConfigParams());

      service = SessionsHttpServiceV1();
      service.configure(httpConfig);

      var references = References.fromTuples([
        Descriptor(
            'pip-services-sessions', 'persistence', 'memory', 'default', '1.0'),
        persistence,
        Descriptor(
            'pip-services-sessions', 'controller', 'default', 'default', '1.0'),
        controller,
        Descriptor(
            'pip-services-sessions', 'service', 'http', 'default', '1.0'),
        service
      ]);

      controller.setReferences(references);
      service.setReferences(references);

      await persistence.open(null);
      await service.open(null);
    });

    tearDown(() async {
      await service.close(null);
      await persistence.close(null);
    });

    test('Open Session', () async {
      SessionV1 session1;

      // Create a new session
      var resp = await rest.post(url + '/v1/sessions/open_session',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'user_id': '1',
            'user_name': 'User 1',
            'address': 'localhost',
            'client': 'test',
            'data': 'abc'
          }));
      var session = SessionV1();
      session.fromJson(json.decode(resp.body));
      expect(session, isNotNull);
      expect(session.id, isNotNull);
      expect(session.request_time, isNotNull);
      expect(session.user_id, '1');
      expect(session.user_name, 'User 1');
      expect(session.address, 'localhost');
      expect(session.client, 'test');
      expect(session.data, 'abc');

      session1 = session;

      // Store session data
      resp = await rest.post(url + '/v1/sessions/store_session_data',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'session_id': session1.id, 'data': 'xyz'}));
      session.fromJson(json.decode(resp.body));
      expect(session, isNotNull);
      expect(session.data, 'xyz');

      // Get opened session
      resp = await rest.post(url + '/v1/sessions/get_session_by_id',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'session_id': session1.id}));
      session.fromJson(json.decode(resp.body));
      expect(session, isNotNull);
      expect(session.request_time, isNotNull);
      expect(session.data, 'xyz');

      // Get open sessions
      resp = await rest.post(url + '/v1/sessions/get_sessions',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'filter': FilterParams.fromValue({'user_id': '1'}),
            'paging': PagingParams()
          }));
      var page = DataPage<SessionV1>.fromJson(json.decode(resp.body), (item) {
        var session = SessionV1();
        session.fromJson(item);
        return session;
      });
      expect(page, isNotNull);
      expect(page.data.length, 1);

      session1 = page.data[0];
      expect(session1.address, 'localhost');
      expect(session1.client, 'test');
    });

    test('Close Session', () async {
      SessionV1 session1;

      // Create a new session
      var resp = await rest.post(url + '/v1/sessions/open_session',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'user_id': '1',
            'user_name': 'User 1',
            'address': 'localhost',
            'client': 'test'
          }));
      var session = SessionV1();
      session.fromJson(json.decode(resp.body));
      expect(session, isNotNull);
      expect(session.id, isNotNull);
      expect(session.request_time, isNotNull);
      expect(session.user_id, '1');
      expect(session.user_name, 'User 1');
      expect(session.address, 'localhost');
      expect(session.client, 'test');

      session1 = session;

      // Close session
      resp = await rest.post(url + '/v1/sessions/close_session',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'session_id': session1.id}));
      session.fromJson(json.decode(resp.body));
      expect(session, isNotNull);

      // Get open sessions
      resp = await rest.post(url + '/v1/sessions/get_sessions',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'filter': FilterParams.fromTuples(['user_id', '1', 'active', true]),
            'paging': PagingParams()
          }));
      var page = DataPage<SessionV1>.fromJson(json.decode(resp.body), (item) {
        var session = SessionV1();
        session.fromJson(item);
        return session;
      });
      expect(page, isNotNull);
      expect(page.data.length, 0);
    });
  });
}
