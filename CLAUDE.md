- currently the app uses a placeholder when clicking on a specific restaurant. can we use the restaurant detail view in the mcdonalds collection? create dummy data fitting a mc donalds for this views

## Interface Structure Overview

### Screen Architecture

#### Place Detail System
The app uses a factory pattern for place detail views:

1. **PlaceDetailFactory** (`place_detail_factory.dart`)
   - Creates appropriate detail views based on place type
   - Supports: 'restaurant', 'museum'
   - Falls back to placeholder for unsupported types

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