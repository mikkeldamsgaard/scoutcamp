import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:uuid/uuid.dart';

import 'groups_service.dart';
import 'group.dart';


@Component(
  selector: 'groups',
  styleUrls: const ['groups.css'],
  templateUrl: 'groups.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
  ],
  providers: const [GroupsService],
)
class GroupsComponent implements OnInit {
  final GroupsService groupsService;

  List<Group> groups = [];
  Group selectedGroup;

  GroupsComponent(this.groupsService);

  @override
  Future<Null> ngOnInit() async {
    groups = await groupsService.getGroups();
  }

  void add() {
    var group = new Group();
    var uuid = new Uuid();
    group.name="New group";
    group.id = uuid.v1();
    groups.add(group);
    selectedGroup=group;
  }

  Future<Null> save() async {
    await groupsService.addGroup(selectedGroup);
    await cancel();
  }

  Future<Null> cancel() async {
    groups = await groupsService.getGroups();
    selectedGroup = null;
  }

  Future<Null>  remove(int index) async {
    await groupsService.deleteGroup(groups[index]);
    cancel();
  }

  void onReorder(ReorderEvent e) =>
      groups.insert(e.destIndex, groups.removeAt(e.sourceIndex));
}

