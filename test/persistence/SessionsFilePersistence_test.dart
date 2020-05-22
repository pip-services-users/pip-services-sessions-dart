import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services_sessions/pip_services_sessions.dart';
import './SessionsPersistenceFixture.dart';

void main() {
  group('SessionsFilePersistence', () {
    SessionsFilePersistence persistence;
    SessionsPersistenceFixture fixture;

    setUp(() async {
      persistence = SessionsFilePersistence('data/sessions.test.json');
      persistence.configure(ConfigParams());

      fixture = SessionsPersistenceFixture(persistence);

      await persistence.open(null);
      await persistence.clear(null);
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
