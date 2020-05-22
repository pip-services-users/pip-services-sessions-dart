import 'package:pip_services3_container/pip_services3_container.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

import '../build/SessionsServiceFactory.dart';

class SessionsProcess extends ProcessContainer {
  SessionsProcess() : super('sessions', 'User sessions microservice') {
    factories.add(SessionsServiceFactory());
    factories.add(DefaultRpcFactory());
  }
}
