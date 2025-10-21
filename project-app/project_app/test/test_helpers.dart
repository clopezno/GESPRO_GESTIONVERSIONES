import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configura `shared_preferences` y desactiva los logs de `EasyLocalization` para los tests.
void setupTestEnvironment() {
  // Configura valores iniciales de shared_preferences
  SharedPreferences.setMockInitialValues({});

  // Desactiva los logs de EasyLocalization
  EasyLocalization.logger.enableLevels = [];
}
