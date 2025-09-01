# Collections API

REST API for the Collections App - serving places, restaurants, museums, visits, and exhibitions data from Bonn.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Or start production server
npm start
```

**API Base URL:** `http://localhost:8080/api/v1`

## 📊 API Endpoints

### Places
- `GET /places` - All places (restaurants & museums)
- `GET /places?type=restaurant` - Restaurants only
- `GET /places?type=museum` - Museums only  
- `GET /places?search=pizza` - Search places
- `GET /places/:id` - Single place with detailed info
- `GET /places/:id/menu` - Restaurant menu items

### User Data
- `GET /user/:userId/places` - User's places with collection status
- `GET /user/:userId/favorites` - User's most visited places
- `GET /user/:userId/stats` - User statistics

### Visits
- `GET /visits` - All visits
- `GET /visits?userId=:id` - User's visits
- `GET /visits?placeId=:id` - Visits for specific place
- `GET /visits/:id` - Single visit with activities
- `POST /visits` - Create new visit

### Exhibitions
- `GET /exhibitions` - All exhibitions
- `GET /exhibitions?type=temporary` - Temporary exhibitions only
- `GET /exhibitions/museum/:museumId` - Museum exhibitions
- `GET /exhibitions/:id` - Single exhibition details

## 🏠 Sample Data

The API serves real data from Bonn:

### Restaurants (9 total)
- **Your favorites:** Spacca Napoli (12 visits), Tuscolo Münsterblick (8 visits), Via Roma (6 visits)
- **Others:** Terra Rossa, Restaurant Ruland, L'Osteria Bonn, etc.
- **46 menu items** with prices, dietary info, allergens

### Museums (10 total)  
- **Beethoven-Haus Bonn** - Original Moonlight Sonata manuscript
- **Museum Koenig** - Natural history with Neandertaler
- **Kunstmuseum Bonn** - Modern and contemporary art
- **33 exhibitions** (permanent, temporary, special)

## 🔧 Configuration

Environment variables in `.env`:
```
DB_HOST=localhost
DB_PORT=5433  
DB_NAME=collections_app
DB_USER=collections_user
DB_PASSWORD=password123
PORT=8080
```

## 🏥 Health Check

`GET /api/health` - API status and uptime

## 📖 Full Documentation

Visit `http://localhost:8080/api` for complete endpoint documentation.

## 🔐 CORS

Configured for Flutter development:
- `http://localhost:3000` (Flutter web)
- `http://10.0.2.2:8080` (Android emulator)

## 🎯 Usage in Flutter

```dart
class ApiService {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  
  static Future<List<Place>> getPlaces({String? type}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/places${type != null ? '?type=$type' : ''}')
    );
    final data = jsonDecode(response.body);
    return data['data'].map<Place>((json) => Place.fromJson(json)).toList();
  }
}
```

## 🚀 Deployment Ready

- Ready for cloud deployment (Vercel, Railway, Heroku)
- Environment-based configuration
- Production error handling
- Rate limiting included