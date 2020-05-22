import 'package:pip_services3_data/pip_services3_data.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../data/version1/SessionV1.dart';
import './SessionsMemoryPersistence.dart';

class SessionsFilePersistence extends SessionsMemoryPersistence {
  JsonFilePersister<SessionV1> persister;

  SessionsFilePersistence([String path]) : super() {
    persister = JsonFilePersister<SessionV1>(path);
    loader = persister;
    saver = persister;
  }
  @override
  void configure(ConfigParams config) {
    super.configure(config);
    persister.configure(config);
  }
}
