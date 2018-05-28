import 'package:angular/angular.dart';

import 'package:scoutcamp/app_component.dart';
import 'package:scoutcamp/login.dart';
import 'package:scoutcamp/src/config/vars.dart';

import 'dart:html';

void main() {
  loggedIn().then((isLoggedIn) {
    if (isLoggedIn) {
      bootstrap(AppComponent);
    } else {
      window.location.replace(cfg.signinUrl);
    }
  });
}
