import 'package:intl/intl.dart';

class MenuMessages {
	String users() =>  Intl.message("Users", name: "MenuMessages_users");
	String groups() =>  Intl.message("Groups", name: "MenuMessages_groups");
	String activities() =>  Intl.message("Activities", name: "MenuMessages_activities");
	String participants() =>  Intl.message("Participants", name: "MenuMessages_participants");
	String no_choice() =>  Intl.message("No Choice", name: "MenuMessages_no_choice");

}