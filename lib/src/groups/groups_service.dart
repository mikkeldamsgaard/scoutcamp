import 'dart:async';

import 'dart:html';
import 'package:angular/core.dart';
import 'dart:convert';
import 'package:dartson/dartson.dart';


import 'group.dart';

/// Mock service emulating access to a to-do list stored on a server.
@Injectable()
class GroupsService {
  var server = "http://localhost:4567/groups";
  var dson = new Dartson.JSON();

  Future<List<Group>> getGroups() async {
    return HttpRequest.getString(server).then((r) {
      List<Map> replyList = JSON.decode(r);
      List<Group> result;
      result = replyList.map((g) => dson.map(g, new Group())).toList();
      return result;
    });
  }

  Future<HttpRequest> addGroup(Group g) async {
    return HttpRequest.request(server+"/create", method: "POST", sendData: dson.encode(g), mimeType: "application/json");
  }

  Future<HttpRequest> deleteGroup(Group g) async {
    return HttpRequest.request(server+"/"+g.id, method: 'DELETE');

  }

}
