import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular/src/core/metadata/lifecycle_hooks.dart';
import 'package:scoutcamp/src/users/user.dart';

import 'user_service.dart';


@Component(
    selector: 'userinfo',
    template: '<span>{{info.name}}</span>',
    directives: const [ ],
    providers: const [UserService]
)
class UserInfoComponent implements OnInit {
  final UserService userService;

  UserInfo info = new UserInfo();

  UserInfoComponent(this.userService);

  @override
  Future<Null> ngOnInit() async {
    info = await userService.getUserInfo();
  }

}

