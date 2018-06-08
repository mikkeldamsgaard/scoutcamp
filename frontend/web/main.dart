import 'package:angular/angular.dart';
import "package:intl/intl.dart";
import 'package:scoutcamp/app_component.dart';
import 'package:scoutcamp/login.dart';
import 'package:scoutcamp/src/config/vars.dart';

import 'dart:html';

import 'package:scoutcamp/src/messages/messages.dart';

void main() {
  Intl.systemLocale = Intl.canonicalizedLocale(window.navigator.language);
  if (Intl.defaultLocale == null) {
    Intl.defaultLocale = Intl.systemLocale;
  }

  loggedIn().then((isLoggedIn) {
    if (isLoggedIn) {
      bootstrap(AppComponent, [provide(Messages, useFactory: Messages.defaultLocale )]);
    } else {
      window.location.replace(cfg.signinUrl);
    }
  });
}
