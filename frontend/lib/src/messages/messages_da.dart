import 'messages.dart';
import 'package:pikaday/pikaday.dart';

/// Definitions of danish text,
class Messages_da extends Messages {
	String language() => "da";
	String language_full() => "Dansk";

	PikadayI18nConfig	pickaday_config() => new PikadayI18nConfig(
			previousMonth : 'Forrige Måned',
			nextMonth     : 'Forrige År',
			months        : ['Januar','Februar','Marts','April','Maj','Juni','Juli','August','September','October','November','December'],
			weekdays      : ['Søndag','Mandag','Tirsdag','Onsdag','Thorsdag','Fredag','Lørdag'],
			weekdaysShort : ['Søn','Man','Tir','Ons','Tor','Fre','Lør']
	);

	String users() => "Brugere";
	String groups() => "Grupper";
	String activities() => "Aktiviteter";
	String participants() => "Deltagere";
	String no_choice() => "Intet valgt";

	String account_contact_email() => "Afregningskontakt email";
	String account_contact_name() => "Afregningskontakt navn";
	String account_contact_phone() => "Afregningskontakt telefon";
	String account_number()  => "Kontonummer";

	String button_cancel()  => "Annuller";
	String button_save() => "Gem";
	String button_save_add_similar() => "Gem og tilføj lignende";
	String button_close() => "Luk";

	String contact_address() => "Kontakt adresse";
	String contact_city() => "Kontakt by";
	String contact_country() => "Kontakt Land";
	String contact_email() => "Kontakt email";
	String contact_name() => "Kontaktnavn";
	String contact_zip() => "Kontakt postnummer";
	String group_delete() => "Slet denne gruppe";
	String group_edit() => "Ret denne gruppe";
	String group_name() => "Gruppe navn";
	String group_new() => "Opret ny gruppe";
	String group_new_name() => "Ny gruppe";
	String groups_empty() => "Ingen grupper! Opret en eller flere grupper";

  String participant_new() => "Ny deltager";
	String participant_delete() => "Slet denne deltager";
	String participant_edit() => "Ret denne deltager";
	String participant_empty() => "Ingen deltagere! Tilføj en eller flere deltagere";

	String participant_name() => "Deltager navn";
	String participant_birthday() => "Fødselsdato";

	String participation_new() => "Ny deltagelse";
	String participation_delete() => "Slet denne deltagelse";
	String participation_edit() => "Ret denne deltagelse";
	String participation_type_label() => "Deltagelses type";
	String participation_type(String type) {
		switch (type) {
			case "Group":
				return "Gruppe";
			case "Helper":
				return "Hjælper";
			default:
				return type;
		}
	}

	String participation_date() => "Dato";
	String participation_morning() => "Morgen";
	String participation_midday() => "Middag";
	String participation_evening() => "Aften";

	String diet_vegan() => "Vegan";
	String diet_vegetarian() => "Vegetar";
	String diet_muslim() => "Muslimsk diæt";
	String diet_kosher() => "Kosher diæt";
	String diet_gluten_allergy() => "Gluten allergi";
	String diet_other_allergies() => "Andre allergier";

	String electricity_special_needs() => "Specielt behov for el";

}