import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services_sessions/pip_services_sessions.dart';
import './SessionsPersistenceFixture.dart';

void main() {
  group('SessionsMemoryPersistence', () {
    SessionsMemoryPersistence persistence;
    SessionsPersistenceFixture fixture;

    setUp(() async {
      persistence = SessionsMemoryPersistence();
      persistence.configure(ConfigParams());

      fixture = SessionsPersistenceFixture(persistence);

      await persistence.open(null);
    });

    tearDown(() async {
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      await fixture.testCrudOperations();
    });

    test('Close Expired', () async {
      await fixture.testCloseExpired();
    });
  });
}
