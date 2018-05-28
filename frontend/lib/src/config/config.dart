import 'package:angular/core.dart';

import 'vars.dart';

@Injectable()
class ConfigService {
  server() => cfg.server;
  signinUrl() => cfg.signinUrl;
  //server() => "http://api-dev.scoutcamp.gl26.dk:4567/";
}