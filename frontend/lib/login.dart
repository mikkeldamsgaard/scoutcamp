import 'dart:async';

import 'dart:html';
import 'package:scoutcamp/src/config/vars.dart';

Future<bool> loggedIn() {
  return HttpRequest.getString(server + "isLoggedIn", withCredentials: true).then((r) {
        return (r == "YES");
  });
}
