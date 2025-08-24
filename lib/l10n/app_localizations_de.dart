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
  String get total => 'Gesamt:';

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
  String get privacy => 'Privatsphäre';

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

  @override
  String get visitDetails => 'Besuch Details';

  @override
  String get save => 'Speichern';

  @override
  String get visitInformation => 'Besuchsinformationen';

  @override
  String get date => 'Datum';

  @override
  String get time => 'Uhrzeit';

  @override
  String get duration => 'Dauer';

  @override
  String get notSpecified => 'Nicht angegeben';

  @override
  String get overallRating => 'Gesamtbewertung';

  @override
  String get required => 'erforderlich';

  @override
  String get notes => 'Notizen';

  @override
  String get visitNotes => 'Wie war dein Besuch?';

  @override
  String get visitedExhibitions => 'Besuchte Ausstellungen';

  @override
  String get noExhibitionsAvailable =>
      'Keine Ausstellungsinformationen verfügbar';

  @override
  String get temporaryExhibition => 'Sonderausstellung';

  @override
  String get permanentExhibition => 'Dauerausstellung';

  @override
  String get additionalInformation => 'Zusätzliche Informationen';

  @override
  String get audioGuideUsed => 'Audio-Guide verwendet';

  @override
  String get giftShopVisited => 'Museumsshop besucht';

  @override
  String get hours => 'Stunden';

  @override
  String get minutes => 'Minuten';

  @override
  String get visitSavedSuccessfully => 'Besuch erfolgreich gespeichert!';

  @override
  String errorSaving(Object error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String get museumVisitSaved => 'Museumsbesuch erfolgreich gespeichert!';

  @override
  String visitSavedAt(Object placeName) {
    return 'Besuch bei $placeName gespeichert!';
  }

  @override
  String get currentExhibitions => 'Aktuelle Ausstellungen';

  @override
  String get permanentCollections => 'Dauerausstellungen';

  @override
  String get exhibitions => 'Ausstellungen';

  @override
  String get equipment => 'Ausstattung & Service';

  @override
  String get audioGuide => 'Audio-Guide';

  @override
  String get giftShop => 'Museumsshop';

  @override
  String get wheelchairAccessible => 'Barrierefrei';

  @override
  String get visitDuration => 'Besuchsdauer';

  @override
  String get museumVisitNotes => 'Wie war dein Museumsbesuch?';

  @override
  String get addNewVisit => 'Neuen Besuch hinzufügen';

  @override
  String get noVisitsYet => 'Noch keine Besuche aufgezeichnet';

  @override
  String get addFirstVisit => 'Fügen Sie Ihren ersten Besuch hinzu!';

  @override
  String get dishesOrdered => 'Gegessene Gerichte';

  @override
  String get availableDishes => 'Verfügbare Gerichte:';

  @override
  String get selectedDishes => 'Ausgewählte Gerichte:';

  @override
  String get costs => 'Kosten';

  @override
  String get dishesWithColon => 'Gerichte:';

  @override
  String get tip => 'Trinkgeld:';

  @override
  String get other => 'Sonstiges:';

  @override
  String get restaurantVisitNotes => 'Wie war dein Besuch?';

  @override
  String get dishes => 'Gerichte';

  @override
  String get averagePrice => 'Ø Preis';

  @override
  String get averageRating => 'Ø Bewertung';

  @override
  String get restaurantInfo => 'Restaurant Info';

  @override
  String get popularDishes => 'Beliebte Gerichte';

  @override
  String get cuisine => 'Küche';

  @override
  String get priceCategory => 'Preiskategorie';

  @override
  String get reservationsAvailable => 'Reservierungen möglich';

  @override
  String get deliveryService => 'Lieferservice';

  @override
  String get takeout => 'Abholung';

  @override
  String get priceRange => 'Preisklasse';

  @override
  String get noMenuInfoAvailable => 'Keine Menü-Informationen verfügbar';

  @override
  String get notVisitedYet => 'Noch nicht besucht';

  @override
  String get menu => 'Menü';

  @override
  String get visits => 'Besuche';

  @override
  String get ticketPrice => 'Eintritt';

  @override
  String get showAllExhibitions => 'Alle Ausstellungen anzeigen';

  @override
  String get myRating => 'Meine Bewertung';

  @override
  String get info => 'Info';

  @override
  String get museumInfo => 'Museum Info';

  @override
  String get category => 'Kategorie';

  @override
  String get noCurrentExhibitions => 'Keine aktuellen Sonderausstellungen';

  @override
  String get art => 'Kunst';

  @override
  String get history => 'Geschichte';

  @override
  String get science => 'Wissenschaft';

  @override
  String get technology => 'Technik';

  @override
  String get nature => 'Naturkunde';

  @override
  String get archaeology => 'Archäologie';

  @override
  String get noExhibitionInfoAvailable =>
      'Keine Ausstellungsinformationen verfügbar';

  @override
  String get overview => 'Übersicht';

  @override
  String get alreadyVisited => 'Schon besucht';

  @override
  String get photos => 'Fotos';

  @override
  String get addPhoto => 'Foto hinzufügen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromGallery => 'Aus Galerie wählen';

  @override
  String get removePhoto => 'Foto entfernen';

  @override
  String get recentVisits => 'Letzte Besuche';

  @override
  String get myVisits => 'Meine Besuche';

  @override
  String get publicVisits => 'Besuche von anderen';

  @override
  String get startExploring =>
      'Beginne zu erkunden, um deine Besuche hier zu sehen';

  @override
  String get noPublicVisits => 'Keine Besuche von anderen';

  @override
  String get comingSoon =>
      'Wenn andere Nutzer Besuche teilen, erscheinen sie hier';

  @override
  String get privateVisits => 'Private Besuche';

  @override
  String get publicVisitsPlace => 'Öffentliche Besuche';

  @override
  String get noPrivateVisits => 'Noch keine privaten Besuche';

  @override
  String get noPublicVisitsForPlace =>
      'Keine öffentlichen Besuche für diesen Ort';

  @override
  String get switchToPublic =>
      'Wechsle zu öffentlichen Besuchen um zu sehen was andere geteilt haben';

  @override
  String get switchToPrivate =>
      'Wechsle zu privaten Besuchen um deine persönliche Historie zu sehen';

  @override
  String get publicData => 'Öffentliche Daten';

  @override
  String get privateData => 'Private Daten';

  @override
  String get privacyDescription =>
      'Wählen Sie, ob Ihre Besuchsdaten öffentlich geteilt oder privat gehalten werden sollen';

  @override
  String get photoAdded => 'Foto erfolgreich hinzugefügt';

  @override
  String get photoRemoved => 'Foto entfernt';

  @override
  String get errorLoadingPhoto => 'Fehler beim Laden des Fotos';

  @override
  String get publicDataDescription =>
      'Deine Bewertungen können von anderen gesehen werden';

  @override
  String get privateDataDescription => 'Nur du kannst deine Daten sehen';

  @override
  String get editVisit => 'Besuch bearbeiten';

  @override
  String get deleteVisit => 'Besuch löschen';

  @override
  String get shareVisit => 'Besuch teilen';

  @override
  String get viewDetails => 'Details anzeigen';

  @override
  String get activities => 'Aktivitäten';

  @override
  String get cost => 'Kosten';

  @override
  String get location => 'Ort';

  @override
  String get noPhotos => 'Keine Fotos';

  @override
  String get photoGallery => 'Fotogalerie';

  @override
  String get confirmDelete => 'Besuch löschen';

  @override
  String get confirmDeleteMessage =>
      'Sind Sie sicher, dass Sie diesen Besuch löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get delete => 'Löschen';

  @override
  String get visitsByOtherUsers => 'Besuche von anderen';

  @override
  String get noMyVisits => 'Noch keine Besuche';

  @override
  String get noVisitsByOtherUsers => 'Keine Besuche von anderen';

  @override
  String get switchToOthersVisits => 'Schauen Sie sich Besuche von anderen an';

  @override
  String get switchToMyVisits => 'Zu Ihren Besuchen wechseln';
}
