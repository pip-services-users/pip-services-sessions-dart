import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services_sessions/pip_services_sessions.dart';

final SESSION1 = SessionV1(id: null, user_id: '1', user_name: 'User 1');
final SESSION2 = SessionV1(id: null, user_id: '2', user_name: 'User 2');

class SessionsPersistenceFixture {
  ISessionsPersistence _persistence;

  SessionsPersistenceFixture(ISessionsPersistence persistence) {
    expect(persistence, isNotNull);
    _persistence = persistence;
  }

  void testCrudOperations() async {
    SessionV1 session1, session2;
    // Create one session
    session1 = await _persistence.create(null, SESSION1);

    expect(session1, isNotNull);
    expect(session1.id, isNotNull);
    expect(session1.open_time, isNotNull);
    expect(session1.request_time, isNotNull);
    expect(SESSION1.user_id, session1.user_id);

    // Create another session
    session2 = await _persistence.create(null, SESSION2);
    expect(session2, isNotNull);
    expect(session2.id, isNotNull);
    expect(session2.open_time, isNotNull);
    expect(session2.request_time, isNotNull);
    expect(SESSION2.user_id, session2.user_id);

    // Partially update
    var session = await _persistence.updatePartially(
        null, session1.id, AnyValueMap.fromTuples(['data', '123']));
    expect(session, isNotNull);
    expect(session1.id, session.id);
    expect('123', session.data);

    // Get user sessions
    var page = await _persistence.getPageByFilter(
        null, FilterParams.fromTuples(['user_id', '1']), PagingParams());
    expect(page, isNotNull);
    expect(page.data.length, 1);
  }

  void testCloseExpired() async {
    await _persistence.closeExpired(null, DateTime.now());
  }
}
