import 'package:angular/core.dart';

@Injectable()
class ConfigService {
  server() => "http://localhost:4567/";
  //server() => "http://api-dev.scoutcamp.gl26.dk:4567/";
}