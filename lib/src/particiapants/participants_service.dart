import 'dart:async';

import 'dart:html';
import 'package:angular/core.dart';
import 'dart:convert';
import 'package:dartson/dartson.dart';


import 'participant.dart';

/// Mock service emulating access to a to-do list stored on a server.
@Injectable()
class ParticipantsService {
  var server = "http://localhost:4567/participants";
  var dson = new Dartson.JSON();

  Future<List<Participant>> getParticipants() async {
    return HttpRequest.getString(server).then((r) {
      List<Map> replyList = JSON.decode(r);
      List<Participant> result;
      result = replyList.map((g) => dson.map(g, new Participant())).toList();
      return result;
    });
  }

  Future<HttpRequest> addParticipant(Participant g) async {
    return HttpRequest.request(server+"/create", method: "POST", sendData: dson.encode(g), mimeType: "application/json");
  }

  Future<HttpRequest> deleteParticipant(Participant g) async {
    return HttpRequest.request(server+"/"+g.id, method: 'DELETE');

  }

}
