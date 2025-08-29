## Place Creation System Architecture

### **Core Concept**
- **`Place`** is the **abstract interface** that all location types implement
- **`Restaurant`** and **`Museum`** are **specific implementations** of Place
- Users can create **any type of Place**, with Restaurant and Museum being specialized options
- System is designed for easy extension to new place types (Hotels, Parks, etc.)

### **Place Creation Flow**
```
User clicks "Create Place" 
    ↓
PlaceTypeSelectionDialog appears (`place_type_selection_dialog.dart`)
    ↓ 
User selects "Restaurant" or "Museum"
    ↓
Specialized creation dialog opens:
- CreateRestaurantDialog (4-step comprehensive process)
- CreateMuseumDialog (museum-specific fields)
    ↓
Form data is validated and sent to API
    ↓
API creates place in PostgreSQL database
    ↓
Place appears in app immediately and persists permanently
```

### **Restaurant Creation System (4 Steps)**
**CreateRestaurantDialog** (`create_restaurant_dialog.dart`):
1. **Basic Info**: Name, address, photos, collection selection
2. **Restaurant Details**: Cuisine, price range, services, highlights
3. **Contact Info**: Phone, website, email, opening hours
4. **Menu Creation**: Full menu system with items, categories, allergens, dietary info

**Menu Creation Features**:
- Add individual menu items with name, description, price, category
- Set dietary restrictions (Vegetarian, Vegan, Gluten-Free)
- Select from 12 common allergens
- 13 menu categories available
- Visual menu item management with add/remove functionality

### **Authentication System**
- **Auto-login for testing**: App automatically logs in as `user@web.com` (password: `123456`)
- **AuthProvider**: Handles authentication state management
- **MockAuthService**: Simulates authentication for development

## Interface Structure Overview

### Screen Architecture

#### Place Detail System
The app uses a factory pattern for place detail views:

1. **PlaceDetailFactory** (`place_detail_factory.dart`)
   - Routes Place objects to appropriate detail views based on place.type
   - Supports: 'restaurant', 'museum'
   - Returns RestaurantDetailView for restaurants, MuseumDetailView for museums
   - Extensible for new place types

2. **PlaceDetailViewInterface** (`place_detail_view_interface.dart`) 
   - Abstract base class that all place detail views extend
   - Defines common interface methods that must be implemented:
     - `buildSpecialTab()` - Place-specific content tab
     - `getSpecificStats()` - Place-specific statistics
     - `getOverviewContent()` - Overview tab content
     - `getFloatingActionButton()` - Place-specific FAB

3. **GenericPlaceDetailView** (in same file)
   - Generic container that wraps all place detail views
   - Provides common UI structure:
     - Hero section with place emoji/name
     - Collection status bar with visit stats
     - Bottom navigation with 4 tabs: Overview, Special, Visits, Info
     - Floating action button from specific implementation

#### Restaurant Detail Implementation
**RestaurantDetailView** (`place_detail_implementations/restaurant_detail_view.dart`):

**Tabs Structure:**
- **Overview Tab**: Restaurant info, quick menu preview, cuisine/price card, add visit button
- **Menu Tab** (Special): Full categorized menu with detailed dish information
- **Visits Tab**: User visits vs. other users' visits with toggle
- **Info Tab**: Address, opening hours, contact information

**Key Features:**
- Categorized menu display with emojis per category
- Dish details with dietary labels (vegan, vegetarian, gluten-free)
- Price formatting and average calculations
- Visit management with photo support
- Privacy controls (public/private visits)

### **Data Models**

#### Place Interface (`place.dart`)
- **Abstract base class** that all place types implement
- **Common properties**: id, name, type, emoji, collectionStatus, visits, info
- **Required methods**: toJson(), copyWith(), specialData getter
- **PlaceInfo**: address, phone, website, email, openingHours, highlights, priceRange
- **PlaceCollectionStatus**: visit tracking, ratings, visit counts

#### Restaurant Model (`restaurant.dart`)
- **Implements Place interface**
- **Specific properties**: cuisine, priceCategory, menu, hasReservation, hasDelivery, hasTakeout
- **Menu system**: List of MenuItem objects with full details

#### MenuItem Model (`menu_item.dart`)
- **Complete menu item data**: name, description, price, category
- **Dietary info**: isVegetarian, isVegan, isGlutenFree flags
- **Allergen tracking**: List of allergen strings
- **Additional data**: imageUrl, userRating
- **Utility methods**: formattedPrice, dietaryLabels, hasDietaryRestrictions

### **Key System Features**
- **✅ Database-Integrated Place Creation**: Places created through dialogs are saved permanently to PostgreSQL
- **No more default McDonald's menu**: Restaurants now use their own created menus
- **Comprehensive data capture**: All PlaceInfo fields are collected during creation including coordinates, menu items, and special data
- **Type-safe place system**: Factory pattern ensures proper type handling
- **Real API Integration**: PlacesProvider uses ApiService to communicate with Node.js backend
- **Extensible architecture**: Easy to add new place types (Parks, Hotels, etc.)
- **Persistent Data**: Created places survive app restarts and appear in all collections immediately

