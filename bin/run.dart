import 'package:pip_services_sessions/pip_services_sessions.dart';

void main(List<String> argument) {
  try {
    var proc = SessionsProcess();
    proc.configPath = './config/config.yml';
    proc.run(argument);
  } catch (ex) {
    print(ex);
  }
}
