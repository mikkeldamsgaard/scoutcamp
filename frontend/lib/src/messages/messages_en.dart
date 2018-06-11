import 'messages.dart';
import 'package:pikaday/pikaday.dart';

/// Definitions of english text, which also are default
class Messages_en extends Messages {
	String language() => "en";
	String language_full() => "English";
	PikadayI18nConfig	pickaday_config() => new PikadayI18nConfig(
		previousMonth : 'Previous Month',
		nextMonth     : 'Next Month',
		months        : ['January','February','March','April','May','June','July','August','September','October','November','December'],
		weekdays      : ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],
		weekdaysShort : ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
	);

	String users() => "Users";
	String groups() => "Groups";
	String activities() => "Activities";
	String participants() => "Participants";
	String no_choice() => "No Choice";
  String account_contact_email() => "Accounting Contact Email";
  String account_contact_name() => "Accounting Contact Name";
  String account_contact_phone() => "Accounting Contact Phone";
  String account_number()  => "Account number";

  String button_cancel()  => "Cancel";
  String button_save() => "Save";
	String button_save_add_similar() => "Save and Add Similar";
	String button_close() => "Close";

	String contact_address() => "Contact Address";
  String contact_city() => "Contact City";
	String contact_country() => "Contact Country";
	String contact_email() => "Contact Email";
	String contact_name() => "Contact Name";
	String contact_zip() => "Contact Zip";
	String group_delete() => "Delete this Group";
	String group_edit() => "Edit this Group";
	String group_name() => "Group Name";
	String group_new() => "Register new Group";
	String group_new_name() => "New Group";
	String groups_empty() => "No Groups! Register one or more groups";

	String participant_new() => "New Participant";
	String participant_delete() => "Delete this Participant";
	String participant_edit() => "Edit this Participant";
	String participant_empty() => "No participants! Register one or more participants";
	String participant_name() => "Participant Name";
	String participant_birthday() => "Birthday";

	String participation_new() => "New Participation";
	String participation_delete() => "Delete this Participation";
	String participation_edit() => "Edit this Participation";
	String participation_type_label() => "Participation Type";
	String participation_type(String type) {
		switch (type) {
			case "Group":
				return "Group";
			case "Helper":
				return "Helper";
			default:
				return type;
		}
	}

	String participation_date() => "Date";
	String participation_morning() => "Morning";
	String participation_midday() => "Midday";
	String participation_evening() => "Evening";


	String diet_vegan() => "Vegan";
	String diet_vegetarian() => "Vegetarian";
	String diet_muslim() => "Muslim diet";
	String diet_kosher() => "Kosher diet";
	String diet_gluten_allergy() => "Gluten allergy";
	String diet_other_allergies() => "Other allergies";
	String electricity_special_needs() => "Special needs for electricity";

}