#### Visit System
- **Visit Model**: Comprehensive visit tracking with photos, ratings, activities, metadata
- **Visits Provider**: State management for visit operations
- **Add Visit Dialogs**: Place-specific visit creation forms

#### UI Patterns
- Card-based layouts throughout
- Consistent color scheme (green for restaurants)
- Material Design components
- Responsive layouts with proper spacing
- Icon + text patterns for information display

## Database Architecture

### **PostgreSQL Database Setup**
- **Container:** Docker container `collections-db` on port **5433**
- **Connection:** localhost:5433, user: `collections_user`, password: `password123`
- **Database:** `collections_app`
- **Access:** TablePlus compatible, PostgreSQL 15

### **Database Schema**

#### Core Tables
```sql
-- Users
users: id(UUID), email, password_hash, display_name, created_at, updated_at

-- Places (Restaurants & Museums)
places: id(UUID), name, type, emoji, address, phone, website, email, 
        opening_hours(JSONB), highlights(TEXT[]), price_range, 
        special_data(JSONB), created_at, updated_at

-- Menu Items (for restaurants)
menu_items: id(UUID), place_id(FK), name, description, price, category,
            allergens(TEXT[]), is_vegetarian, is_vegan, is_gluten_free,
            image_url, created_at, updated_at

-- User Place Status (collection tracking)
user_place_status: id(UUID), user_id(FK), place_id(FK), is_visited, 
                   last_visit, user_rating, visit_count, created_at, updated_at

-- Visits (user visit tracking)
visits: id(UUID), user_id(FK), place_id(FK), date, place_type, 
        overall_rating, notes, duration_minutes, total_cost,
        metadata(JSONB), photo_urls(TEXT[]), is_public, created_at, updated_at

-- Visit Activities (dishes eaten, exhibitions seen)
visit_activities: id(UUID), visit_id(FK), name, type, rating,
                  activity_data(JSONB), created_at, updated_at

-- Exhibitions (museum exhibitions)
exhibitions: id(UUID), museum_id(FK), name, description, exhibition_type,
             start_date, end_date, artist, period, category, is_active,
             ticket_required, additional_cost, image_url, website_url,
             created_at, updated_at
```

#### Key Design Features
- **UUID primary keys** for scalability and distribution
- **JSONB fields** for flexible polymorphic data (special_data, metadata, opening_hours)
- **Array fields** for lists (allergens, photo_urls, highlights)
- **Foreign key constraints** with CASCADE deletes
- **Performance indexes** on commonly queried fields
- **Check constraints** for data validation (ratings 1.0-5.0)
- **Automatic timestamps** via triggers

### **Sample Data (Production-Ready)**

#### Restaurants (9 total)
- **5 General Italian restaurants:** Terra Rossa, Restaurant Ruland, eat italian Bonn, L'Osteria Bonn, La Piazza
- **4 User's favorite places:** Tuscolo Münsterblick, Tuscolo Frankenbad, Spacca Napoli, Via Roma
- **46 menu items total** with authentic German descriptions, dietary info, allergens
- **Price range:** €5.90 - €32.90, average €13.50

#### Museums (10 total) 
- **Art Museums (3):** Kunstmuseum Bonn, Bundeskunsthalle, August-Macke-Haus
- **History Museums (2):** Haus der Geschichte, Stadtmuseum Bonn
- **Technology Museums (2):** Arithmeum, Deutsches Museum Bonn  
- **Specialty Museums (3):** LVR-Landesmuseum Bonn (archaeology), Beethoven-Haus (music), Museum Koenig (natural history)
- **33 exhibitions total:** 25 permanent, 6 temporary, 2 special
- **Price range:** Free to €15, most around €6-8

#### User Data
- **Test user:** user@web.com 
- **Visit history:** 6 total visits (3 restaurants, 3 museums)
- **Favorites tracking:** High visit counts for Spacca Napoli (12 visits), Tuscolo (8 visits), Via Roma (6 visits)
- **Ratings:** 4.2 - 4.9 stars with detailed personal notes

### **Migration & Deployment**
- **Local Development:** Docker container on port 5433
- **Production Migration:** Easy pg_dump/pg_restore to cloud providers
- **Backup Strategy:** `docker exec collections-db pg_dump -U collections_user -d collections_app > backup.sql`
- **Scalability:** Ready for cloud deployment (Supabase, Railway, AWS RDS)

## API Architecture

### **Node.js REST API Server**
- **Technology Stack:** Node.js + Express.js + PostgreSQL
- **Server:** `api/server.js` running on **port 8080**
- **Base URL:** `http://localhost:8080/api/v1`
- **Documentation:** `http://localhost:8080/api`
- **Health Check:** `http://localhost:8080/api/health`

