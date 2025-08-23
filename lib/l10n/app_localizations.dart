import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection App'**
  String get appTitle;

  /// No description provided for @myCollections.
  ///
  /// In en, this message translates to:
  /// **'My Collections'**
  String get myCollections;

  /// No description provided for @discoverAndCollect.
  ///
  /// In en, this message translates to:
  /// **'Discover and collect special places'**
  String get discoverAndCollect;

  /// No description provided for @searchPlacesOrCollections.
  ///
  /// In en, this message translates to:
  /// **'Search places or collections...'**
  String get searchPlacesOrCollections;

  /// No description provided for @visited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visited;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get total;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @activeCollections.
  ///
  /// In en, this message translates to:
  /// **'Active Collections'**
  String get activeCollections;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @collectingProgress.
  ///
  /// In en, this message translates to:
  /// **'Collecting Progress'**
  String get collectingProgress;

  /// No description provided for @searchLocations.
  ///
  /// In en, this message translates to:
  /// **'Search locations...'**
  String get searchLocations;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @noLocationsFound.
  ///
  /// In en, this message translates to:
  /// **'No locations found'**
  String get noLocationsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or filter.'**
  String get tryDifferentSearch;

  /// No description provided for @markAsVisited.
  ///
  /// In en, this message translates to:
  /// **'Mark as\nvisited'**
  String get markAsVisited;

  /// No description provided for @visitedToday.
  ///
  /// In en, this message translates to:
  /// **'Visited today'**
  String get visitedToday;

  /// No description provided for @visitedCount.
  ///
  /// In en, this message translates to:
  /// **'{visited} of {total} visited'**
  String visitedCount(Object total, Object visited);

  /// No description provided for @allCount.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String allCount(Object count);

  /// No description provided for @collectedCount.
  ///
  /// In en, this message translates to:
  /// **'Collected ({count})'**
  String collectedCount(Object count);

  /// No description provided for @openCount.
  ///
  /// In en, this message translates to:
  /// **'Open ({count})'**
  String openCount(Object count);

  /// No description provided for @mcdonaldsDescription.
  ///
  /// In en, this message translates to:
  /// **'Collect all McDonald\'s restaurants in your area'**
  String get mcdonaldsDescription;

  /// No description provided for @starbucksDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover all Starbucks locations'**
  String get starbucksDescription;

  /// No description provided for @museumsDescription.
  ///
  /// In en, this message translates to:
  /// **'Visit museums and exhibitions'**
  String get museumsDescription;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @dataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataPrivacy;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @receiveUpdates.
  ///
  /// In en, this message translates to:
  /// **'Receive updates and achievements'**
  String get receiveUpdates;

  /// No description provided for @locationServices.
  ///
  /// In en, this message translates to:
  /// **'Location Services'**
  String get locationServices;

  /// No description provided for @findNearbyPlaces.
  ///
  /// In en, this message translates to:
  /// **'Find nearby places automatically'**
  String get findNearbyPlaces;

  /// No description provided for @autoMark.
  ///
  /// In en, this message translates to:
  /// **'Auto Mark Nearby'**
  String get autoMark;

  /// No description provided for @autoMarkDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically mark places when nearby'**
  String get autoMarkDescription;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @achievementSounds.
  ///
  /// In en, this message translates to:
  /// **'Play sounds for achievements'**
  String get achievementSounds;

  /// No description provided for @manageData.
  ///
  /// In en, this message translates to:
  /// **'Manage Data'**
  String get manageData;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @dataUsage.
  ///
  /// In en, this message translates to:
  /// **'How we use your data'**
  String get dataUsage;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @downloadCollections.
  ///
  /// In en, this message translates to:
  /// **'Download your collections'**
  String get downloadCollections;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faq;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get feedback;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Help us improve the app'**
  String get sendFeedback;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemTheme;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Export all your collection data as JSON file'**
  String get exportDescription;

  /// No description provided for @exportStarted.
  ///
  /// In en, this message translates to:
  /// **'Export started. Check your downloads.'**
  String get exportStarted;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @dataManagementInfo.
  ///
  /// In en, this message translates to:
  /// **'This will clear temporary files and reset some preferences.'**
  String get dataManagementInfo;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A beautiful app for collecting and tracking special places you visit.'**
  String get aboutDescription;

  /// No description provided for @visitDetails.
  ///
  /// In en, this message translates to:
  /// **'Visit: {placeName}'**
  String visitDetails(Object placeName);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @visitInformation.
  ///
  /// In en, this message translates to:
  /// **'Visit Information'**
  String get visitInformation;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @overallRating.
  ///
  /// In en, this message translates to:
  /// **'Overall Rating'**
  String get overallRating;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'required'**
  String get required;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notes;

  /// No description provided for @visitNotes.
  ///
  /// In en, this message translates to:
  /// **'How was your visit?'**
  String get visitNotes;

  /// No description provided for @visitedExhibitions.
  ///
  /// In en, this message translates to:
  /// **'Visited Exhibitions'**
  String get visitedExhibitions;

  /// No description provided for @noExhibitionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No exhibition information available'**
  String get noExhibitionsAvailable;

  /// No description provided for @temporaryExhibition.
  ///
  /// In en, this message translates to:
  /// **'Temporary Exhibition'**
  String get temporaryExhibition;

  /// No description provided for @permanentExhibition.
  ///
  /// In en, this message translates to:
  /// **'Permanent Exhibition'**
  String get permanentExhibition;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @audioGuideUsed.
  ///
  /// In en, this message translates to:
  /// **'Used Audio Guide'**
  String get audioGuideUsed;

  /// No description provided for @giftShopVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited Gift Shop'**
  String get giftShopVisited;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @visitSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Visit saved successfully!'**
  String get visitSavedSuccessfully;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSaving(Object error);

  /// No description provided for @museumVisitSaved.
  ///
  /// In en, this message translates to:
  /// **'Museum visit saved successfully!'**
  String get museumVisitSaved;

  /// No description provided for @visitSavedAt.
  ///
  /// In en, this message translates to:
  /// **'Visit at {placeName} saved!'**
  String visitSavedAt(Object placeName);

  /// No description provided for @currentExhibitions.
  ///
  /// In en, this message translates to:
  /// **'Current Exhibitions'**
  String get currentExhibitions;

  /// No description provided for @permanentCollections.
  ///
  /// In en, this message translates to:
  /// **'Permanent Collections'**
  String get permanentCollections;

  /// No description provided for @exhibitions.
  ///
  /// In en, this message translates to:
  /// **'Exhibitions'**
  String get exhibitions;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment & Service'**
  String get equipment;

  /// No description provided for @audioGuide.
  ///
  /// In en, this message translates to:
  /// **'Audio Guide'**
  String get audioGuide;

  /// No description provided for @giftShop.
  ///
  /// In en, this message translates to:
  /// **'Gift Shop'**
  String get giftShop;

  /// No description provided for @wheelchairAccessible.
  ///
  /// In en, this message translates to:
  /// **'Wheelchair Accessible'**
  String get wheelchairAccessible;

  /// No description provided for @visitDuration.
  ///
  /// In en, this message translates to:
  /// **'Visit Duration'**
  String get visitDuration;

  /// No description provided for @museumVisitNotes.
  ///
  /// In en, this message translates to:
  /// **'How was your museum visit?'**
  String get museumVisitNotes;

  /// No description provided for @addNewVisit.
  ///
  /// In en, this message translates to:
  /// **'Add New Visit'**
  String get addNewVisit;

  /// No description provided for @noVisitsYet.
  ///
  /// In en, this message translates to:
  /// **'No visits recorded yet'**
  String get noVisitsYet;

  /// No description provided for @addFirstVisit.
  ///
  /// In en, this message translates to:
  /// **'Add your first visit!'**
  String get addFirstVisit;

  /// No description provided for @dishesOrdered.
  ///
  /// In en, this message translates to:
  /// **'Dishes Ordered'**
  String get dishesOrdered;

  /// No description provided for @availableDishes.
  ///
  /// In en, this message translates to:
  /// **'Available Dishes'**
  String get availableDishes;

  /// No description provided for @selectedDishes.
  ///
  /// In en, this message translates to:
  /// **'Selected Dishes:'**
  String get selectedDishes;

  /// No description provided for @costs.
  ///
  /// In en, this message translates to:
  /// **'Costs'**
  String get costs;

  /// No description provided for @dishesWithColon.
  ///
  /// In en, this message translates to:
  /// **'Dishes:'**
  String get dishesWithColon;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip:'**
  String get tip;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other:'**
  String get other;

  /// No description provided for @restaurantVisitNotes.
  ///
  /// In en, this message translates to:
  /// **'How was your visit?'**
  String get restaurantVisitNotes;

  /// No description provided for @dishes.
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get dishes;

  /// No description provided for @averagePrice.
  ///
  /// In en, this message translates to:
  /// **'Avg Price'**
  String get averagePrice;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Avg Rating'**
  String get averageRating;

  /// No description provided for @restaurantInfo.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Info'**
  String get restaurantInfo;

  /// No description provided for @popularDishes.
  ///
  /// In en, this message translates to:
  /// **'Popular Dishes'**
  String get popularDishes;

  /// No description provided for @cuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get cuisine;

  /// No description provided for @priceCategory.
  ///
  /// In en, this message translates to:
  /// **'Price Category'**
  String get priceCategory;

  /// No description provided for @reservationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Reservations Available'**
  String get reservationsAvailable;

  /// No description provided for @deliveryService.
  ///
  /// In en, this message translates to:
  /// **'Delivery Service'**
  String get deliveryService;

  /// No description provided for @takeout.
  ///
  /// In en, this message translates to:
  /// **'Takeout'**
  String get takeout;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @noMenuInfoAvailable.
  ///
  /// In en, this message translates to:
  /// **'No menu information available'**
  String get noMenuInfoAvailable;

  /// No description provided for @notVisitedYet.
  ///
  /// In en, this message translates to:
  /// **'Not visited yet'**
  String get notVisitedYet;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @visits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get visits;

  /// No description provided for @ticketPrice.
  ///
  /// In en, this message translates to:
  /// **'Admission'**
  String get ticketPrice;

  /// No description provided for @showAllExhibitions.
  ///
  /// In en, this message translates to:
  /// **'Show all exhibitions'**
  String get showAllExhibitions;

  /// No description provided for @myRating.
  ///
  /// In en, this message translates to:
  /// **'My Rating'**
  String get myRating;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @museumInfo.
  ///
  /// In en, this message translates to:
  /// **'Museum Info'**
  String get museumInfo;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @noCurrentExhibitions.
  ///
  /// In en, this message translates to:
  /// **'No current special exhibitions'**
  String get noCurrentExhibitions;

  /// No description provided for @art.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get art;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @nature.
  ///
  /// In en, this message translates to:
  /// **'Natural History'**
  String get nature;

  /// No description provided for @archaeology.
  ///
  /// In en, this message translates to:
  /// **'Archaeology'**
  String get archaeology;

  /// No description provided for @noExhibitionInfoAvailable.
  ///
  /// In en, this message translates to:
  /// **'No exhibition information available'**
  String get noExhibitionInfoAvailable;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @alreadyVisited.
  ///
  /// In en, this message translates to:
  /// **'Already visited'**
  String get alreadyVisited;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @recentVisits.
  ///
  /// In en, this message translates to:
  /// **'Recent Visits'**
  String get recentVisits;

  /// No description provided for @myVisits.
  ///
  /// In en, this message translates to:
  /// **'My Visits'**
  String get myVisits;

  /// No description provided for @publicVisits.
  ///
  /// In en, this message translates to:
  /// **'Public Visits'**
  String get publicVisits;

  /// No description provided for @startExploring.
  ///
  /// In en, this message translates to:
  /// **'Start exploring to see your visits here'**
  String get startExploring;

  /// No description provided for @noPublicVisits.
  ///
  /// In en, this message translates to:
  /// **'No public visits available'**
  String get noPublicVisits;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon - explore what others have discovered'**
  String get comingSoon;

  /// No description provided for @privateVisits.
  ///
  /// In en, this message translates to:
  /// **'Private Visits'**
  String get privateVisits;

  /// No description provided for @publicVisitsPlace.
  ///
  /// In en, this message translates to:
  /// **'Public Visits'**
  String get publicVisitsPlace;

  /// No description provided for @noPrivateVisits.
  ///
  /// In en, this message translates to:
  /// **'No private visits yet'**
  String get noPrivateVisits;

  /// No description provided for @noPublicVisitsForPlace.
  ///
  /// In en, this message translates to:
  /// **'No public visits for this place'**
  String get noPublicVisitsForPlace;

  /// No description provided for @switchToPublic.
  ///
  /// In en, this message translates to:
  /// **'Switch to public visits to see what others shared'**
  String get switchToPublic;

  /// No description provided for @switchToPrivate.
  ///
  /// In en, this message translates to:
  /// **'Switch to private visits to see your personal history'**
  String get switchToPrivate;

  /// No description provided for @publicData.
  ///
  /// In en, this message translates to:
  /// **'Public Data'**
  String get publicData;

  /// No description provided for @privateData.
  ///
  /// In en, this message translates to:
  /// **'Private Data'**
  String get privateData;

  /// No description provided for @privacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose if your visit data should be shared publicly or kept private'**
  String get privacyDescription;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added successfully'**
  String get photoAdded;

  /// No description provided for @photoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Photo removed'**
  String get photoRemoved;

  /// No description provided for @errorLoadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Error loading photo'**
  String get errorLoadingPhoto;

  /// No description provided for @publicDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Your reviews can be seen by others'**
  String get publicDataDescription;

  /// No description provided for @privateDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Only you can see your data'**
  String get privateDataDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
