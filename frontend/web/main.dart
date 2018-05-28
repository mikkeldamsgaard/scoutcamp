import 'package:angular/angular.dart';
import "package:intl/intl_browser.dart";
import 'package:scoutcamp/app_component.dart';
import 'package:scoutcamp/login.dart';
import 'package:scoutcamp/src/config/vars.dart';

import 'dart:html';
import 'messages_all.dart';


void main() {
  var initMessages = findSystemLocale().then((locale) {
    initializeMessages(locale);
  });
  initMessages.then((ignore) {
      loggedIn().then((isLoggedIn) {
        if (isLoggedIn) {
          bootstrap(AppComponent);
        } else {
          window.location.replace(cfg.signinUrl);
        }
      });
    });
}