### **API Structure**
```
api/
├── server.js           # Main Express server
├── database.js         # PostgreSQL connection pool
├── package.json        # Dependencies (express, pg, cors, helmet)
├── .env               # Environment configuration
└── routes/
    ├── places.js      # Places endpoints (restaurants & museums)
    ├── visits.js      # Visit tracking and creation
    ├── user.js        # User-specific data and favorites
    └── exhibitions.js # Museum exhibitions management
```

### **Core API Endpoints**

#### Places & Restaurants
- `GET /api/v1/places` - All places with stats
- `GET /api/v1/places?type=restaurant` - Restaurants only
- `GET /api/v1/places?type=museum` - Museums only
- `GET /api/v1/places?search=pizza` - Search functionality
- `GET /api/v1/places/:id` - Single place with detailed info
- `GET /api/v1/places/:id/menu` - Restaurant menu items
- **`POST /api/v1/places`** - **✅ Create new places (restaurants & museums)**

#### User & Favorites
- `GET /api/v1/user/:userId/places` - User's collection status
- `GET /api/v1/user/:userId/favorites` - Most visited places
- `GET /api/v1/user/:userId/stats` - User statistics

#### Visits & Activities  
- `GET /api/v1/visits` - All visits with filtering
- `GET /api/v1/visits/:id` - Single visit with activities
- `POST /api/v1/visits` - Create visit with activities
- Automatic user_place_status updates

#### Museums & Exhibitions
- `GET /api/v1/exhibitions` - All exhibitions
- `GET /api/v1/exhibitions?type=temporary` - Filter by type
- `GET /api/v1/exhibitions/museum/:museumId` - Museum exhibitions
- `GET /api/v1/exhibitions/:id` - Single exhibition details

### **API Features**
- **Security:** Helmet, CORS for Flutter, rate limiting
- **Performance:** Connection pooling, proper indexing
- **Error Handling:** Comprehensive error responses
- **Data Validation:** Input validation and constraints
- **Transactions:** Safe visit creation with rollback
- **Statistics:** Real-time aggregated stats

### **Flutter Integration Ready**
```dart
class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  
  // Development URLs  
  static const String devWeb = 'http://localhost:3000/api/v1';
  static const String devAndroid = 'http://192.168.0.143:3000/api/v1';
  
  // Read operations
  static Future<List<Place>> getPlaces({String? type}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/places${type != null ? '?type=$type' : ''}')
    );
    return PlaceFactory.fromJsonList(jsonDecode(response.body)['data']);
  }
  
  // ✅ Create operations
  static Future<Restaurant> createRestaurant({
    required String name,
    required String address,
    required String cuisine,
    // ... all restaurant parameters
    List<Map<String, dynamic>>? menuItems,
  }) async {
    final placeData = {
      'name': name,
      'type': 'restaurant',
      'address': address,
      'specialData': {'cuisine': cuisine, ...},
      'menuItems': menuItems ?? [],
    };
    final place = await createPlace(placeData);
    return place as Restaurant;
  }
}
```

### **Place Creation API Implementation**

#### **Backend Implementation (`api/routes/places.js`)**
- **POST /api/v1/places** endpoint with full transaction support
- **Input validation**: name, type, address required fields
- **Place type validation**: Only 'restaurant' and 'museum' accepted  
- **Database transactions**: BEGIN/COMMIT/ROLLBACK for data consistency
- **Menu item insertion**: Automatically inserts menu items for restaurants
- **Response format**: Returns created place in consistent API format
- **Error handling**: Comprehensive error responses with rollback on failure

#### **Frontend Implementation**

**PlacesProvider** (`lib/providers/places_provider.dart`):
- `createRestaurant()` - Restaurant creation with menu items
- `createMuseum()` - Museum creation with exhibitions data
- `createPlace()` - General place creation method
- **State management**: Updates local lists and notifies listeners
- **Error handling**: Loading states and error messaging

**ApiService** (`lib/services/api_service.dart`):
- `createPlace()` - General API call with response parsing
- `createRestaurant()` - Restaurant-specific creation
- `createMuseum()` - Museum-specific creation  
- **Data formatting**: Converts Flutter models to API format
- **Response parsing**: Converts API responses back to Place objects

**Creation Dialogs**:
- **CreateRestaurantDialog**: Uses `PlacesProvider.createRestaurant()`
- **CreateMuseumDialog**: Uses `PlacesProvider.createMuseum()`
- **Real API calls**: No more simulation with `Future.delayed`
- **Immediate feedback**: Places appear in collections instantly
- **Persistent data**: Survives app restarts and device switches

#### **Data Flow**
```
User Form → PlacesProvider → ApiService → POST /api/v1/places → PostgreSQL
                                                                      ↓
App State ← Place Object ← API Response ← Database Insert Response ←
```

### **Production Deployment**
- **Current:** Local development server
- **Migration Path:** Vercel, Railway, Heroku ready
- **Configuration:** Environment-based (.env)
- **Database:** Same PostgreSQL structure
- **CORS:** Configured for production domains