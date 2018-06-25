// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:scoutcamp/src/users/userinfo.dart';

import '../groups/groups.dart';
import '../particiapants/participants.dart';
import 'package:scoutcamp/src/messages/messages.dart';

@Component(
    selector: 'app-layout',
    directives: const [
      DeferredContentDirective,
      materialDirectives,
      CORE_DIRECTIVES,
      GroupsComponent,
      ParticipantsComponent,
      UserInfoComponent
    ],
    templateUrl: 'menu.html',
    styleUrls: const [
      'package:angular_components/app_layout/layout.scss.css',
      'menu.css',
    ]
)
class MenuComponent {
  bool end = false;
  String menuItem = "register";
  Messages messages = Messages.defaultLocale();

  MenuComponent();

  void changeLanguage(String language) {
    Messages.changeLanguage(language);
    messages = Messages.defaultLocale();
    menuItem = "register";
  }
}