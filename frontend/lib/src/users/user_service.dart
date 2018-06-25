import 'dart:async';

import 'dart:html';
import 'package:angular/core.dart';
import 'dart:convert';
import 'package:dartson/dartson.dart';


import 'user.dart';
import 'package:scoutcamp/src/config/config.dart';

/// Mock service emulating access to a to-do list stored on a server.
@Injectable()
class UserService {
  final ConfigService configService;
  var dson = new Dartson.JSON();

  UserService(this.configService);
  server() => configService.server()+"user";

  Future<UserInfo> getUserInfo() async {
    return HttpRequest.getString(server() + "/info", withCredentials: true).then((r) {
      Map reply = JSON.decode(r);
      UserInfo result = dson.map(reply, new UserInfo());
      return result;
    });
  }

}
