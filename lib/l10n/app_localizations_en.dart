// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Collection App';

  @override
  String get myCollections => 'My Collections';

  @override
  String get discoverAndCollect => 'Discover and collect special places';

  @override
  String get searchPlacesOrCollections => 'Search places or collections...';

  @override
  String get visited => 'Visited';

  @override
  String get total => 'Total';

  @override
  String get progress => 'Progress';

  @override
  String get activeCollections => 'Active Collections';

  @override
  String get map => 'Map';

  @override
  String get details => 'Details';

  @override
  String get collectingProgress => 'Collecting Progress';

  @override
  String get searchLocations => 'Search locations...';

  @override
  String get all => 'All';

  @override
  String get collected => 'Collected';

  @override
  String get open => 'Open';

  @override
  String get noLocationsFound => 'No locations found';

  @override
  String get tryDifferentSearch => 'Try a different search term or filter.';

  @override
  String get markAsVisited => 'Mark as\nvisited';

  @override
  String get visitedToday => 'Visited today';

  @override
  String visitedCount(Object total, Object visited) {
    return '$visited of $total visited';
  }

  @override
  String allCount(Object count) {
    return 'All ($count)';
  }

  @override
  String collectedCount(Object count) {
    return 'Collected ($count)';
  }

  @override
  String openCount(Object count) {
    return 'Open ($count)';
  }

  @override
  String get mcdonaldsDescription =>
      'Collect all McDonald\'s restaurants in your area';

  @override
  String get starbucksDescription => 'Discover all Starbucks locations';

  @override
  String get museumsDescription => 'Visit museums and exhibitions';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get preferences => 'Preferences';

  @override
  String get collections => 'Collections';

  @override
  String get dataPrivacy => 'Data & Privacy';

  @override
  String get support => 'Support';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get receiveUpdates => 'Receive updates and achievements';

  @override
  String get locationServices => 'Location Services';

  @override
  String get findNearbyPlaces => 'Find nearby places automatically';

  @override
  String get autoMark => 'Auto Mark Nearby';

  @override
  String get autoMarkDescription => 'Automatically mark places when nearby';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get achievementSounds => 'Play sounds for achievements';

  @override
  String get manageData => 'Manage Data';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get dataUsage => 'How we use your data';

  @override
  String get exportData => 'Export Data';

  @override
  String get downloadCollections => 'Download your collections';

  @override
  String get help => 'Help & Support';

  @override
  String get faq => 'Frequently asked questions';

  @override
  String get feedback => 'Send Feedback';

  @override
  String get sendFeedback => 'Help us improve the app';

  @override
  String get about => 'About';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System Default';

  @override
  String get cancel => 'Cancel';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get exportDescription =>
      'Export all your collection data as JSON file';

  @override
  String get exportStarted => 'Export started. Check your downloads.';

  @override
  String get export => 'Export';

  @override
  String get dataManagementInfo =>
      'This will clear temporary files and reset some preferences.';

  @override
  String get aboutDescription =>
      'A beautiful app for collecting and tracking special places you visit.';
}
