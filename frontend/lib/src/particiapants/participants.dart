import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:uuid/uuid.dart';
import 'package:pikaday_datepicker_angular/pikaday_datepicker_angular.dart';

import 'participants_service.dart';
import 'participant.dart';
import 'package:scoutcamp/src/messages/messages.dart';


@Component(
  selector: 'participants',
  styleUrls: const ['participants.css'],
  templateUrl: 'participants.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    PikadayComponent
  ],
  providers: const [ParticipantsService],
)
class ParticipantsComponent implements OnInit {
  final ParticipantsService participantsService;
  Messages messages = Messages.defaultLocale();

  List<Participant> participants = [];
  Participant selectedParticipant;
  Participation selectedParticipation;

  ParticipantsComponent(this.participantsService) {
  }

  @override
  Future<Null> ngOnInit() async {
    participants = await participantsService.getParticipants();
  }

  void add() {
    internalAdd(new List());
  }

  void internalAdd(List<Participation> participations) {
    var uuid = new Uuid();
    var participant = new Participant()
      ..name= messages.participant_new()
      ..id = uuid.v1()
      ..birthdayDate = new DateTime(2000,1,1)
      ..participations=participations;

    participants.add(participant);
    selectedParticipant=participant;
  }

  Future<Null> save() async {
    await participantsService.addParticipant(selectedParticipant);
    await cancel();
  }

  Future<Null> saveAddSimilar() async {
    Participant old = selectedParticipant;
    await participantsService.addParticipant(selectedParticipant);
    await cancel();
    internalAdd(old.participations);
  }

  Future<Null> cancel() async {
    participants = await participantsService.getParticipants();
    selectedParticipant = null;
  }

  Future<Null>  remove(int index) async {
    await participantsService.deleteParticipant(participants[index]);
    cancel();
  }

  void removeParticipation(int participationIndex) {
    selectedParticipant.participations.removeAt(participationIndex);
  }

  void addParticipation() {
    selectedParticipation = new Participation()
          ..type="Group"
          ..dateDate = new DateTime(2019,7,13);
    selectedParticipant.participations.add(selectedParticipation);
  }

  void onReorder(ReorderEvent e) =>
      participants.insert(e.destIndex, participants.removeAt(e.sourceIndex));

  final SelectionOptions<String> typeSelectionOptions = new StringSelectionOptions(["Group", "Helper"]);

  SelectionModel<String> typeSelectionModel() {
    SelectionModel<String> typeSelectionModel = new SelectionModel.withList(selectedValues: [selectedParticipation.type]);
    typeSelectionModel.selectionChanges.listen((_) {
      if (selectedParticipation != null && !typeSelectionModel.selectedValues.isEmpty)
        selectedParticipation.type = typeSelectionModel.selectedValues.first;
    });
    return typeSelectionModel;
  }
}


