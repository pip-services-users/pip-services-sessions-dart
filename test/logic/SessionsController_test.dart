import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services_sessions/pip_services_sessions.dart';

void main() {
  group('SessionsController', () {
    SessionsMemoryPersistence persistence;
    SessionsController controller;

    setUp(() async {
      persistence = SessionsMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = SessionsController();
      controller.configure(ConfigParams());

      var references = References.fromTuples([
        Descriptor(
            'pip-services-sessions', 'persistence', 'memory', 'default', '1.0'),
        persistence,
        Descriptor(
            'pip-services-sessions', 'controller', 'default', 'default', '1.0'),
        controller
      ]);

      controller.setReferences(references);

      await persistence.open(null);
    });

    tearDown(() async {
      await persistence.close(null);
    });

    test('Close session', () async {
      var session1 = await controller.openSession(
          null, '1', 'User 1', 'localhost', 'test', '123', 'abc');
      expect(session1, isNotNull);
      expect(session1.id, isNotNull);
      expect(session1.request_time, isNotNull);
      expect(session1.active, isTrue);

      var del_session = await controller.closeSession(null, session1.id);
      expect(del_session, isNotNull);
      expect(del_session.id, session1.id);
      expect(session1.request_time, isNotNull);
      expect(session1.active, isFalse);
    });
  });
}
