// lib/screens/collection_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/collection_base.dart';
import '../models/location.dart';
import '../models/restaurant.dart';
import '../models/museum.dart';
import '../models/place.dart';
import '../models/menu_item.dart';
import '../models/visit.dart';
import '../providers/visits_provider.dart';
import '../providers/collections_provider.dart';
import '../utils/default_place_images.dart';
import 'place_detail_factory.dart';


class CollectionDetailScreen extends StatefulWidget {
  final CollectionBase collection;

  const CollectionDetailScreen({
    super.key,
    required this.collection,
  });

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  String searchTerm = '';
  String filterMode = 'all';
  List<Place> _places = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCollectionPlaces();
  }

  Future<void> _loadCollectionPlaces() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final collectionsProvider = Provider.of<CollectionsProvider>(context, listen: false);
      final places = await collectionsProvider.getCollectionPlaces(widget.collection.id);
      
      
      setState(() {
        _places = places;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Place> get filteredPlaces {
    var places = _places.where((place) {
      final matchesSearch = place.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          place.info.address.toLowerCase().contains(searchTerm.toLowerCase());

      switch (filterMode) {
        case 'visited':
          return place.collectionStatus.isVisited && matchesSearch;
        case 'unvisited':
          return !place.collectionStatus.isVisited && matchesSearch;
        default:
          return matchesSearch;
      }
    }).toList();

    return places;
  }

  void _navigateToPlaceDetail(BuildContext context, Place place) async {
    final detailView = PlaceDetailFactory.createDetailView(place);
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => detailView),
    );
    
    // If a visit was created and returned, save it and reload places to update status
    if (result != null && result is Visit && mounted) {
      final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
      await visitsProvider.addVisit(result);
      
      // Reload the collection places to get updated visit status
      await _loadCollectionPlaces();
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.visitSavedAt(place.name)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Place? _convertLocationToPlace(Location location) {
    // For database collections, we need to load the actual Place object
    if (widget.collection.collectionType == 'database') {
      // This will need to be loaded from the collection places
      // For now, return null and let the fallback logic handle it
      return null;
    }
    
    // Fallback to creating Place object from Location (for legacy collections)
    final collectionType = widget.collection.collectionType;
    
    switch (collectionType) {
      case 'restaurant':
        return _createRestaurantFromLocation(location);
      case 'museum':
        return _createMuseumFromLocation(location);
      default:
        return null;
    }
  }

  // Generic helper to get existing visits for any location
  List<Visit> _getExistingVisits(String locationId) {
    final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
    return visitsProvider.getVisitsForPlace(locationId);
  }

  // Generic helper to create collection status based on visits and location data
  PlaceCollectionStatus _createCollectionStatus(Location location, List<Visit> visits) {
    final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
    
    return PlaceCollectionStatus(
      isVisited: visitsProvider.hasVisited(location.id),
      lastVisit: visitsProvider.getLastVisitDate(location.id),
      userRating: visitsProvider.getAverageRating(location.id),
      visitCount: visitsProvider.getVisitCount(location.id),
    );
  }

  Restaurant _createRestaurantFromLocation(Location location) {
    // Determine restaurant type based on location name and collection
    final locationName = location.name.toLowerCase();
    final collectionName = widget.collection.name.toLowerCase();
    
    if (locationName.contains('starbucks') || collectionName.contains('starbucks')) {
      return _createStarbucksFromLocation(location);
    } else if (collectionName.contains('italian') || 
               locationName.contains('italian') ||
               locationName.contains('dolce vita') ||
               locationName.contains('osteria') ||
               locationName.contains('trattoria') ||
               locationName.contains('ristorante') ||
               locationName.contains('pizzeria')) {
      return _createItalianRestaurantFromLocation(location);
    } else {
      return _createMcDonaldsFromLocation(location);
    }
  }

  Restaurant _createMcDonaldsFromLocation(Location location) {
    // Get existing visits for this location
    final existingVisits = _getExistingVisits(location.id);
    // Create McDonald's-specific menu items
    final mcdonaldsMenu = [
      // Burger
      MenuItem(
        id: 'mc_big_mac',
        name: 'Big Mac',
        description: 'Zwei Rindfleisch-Patties, Spezialsoße, Salat, Käse, Zwiebeln und Gewürzgurken auf einem Sesambrötchen',
        price: 5.50,
        category: 'Burger',
      ),
      MenuItem(
        id: 'mc_quarter_pounder',
        name: 'Quarter Pounder with Cheese',
        description: 'Viertel-Pfund-Rindfleisch-Patty mit zwei Scheiben Käse, Zwiebeln, Gewürzgurken, Ketchup und Senf',
        price: 6.20,
        category: 'Burger',
      ),
      MenuItem(
        id: 'mc_cheeseburger',
        name: 'Cheeseburger',
        description: 'Rindfleisch-Patty mit Käse, Zwiebeln, Gewürzgurken, Ketchup und Senf',
        price: 1.50,
        category: 'Burger',
      ),
      MenuItem(
        id: 'mc_mcchicken',
        name: 'McChicken',
        description: 'Knuspriges Hähnchen-Filet mit frischem Salat und Mayo',
        price: 4.20,
        category: 'Burger',
      ),
      
      // Pommes & Beilagen
      MenuItem(
        id: 'mc_fries_small',
        name: 'Pommes frites klein',
        description: 'Goldgelbe, knusprige Pommes frites',
        price: 2.50,
        category: 'Pommes & Beilagen',
      ),
      MenuItem(
        id: 'mc_fries_medium',
        name: 'Pommes frites mittel',
        description: 'Goldgelbe, knusprige Pommes frites',
        price: 3.20,
        category: 'Pommes & Beilagen',
      ),
      MenuItem(
        id: 'mc_nuggets_6',
        name: 'Chicken McNuggets 6er',
        description: 'Sechs knusprige Chicken McNuggets aus 100% Hähnchenfleisch',
        price: 4.50,
        category: 'Pommes & Beilagen',
      ),
      MenuItem(
        id: 'mc_nuggets_20',
        name: 'Chicken McNuggets 20er',
        description: 'Zwanzig knusprige Chicken McNuggets aus 100% Hähnchenfleisch',
        price: 12.90,
        category: 'Pommes & Beilagen',
      ),
      
      // McCafé
      MenuItem(
        id: 'mc_latte',
        name: 'Latte Macchiato',
        description: 'Cremiger Latte Macchiato mit McCafé Premium-Bohnen',
        price: 3.80,
        category: 'McCafé',
      ),
      MenuItem(
        id: 'mc_cappuccino',
        name: 'Cappuccino',
        description: 'Aromatischer Cappuccino mit cremigem Milchschaum',
        price: 3.20,
        category: 'McCafé',
      ),
      MenuItem(
        id: 'mc_muffin_chocolate',
        name: 'Chocolate Chip Muffin',
        description: 'Saftiger Muffin mit Schokoladenstückchen',
        price: 2.80,
        category: 'McCafé',
      ),
      
      // Desserts
      MenuItem(
        id: 'mc_mcflurry_oreo',
        name: 'McFlurry Oreo',
        description: 'Cremiges Softeis mit knusprigen Oreo-Keksstückchen',
        price: 3.50,
        category: 'Desserts',
      ),
      MenuItem(
        id: 'mc_apple_pie',
        name: 'Apfeltasche',
        description: 'Warme, knusprige Apfeltasche mit zimtigen Äpfeln',
        price: 1.80,
        category: 'Desserts',
      ),
      MenuItem(
        id: 'mc_cookies',
        name: 'Cookies',
        description: 'Zwei frisch gebackene Chocolate Chip Cookies',
        price: 1.50,
        category: 'Desserts',
      ),
      
      // Getränke
      MenuItem(
        id: 'mc_coke_medium',
        name: 'Coca-Cola mittel',
        description: 'Erfrischende Coca-Cola',
        price: 2.50,
        category: 'Getränke',
      ),
      MenuItem(
        id: 'mc_orange_juice',
        name: 'Orangensaft',
        description: '100% Orangensaft ohne Zuckerzusatz',
        price: 2.80,
        category: 'Getränke',
      ),
      MenuItem(
        id: 'mc_milkshake_vanilla',
        name: 'Vanille Milkshake',
        description: 'Cremiger Milkshake mit Vanillegeschmack',
        price: 3.20,
        category: 'Getränke',
      ),
    ];

    return Restaurant(
      id: location.id,
      name: location.name,
      cuisine: 'Fast Food', // McDonald's specific
      priceCategory: '€',
      menu: mcdonaldsMenu,
      collectionStatus: _createCollectionStatus(location, existingVisits),
      visits: existingVisits, // Load actual visits from provider
      info: PlaceInfo(
        address: location.address,
        phone: location.phone,
        website: location.website,
        openingHours: location.openingHours != null 
            ? {'monday': location.openingHours!} 
            : {},
        highlights: location.features,
      ),
      hasReservation: false, // McDonald's typically doesn't take reservations
      hasDelivery: true,     // McDonald's has delivery
      hasTakeout: true,      // McDonald's has takeout
    );
  }

  Restaurant _createStarbucksFromLocation(Location location) {
    // Get existing visits for this location
    final existingVisits = _getExistingVisits(location.id);
    // Create Starbucks-specific menu items
    final starbucksMenu = [
      // Kaffee
      MenuItem(
        id: 'sb_pike_place',
        name: 'Pike Place Roast',
        description: 'Ausgewogener Kaffee mit milden Noten von Kakao und gerösteten Nüssen',
        price: 2.80,
        category: 'Kaffee',
      ),
      MenuItem(
        id: 'sb_americano',
        name: 'Caffè Americano',
        description: 'Espresso mit heißem Wasser, reich und vollmundig',
        price: 3.20,
        category: 'Kaffee',
      ),
      MenuItem(
        id: 'sb_latte',
        name: 'Caffè Latte',
        description: 'Espresso mit gedämpfter Milch und einer dünnen Schicht Milchschaum',
        price: 4.50,
        category: 'Kaffee',
      ),
      MenuItem(
        id: 'sb_cappuccino',
        name: 'Cappuccino',
        description: 'Espresso mit gedämpfter Milch und reichlich Milchschaum',
        price: 4.20,
        category: 'Kaffee',
      ),
      MenuItem(
        id: 'sb_macchiato',
        name: 'Caramel Macchiato',
        description: 'Espresso mit Vanillesirup, gedämpfter Milch und Karamellsauce',
        price: 5.20,
        category: 'Kaffee',
      ),

      // Frappuccino
      MenuItem(
        id: 'sb_frap_caramel',
        name: 'Caramel Frappuccino',
        description: 'Kaffee-Frappuccino mit Karamellsirup und Schlagsahne',
        price: 5.80,
        category: 'Frappuccino',
      ),
      MenuItem(
        id: 'sb_frap_mocha',
        name: 'Mocha Frappuccino',
        description: 'Kaffee-Frappuccino mit Schokoladensirup und Schlagsahne',
        price: 5.60,
        category: 'Frappuccino',
      ),
      MenuItem(
        id: 'sb_frap_vanilla',
        name: 'Vanilla Frappuccino',
        description: 'Kaffee-Frappuccino mit Vanillesirup und Schlagsahne',
        price: 5.40,
        category: 'Frappuccino',
      ),

      // Tee
      MenuItem(
        id: 'sb_green_tea',
        name: 'Green Tea Latte',
        description: 'Matcha-Grüntee mit gedämpfter Milch',
        price: 4.80,
        category: 'Tee',
      ),
      MenuItem(
        id: 'sb_chai_latte',
        name: 'Chai Tea Latte',
        description: 'Würziger Chai-Tee mit gedämpfter Milch',
        price: 4.60,
        category: 'Tee',
      ),
      MenuItem(
        id: 'sb_earl_grey',
        name: 'Earl Grey',
        description: 'Klassischer Earl Grey Tee mit Bergamotte',
        price: 2.90,
        category: 'Tee',
      ),

      // Snacks
      MenuItem(
        id: 'sb_croissant',
        name: 'Butter Croissant',
        description: 'Frisches, buttriges Croissant',
        price: 3.20,
        category: 'Snacks',
      ),
      MenuItem(
        id: 'sb_muffin_blueberry',
        name: 'Blueberry Muffin',
        description: 'Saftiger Muffin mit frischen Blaubeeren',
        price: 3.80,
        category: 'Snacks',
      ),
      MenuItem(
        id: 'sb_sandwich',
        name: 'Turkey & Swiss Sandwich',
        description: 'Sandwich mit Truthahn, Schweizer Käse und frischem Gemüse',
        price: 6.50,
        category: 'Snacks',
      ),
      MenuItem(
        id: 'sb_cookie',
        name: 'Double Chocolate Cookie',
        description: 'Schokoladenkeks mit Schokoladenstückchen',
        price: 2.50,
        category: 'Snacks',
      ),

      // Getränke (kalt)
      MenuItem(
        id: 'sb_iced_coffee',
        name: 'Iced Coffee',
        description: 'Kalter Kaffee mit Eis',
        price: 3.50,
        category: 'Kalte Getränke',
      ),
      MenuItem(
        id: 'sb_cold_brew',
        name: 'Cold Brew',
        description: 'Kalt extrahierter Kaffee, mild und süßlich',
        price: 3.80,
        category: 'Kalte Getränke',
      ),
      MenuItem(
        id: 'sb_refresher',
        name: 'Strawberry Açaí Refresher',
        description: 'Erfrischender Açaí-Drink mit Erdbeeren',
        price: 4.20,
        category: 'Kalte Getränke',
      ),
    ];

    return Restaurant(
      id: location.id,
      name: location.name,
      cuisine: 'Café', // Starbucks specific
      priceCategory: '€€',
      menu: starbucksMenu,
      collectionStatus: _createCollectionStatus(location, existingVisits),
      visits: existingVisits, // Load actual visits from provider
      info: PlaceInfo(
        address: location.address,
        phone: location.phone,
        website: location.website,
        openingHours: location.openingHours != null 
            ? {'monday-friday': location.openingHours!} 
            : {},
        highlights: location.features,
      ),
      hasReservation: false, // Starbucks typically doesn't take reservations
      hasDelivery: true,     // Starbucks has delivery
      hasTakeout: true,      // Starbucks has takeout
    );
  }

  Restaurant _createItalianRestaurantFromLocation(Location location) {
    final existingVisits = _getExistingVisits(location.id);
    final italianMenu = [
      // Antipasti
      MenuItem(
        id: 'it_bruschetta',
        name: 'Bruschetta Classica',
        description: 'Geröstetes Brot mit frischen Tomaten, Basilikum und Knoblauch',
        price: 7.50,
        category: 'Antipasti',
      ),
      MenuItem(
        id: 'it_antipasto_misto',
        name: 'Antipasto Misto',
        description: 'Gemischte italienische Vorspeisen mit Oliven, Käse und Salami',
        price: 12.90,
        category: 'Antipasti',
      ),
      MenuItem(
        id: 'it_carpaccio',
        name: 'Carpaccio di Manzo',
        description: 'Hauchdünnes Rindfleisch mit Rucola, Parmesan und Zitrone',
        price: 14.50,
        category: 'Antipasti',
      ),

      // Pizza
      MenuItem(
        id: 'it_margherita',
        name: 'Pizza Margherita',
        description: 'Tomatensoße, Mozzarella und frisches Basilikum',
        price: 9.50,
        category: 'Pizza',
      ),
      MenuItem(
        id: 'it_quattro_stagioni',
        name: 'Pizza Quattro Stagioni',
        description: 'Tomatensoße, Mozzarella, Schinken, Champignons, Artischocken und Oliven',
        price: 13.90,
        category: 'Pizza',
      ),
      MenuItem(
        id: 'it_diavola',
        name: 'Pizza Diavola',
        description: 'Tomatensoße, Mozzarella und scharfe Salami',
        price: 12.50,
        category: 'Pizza',
      ),
      MenuItem(
        id: 'it_prosciutto',
        name: 'Pizza Prosciutto e Funghi',
        description: 'Tomatensoße, Mozzarella, Schinken und Champignons',
        price: 12.90,
        category: 'Pizza',
      ),

      // Pasta
      MenuItem(
        id: 'it_carbonara',
        name: 'Spaghetti Carbonara',
        description: 'Spaghetti mit Ei, Speck, Parmesan und schwarzem Pfeffer',
        price: 11.90,
        category: 'Pasta',
      ),
      MenuItem(
        id: 'it_amatriciana',
        name: 'Spaghetti all\'Amatriciana',
        description: 'Spaghetti mit Tomatensoße, Speck und Pecorino',
        price: 12.50,
        category: 'Pasta',
      ),
      MenuItem(
        id: 'it_aglio_olio',
        name: 'Spaghetti Aglio e Olio',
        description: 'Spaghetti mit Olivenöl, Knoblauch und Chili',
        price: 9.90,
        category: 'Pasta',
      ),
      MenuItem(
        id: 'it_penne_arrabbiata',
        name: 'Penne all\'Arrabbiata',
        description: 'Penne mit scharfer Tomatensoße und Basilikum',
        price: 10.90,
        category: 'Pasta',
      ),
      MenuItem(
        id: 'it_lasagne',
        name: 'Lasagne della Casa',
        description: 'Hausgemachte Lasagne mit Hackfleischsoße und Béchamel',
        price: 13.90,
        category: 'Pasta',
      ),

      // Dolci
      MenuItem(
        id: 'it_tiramisu',
        name: 'Tiramisù',
        description: 'Klassisches Tiramisù mit Mascarpone und Espresso',
        price: 6.50,
        category: 'Dolci',
      ),
      MenuItem(
        id: 'it_panna_cotta',
        name: 'Panna Cotta',
        description: 'Italienische Sahnespeise mit Beerensauce',
        price: 5.90,
        category: 'Dolci',
      ),
      MenuItem(
        id: 'it_gelato',
        name: 'Gelato Misto',
        description: 'Drei Kugeln italienisches Eis nach Wahl',
        price: 4.50,
        category: 'Dolci',
      ),

      // Vino
      MenuItem(
        id: 'it_chianti',
        name: 'Chianti Classico',
        description: 'Italienischer Rotwein aus der Toskana (0,25l)',
        price: 6.90,
        category: 'Vino',
      ),
      MenuItem(
        id: 'it_prosecco',
        name: 'Prosecco',
        description: 'Italienischer Schaumwein (0,1l)',
        price: 4.50,
        category: 'Vino',
      ),
      MenuItem(
        id: 'it_limoncello',
        name: 'Limoncello',
        description: 'Italienischer Zitronenlikör (4cl)',
        price: 3.90,
        category: 'Vino',
      ),
    ];

    return Restaurant(
      id: location.id,
      name: location.name,
      cuisine: 'Italienisch',
      priceCategory: '€€',
      menu: italianMenu,
      collectionStatus: _createCollectionStatus(location, existingVisits),
      visits: existingVisits,
      info: PlaceInfo(
        address: location.address,
        phone: location.phone,
        website: location.website,
        openingHours: location.openingHours != null 
            ? {'daily': location.openingHours!} 
            : {},
        highlights: location.features,
      ),
      hasReservation: true,  // Italian restaurants typically take reservations
      hasDelivery: true,
      hasTakeout: true,
    );
  }


  Museum _createMuseumFromLocation(Location location) {
    // Get existing visits for this location
    final existingVisits = _getExistingVisits(location.id);
    
    // Determine museum type based on collection and location name
    final collectionName = widget.collection.name.toLowerCase();
    final locationName = location.name.toLowerCase();
    
    if (collectionName.contains('kunst') || collectionName.contains('art') ||
        locationName.contains('art') || locationName.contains('kunst')) {
      return _createArtMuseum(location, existingVisits);
    } else if (collectionName.contains('wissenschaft') || collectionName.contains('science') ||
               locationName.contains('science') || locationName.contains('odysseum') ||
               locationName.contains('sport') || locationName.contains('chocolate')) {
      return _createScienceMuseum(location, existingVisits);
    } else {
      return _createGeneralMuseum(location, existingVisits);
    }
  }

  Museum _createGeneralMuseum(Location location, List<Visit> existingVisits) {
    // Default museum with mixed collections
    List<String> exhibitions = [];
    List<String> collections = [];
    String ticketPrice = '€12 / €6 ermäßigt';
    String category = 'mixed';
    
    if (location.name.contains('Ludwig')) {
      exhibitions = ['Pop Art', 'Picasso Retrospektive'];
      collections = ['Moderne Kunst', 'Expressionismus', 'Pop Art'];
      ticketPrice = '€13 / €8.50 ermäßigt';
      category = 'art';
    } else if (location.name.contains('Wallraf')) {
      exhibitions = ['Barock Meister', 'Mittelalterliche Kunst'];
      collections = ['Alte Meister', 'Mittelalterliche Kunst'];
      ticketPrice = '€10 / €6 ermäßigt';
      category = 'art';
    } else if (location.name.contains('Romano')) {
      exhibitions = ['Römische Funde 2024', 'Gladiatoren'];
      collections = ['Römische Mosaike', 'Antike Skulpturen'];
      ticketPrice = '€6 / €3 ermäßigt';
      category = 'history';
    } else {
      exhibitions = ['Wechselausstellung 2024'];
      collections = ['Dauerausstellung'];
    }
    
    return Museum(
      id: location.id,
      name: location.name,
      category: category,
      currentExhibitions: exhibitions,
      permanentCollections: collections,
      ticketPrice: ticketPrice,
      collectionStatus: _createCollectionStatus(location, existingVisits),
      visits: existingVisits,
      info: PlaceInfo(
        address: location.address,
        phone: location.phone,
        website: location.website,
        openingHours: location.openingHours != null 
            ? {'tuesday-sunday': location.openingHours!} 
            : {},
        highlights: location.features,
      ),
      hasAudioGuide: true,
      hasGiftShop: true,
      isWheelchairAccessible: false,
    );
  }

  Museum _createArtMuseum(Location location, List<Visit> existingVisits) {
    List<String> exhibitions = [];
    List<String> collections = [];
    String ticketPrice = '€15 / €8 ermäßigt';
    
    if (location.name.contains('Angewandte Kunst')) {
      exhibitions = ['Design Now', 'Zeitgenössisches Handwerk'];
      collections = ['Design Sammlung', 'Keramik', 'Textilien'];
      ticketPrice = '€8 / €5 ermäßigt';
    } else if (location.name.contains('Kunstverein')) {
      exhibitions = ['Emerging Artists', 'Neue Medien'];
      collections = ['Zeitgenössische Sammlung'];
      ticketPrice = '€6 / €3 ermäßigt';
    } else if (location.name.contains('Käthe Kollwitz')) {
      exhibitions = ['Kollwitz und Zeitgenossen'];
      collections = ['Käthe Kollwitz Werke', 'Deutsche Expressionisten'];
      ticketPrice = '€7 / €4 ermäßigt';
    } else {
      exhibitions = ['Moderne Kunst 2024', 'Abstrakte Kunst'];
      collections = ['Zeitgenössische Sammlung', 'Moderne Klassiker'];
    }
    
    return Museum(
      id: location.id,
      name: location.name,
      category: 'art',
      currentExhibitions: exhibitions,
      permanentCollections: collections,
      ticketPrice: ticketPrice,
      collectionStatus: _createCollectionStatus(location, existingVisits),
      visits: existingVisits,
      info: PlaceInfo(
        address: location.address,
        phone: location.phone,
        website: location.website,
        openingHours: location.openingHours != null 
            ? {'tuesday-sunday': location.openingHours!} 
            : {},
        highlights: location.features,
      ),
      hasAudioGuide: true,
      hasGiftShop: location.name.contains('Kollwitz') ? false : true,
      isWheelchairAccessible: true,
    );
  }

  Museum _createScienceMuseum(Location location, List<Visit> existingVisits) {
    List<String> exhibitions = [];
    List<String> collections = [];
    String ticketPrice = '€16 / €10 ermäßigt';
    
    if (location.name.contains('Odysseum')) {
      exhibitions = ['Weltraum Expedition', 'Zukunft der Energie'];
      collections = ['Interaktive Physik', 'Planetarium', 'Life Science'];
      ticketPrice = '€18.50 / €13.50 ermäßigt';
    } else if (location.name.contains('Sport')) {
      exhibitions = ['Olympische Spiele 2024', 'Fußball WM Historie'];
      collections = ['Sportgeschichte', 'Olympische Sammlung', 'Deutsche Sportler'];
      ticketPrice = '€14 / €9 ermäßigt';
    } else if (location.name.contains('Chocolate') || location.name.contains('Schokolade')) {
      exhibitions = ['Kakao Weltweit', 'Süße Innovationen'];
      collections = ['Schokoladen Geschichte', 'Produktionsprozess', 'Kakao Anbau'];
      ticketPrice = '€13.50 / €9 ermäßigt';
    } else {
      exhibitions = ['Wissenschaft Interaktiv', 'Technik der Zukunft'];
      collections = ['Naturwissenschaften', 'Technik Museum'];
    }
    
    return Museum(
      id: location.id,
      name: location.name,
      category: 'science',
      currentExhibitions: exhibitions,
      permanentCollections: collections,
      ticketPrice: ticketPrice,
      collectionStatus: _createCollectionStatus(location, existingVisits),
      visits: existingVisits,
      info: PlaceInfo(
        address: location.address,
        phone: location.phone,
        website: location.website,
        openingHours: location.openingHours != null 
            ? {'daily': location.openingHours!} 
            : {},
        highlights: location.features,
      ),
      hasAudioGuide: location.name.contains('Chocolate') ? false : true,
      hasGiftShop: true, // Science museums typically have good gift shops
      isWheelchairAccessible: true, // Modern science museums are usually accessible
    );
  }

  Color get brandColor {
    switch (widget.collection.iconEmoji) {
      case '🍟': // McDonald's
        return const Color(0xFFEF4444);
      case '☕': // Starbucks
        return const Color(0xFF10B981);
      case '🏛️': // Museums
        return const Color(0xFF8B5CF6);
      case '🎨': // Art Museums
        return const Color(0xFFF59E0B);
      case '🔬': // Science Museums
        return const Color(0xFF3B82F6);
      case '🍝': // Italian Restaurants
        return const Color(0xFF059669);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visitedCount = _places.where((p) => p.collectionStatus.isVisited).length;
    final totalCount = _places.length;
    final progressPercentage = totalCount > 0 ? (visitedCount / totalCount) * 100 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Back Button und Info
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.collection.iconEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.collection.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.visitedCount(visitedCount, totalCount),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.collectingProgress),
                      Text('${progressPercentage.toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(brandColor),
                  ),
                  const SizedBox(height: 16),

                  // Search
                  TextField(
                    onChanged: (value) => setState(() => searchTerm = value),
                    decoration: InputDecoration(
                      hintText: l10n.searchLocations,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => filterMode = 'all'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filterMode == 'all' ? brandColor : Colors.grey[300],
                            foregroundColor: filterMode == 'all' ? Colors.white : Colors.black,
                          ),
                          child: Text(l10n.allCount(totalCount)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => filterMode = 'visited'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filterMode == 'visited' ? Colors.green : Colors.grey[300],
                            foregroundColor: filterMode == 'visited' ? Colors.white : Colors.black,
                          ),
                          child: Text(l10n.collectedCount(visitedCount)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => filterMode = 'unvisited'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filterMode == 'unvisited' ? Colors.grey : Colors.grey[300],
                            foregroundColor: filterMode == 'unvisited' ? Colors.white : Colors.black,
                          ),
                          child: Text(l10n.openCount(totalCount - visitedCount)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading places:\n$_error',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadCollectionPlaces,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : filteredPlaces.isEmpty
                          ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noLocationsFound,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tryDifferentSearch,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];
                    
                    return PlaceTile(
                      place: place,
                      onTap: () => _navigateToPlaceDetail(context, place),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  final Location location;
  final VoidCallback onTap;
  final VoidCallback? onMarkVisited;
  final String? placeType;

  const LocationTile({
    super.key,
    required this.location,
    required this.onTap,
    this.onMarkVisited,
    this.placeType,
  });

  IconData get _placeholderIcon {
    switch (placeType?.toLowerCase()) {
      case 'museum':
        return Icons.account_balance;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Foto oder Placeholder
              location.imageUrls.isNotEmpty
                  ? ColorFiltered(
                colorFilter: location.isVisited
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                    : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                child: Image.network(
                  location.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(_placeholderIcon, size: 32),
                    );
                  },
                ),
              )
                  : Container(
                color: Colors.grey[300],
                child: Icon(_placeholderIcon, size: 32),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Besucht Badge
              if (location.isVisited)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),

              // Text unten
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      location.name.split(' ').last, // Nur letzter Teil des Namens
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      location.shortAddress,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (location.isVisited)
                      Text(
                        l10n.visitedToday,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              // Only show tap-to-mark overlay if manual marking is enabled
              if (!location.isVisited && onMarkVisited != null)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onMarkVisited,
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Text(
                            l10n.markAsVisited,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// PlaceTile widget for displaying places in the grid
class PlaceTile extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const PlaceTile({
    super.key,
    required this.place,
    required this.onTap,
  });

  IconData get _placeholderIcon {
    switch (place.type.toLowerCase()) {
      case 'museum':
        return Icons.museum;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with enhanced default image
              ColorFiltered(
                colorFilter: place.collectionStatus.isVisited
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                    : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                child: DefaultPlaceImages.buildPlaceImage(
                  placeType: place.type,
                  placeName: place.name,
                  imageUrl: place.imageUrl,
                  emoji: place.emoji,
                  fit: BoxFit.cover,
                ),
              ),
              
              // Overlay with place info
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              
              // Content
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (place.collectionStatus.visitCount > 0)
                      Text(
                        '${place.collectionStatus.visitCount}x visited',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Visit status indicator
              if (place.collectionStatus.isVisited)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}