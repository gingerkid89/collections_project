// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Sammel App';

  @override
  String get myCollections => 'Meine Sammlungen';

  @override
  String get discoverAndCollect => 'Entdecke und sammle besondere Orte';

  @override
  String get searchPlacesOrCollections => 'Orte oder Sammlungen suchen...';

  @override
  String get visited => 'Besucht';

  @override
  String get total => 'Gesamt';

  @override
  String get progress => 'Fortschritt';

  @override
  String get activeCollections => 'Aktive Sammlungen';

  @override
  String get map => 'Karte';

  @override
  String get details => 'Details';

  @override
  String get collectingProgress => 'Sammel-Fortschritt';

  @override
  String get searchLocations => 'Filialen suchen...';

  @override
  String get all => 'Alle';

  @override
  String get collected => 'Gesammelt';

  @override
  String get open => 'Offen';

  @override
  String get noLocationsFound => 'Keine Filialen gefunden';

  @override
  String get tryDifferentSearch =>
      'Versuche einen anderen Suchbegriff oder Filter.';

  @override
  String get markAsVisited => 'Als besucht\nmarkieren';

  @override
  String get visitedToday => 'Heute besucht';

  @override
  String visitedCount(Object total, Object visited) {
    return '$visited von $total besucht';
  }

  @override
  String allCount(Object count) {
    return 'Alle ($count)';
  }

  @override
  String collectedCount(Object count) {
    return 'Gesammelt ($count)';
  }

  @override
  String openCount(Object count) {
    return 'Offen ($count)';
  }

  @override
  String get mcdonaldsDescription =>
      'Sammle alle McDonald\'s Restaurants in deiner Region';

  @override
  String get starbucksDescription => 'Entdecke alle Starbucks Locations';

  @override
  String get museumsDescription => 'Besuche Museen und Ausstellungen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get profile => 'Profil';

  @override
  String get preferences => 'Präferenzen';

  @override
  String get collections => 'Sammlungen';

  @override
  String get dataPrivacy => 'Daten & Datenschutz';

  @override
  String get support => 'Support';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Design';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get receiveUpdates => 'Updates und Erfolge erhalten';

  @override
  String get locationServices => 'Standortdienste';

  @override
  String get findNearbyPlaces => 'Orte in der Nähe automatisch finden';

  @override
  String get autoMark => 'Automatisch markieren';

  @override
  String get autoMarkDescription => 'Orte automatisch als besucht markieren';

  @override
  String get soundEffects => 'Soundeffekte';

  @override
  String get achievementSounds => 'Töne für Erfolge abspielen';

  @override
  String get manageData => 'Daten verwalten';

  @override
  String get clearCache => 'Cache leeren';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get dataUsage => 'Wie wir deine Daten nutzen';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get downloadCollections => 'Deine Sammlungen herunterladen';

  @override
  String get help => 'Hilfe & Support';

  @override
  String get faq => 'Häufig gestellte Fragen';

  @override
  String get feedback => 'Feedback senden';

  @override
  String get sendFeedback => 'Hilf uns die App zu verbessern';

  @override
  String get about => 'Über';

  @override
  String get selectLanguage => 'Sprache wählen';

  @override
  String get selectTheme => 'Design wählen';

  @override
  String get lightTheme => 'Hell';

  @override
  String get darkTheme => 'Dunkel';

  @override
  String get systemTheme => 'System Standard';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get cacheCleared => 'Cache erfolgreich geleert';

  @override
  String get exportDescription =>
      'Exportiere alle deine Sammlungsdaten als JSON-Datei';

  @override
  String get exportStarted => 'Export gestartet. Prüfe deine Downloads.';

  @override
  String get export => 'Exportieren';

  @override
  String get dataManagementInfo =>
      'Dies löscht temporäre Dateien und setzt einige Einstellungen zurück.';

  @override
  String get aboutDescription =>
      'Eine schöne App zum Sammeln und Verfolgen besonderer Orte, die du besuchst.';
}
