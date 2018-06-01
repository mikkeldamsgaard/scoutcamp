import 'package:angular/angular.dart';
import "package:intl/intl.dart";
import 'package:scoutcamp/app_component.dart';
import 'package:scoutcamp/login.dart';
import 'package:scoutcamp/src/config/vars.dart';

import 'dart:html';

void main() {
  Intl.systemLocale = Intl.canonicalizedLocale(window.navigator.language);
  Intl.defaultLocale = Intl.systemLocale;

  loggedIn().then((isLoggedIn) {
    if (isLoggedIn) {
      bootstrap(AppComponent);
    } else {
      window.location.replace(cfg.signinUrl);
    }
  });
}
