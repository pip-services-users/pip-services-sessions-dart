import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../persistence/SessionsMemoryPersistence.dart';
import '../persistence/SessionsFilePersistence.dart';
import '../persistence/SessionsMongoDbPersistence.dart';
import '../logic/SessionsController.dart';
import '../services/version1/SessionsHttpServiceV1.dart';

class SessionsServiceFactory extends Factory {
  static final MemoryPersistenceDescriptor =
      Descriptor('pip-services-sessions', 'persistence', 'memory', '*', '1.0');
  static final FilePersistenceDescriptor =
      Descriptor('pip-services-sessions', 'persistence', 'file', '*', '1.0');
  static final MongoDbPersistenceDescriptor =
      Descriptor('pip-services-sessions', 'persistence', 'mongodb', '*', '1.0');
  static final ControllerDescriptor =
      Descriptor('pip-services-sessions', 'controller', 'default', '*', '1.0');
  static final HttpServiceDescriptor =
      Descriptor('pip-services-sessions', 'service', 'http', '*', '1.0');

  SessionsServiceFactory() : super() {
    registerAsType(SessionsServiceFactory.MemoryPersistenceDescriptor,
        SessionsMemoryPersistence);
    registerAsType(SessionsServiceFactory.FilePersistenceDescriptor,
        SessionsFilePersistence);
    registerAsType(SessionsServiceFactory.MongoDbPersistenceDescriptor,
        SessionsMongoDbPersistence);
    registerAsType(
        SessionsServiceFactory.ControllerDescriptor, SessionsController);
    registerAsType(
        SessionsServiceFactory.HttpServiceDescriptor, SessionsHttpServiceV1);
  }
}
