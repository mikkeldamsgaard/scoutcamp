import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pikaday/pikaday.dart';
import 'messages_da.dart';
import 'messages_en.dart';
import 'package:angular/di.dart';

/// Definitions of functions for text messages, which can be localized.
/// This is a simplified version of the Intl: String groups() =>  Intl.message("Groups", name: "MenuMessages_groups");
/// But Intl package requires genreation of arb files and then generation of dart from translated arb.
//@Injectable()
abstract class Messages {

	static Messages locale(String locale) {
		if (locale == null || locale.length < 2) locale = "en";
		initializeDateFormatting(locale);
		switch (Intl.shortLocale(locale)) {
			case 'da': return new Messages_da();
			default : return new Messages_en();
		}
	}

	static Messages defaultLocale() => locale(Intl.defaultLocale);
	static const provider = const Provider(Messages,	useFactory: defaultLocale);

	static void changeLanguage(String language) {
		Intl.defaultLocale = language;
	}

/* definitions of messages function, it is possible to add methods having parameter if the sting should be interpolated. */
	String language();
	String language_full();

	String danish() => "Dansk";
	String english() => "English";

	String date_day_format() => "DD-MM-YYYY";
	String date_day(DateTime date) {
		var formatter = new DateFormat("dd-MM-yyyy");
	  return formatter.format(date);
	}
	PikadayI18nConfig	pickaday_config();

	String users();
	String groups();
	String activities();
	String participants();
	String no_choice();

	// Group texts
	String group_title();
	String group_new();
	String group_delete();
	String group_edit();
	String groups_empty();
	String group_new_name() {}

	String group_name();

	String contact_name();
	String contact_email();
	String contact_address();
	String contact_zip();
	String contact_city();
	String contact_country();

	String account_contact_name();
	String account_contact_phone();
	String account_contact_email();
	String account_number();


	String button_save();
	String button_save_add_similar();
	String button_cancel();
	String button_close();

	String participant_title();
  String participant_new();
	String participant_delete();
	String participant_edit();
	String participant_name();
	String participant_birthday();

	String participation_new();
	String participation_delete();
	String participation_edit();
	String participation_type_label();
	String participation_type(String type);
	String participation_date();
	String participation_morning();
	String participation_midday();
	String participation_evening();

	String diet_vegan();
	String diet_vegetarian();
	String diet_muslim();
	String diet_kosher();
	String diet_gluten_allergy();
	String diet_other_allergies();

	String electricity_special_needs();


}

