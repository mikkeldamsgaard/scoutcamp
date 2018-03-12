import 'package:dartson/dartson.dart';

@Entity()
class Participant {
  String id;
  String name;
  String birthday;
  bool vegan;
  bool vegetarian;
  bool muslim;
  bool kosher;
  bool glutenAllergies;
  String extraAllergies;
  bool needsElectricity;
  List<Participation> participations;

  DateTime get birthdayDate => DateTime.parse(birthday);
  void set birthdayDate(DateTime birthdayDate) => birthday = birthdayDate.toIso8601String();
}

@Entity()
class Participation {
  String type;
  String date;
  bool morning, midday,evening;
  String groupId;
  String campType;
  bool needElectricity;

  DateTime get dateDate => DateTime.parse(date);
  void set dateDate(DateTime birthdayDate) => date = birthdayDate.toIso8601String();
}