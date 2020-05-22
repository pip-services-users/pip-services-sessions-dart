import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

class SessionsHttpServiceV1 extends CommandableHttpService {
  SessionsHttpServiceV1() : super('v1/sessions') {
    dependencyResolver.put('controller',
        Descriptor('pip-services-sessions', 'controller', '*', '*', '1.0'));
  }
}
