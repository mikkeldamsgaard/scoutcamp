import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'src/menu/menu.dart';
import 'src/config/config.dart';
// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [materialDirectives, MenuComponent],
  providers: const [materialProviders, ConfigService],
)
class AppComponent {
  // Nothing here yet. All logic is in TodoListComponent.
}
