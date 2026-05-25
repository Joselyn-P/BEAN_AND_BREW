# Bean & Brew — Project Documentation

> Freshly brewed, just a tap away.

A full-stack mobile coffee shop ordering application built with **Flutter** (frontend), **Express.js** (backend), and **MySQL via XAMPP** (database). Features Google OAuth login and weather-adaptive drink recommendations.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [System Architecture](#3-system-architecture)
4. [Project Structure](#4-project-structure)
   - [Backend](#41-backend-structure)
   - [Flutter](#42-flutter-structure)
5. [Database Design](#5-database-design)
   - [ERD Summary](#51-erd-summary)
   - [Tables Reference](#52-tables-reference)
6. [API Reference](#6-api-reference)
   - [Auth](#61-auth)
   - [Products](#62-products)
   - [Cart](#63-cart)
   - [Orders](#64-orders)
   - [Weather](#65-weather)
   - [Profile](#66-profile)
7. [App Pages & Features](#7-app-pages--features)
8. [Environment Setup](#8-environment-setup)
   - [Prerequisites](#81-prerequisites)
   - [XAMPP & MySQL](#82-xampp--mysql)
   - [Backend Setup](#83-backend-setup)
   - [Flutter Setup](#84-flutter-setup)
9. [Google OAuth Setup](#9-google-oauth-setup)
10. [OpenWeather API Setup](#10-openweather-api-setup)
11. [Running the Project](#11-running-the-project)
12. [Key Implementation Notes](#12-key-implementation-notes)

---

## 1. Project Overview

Bean & Brew is a mobile-first coffee shop ordering app that allows customers to:

- Register and log in via Google account or email/password
- Browse the full menu by category (Hot Coffee, Iced Coffee, Food, Merchandise)
- Receive daily drink recommendations based on real-time local weather
- Customize products (size, temperature, sugar level, add-ons)
- Add items to cart, apply promo codes, and checkout
- Choose pickup or delivery, and select a payment method
- Track live order status (Confirmed → Preparing → Ready → Enjoy)
- Manage their profile, saved addresses, favorites, and past orders

---

## 2. Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Mobile frontend | Flutter (Dart) | Cross-platform UI |
| State management | Provider | App-wide state |
| HTTP client | Dio | API requests + interceptors |
| Backend | Express.js (Node.js) | REST API server |
| Authentication | JWT + Google OAuth 2.0 | Secure sessions |
| Database | MySQL 8 via XAMPP | Persistent data storage |
| Weather | OpenWeatherMap API | Real-time weather data |
| Location | Geolocator (Flutter) | Device GPS |
| Secure storage | flutter_secure_storage | JWT token storage on device |

---

## 3. System Architecture

```
┌─────────────────────────────┐
│        Flutter App          │
│  (Dart + Provider + Dio)    │
└────────────┬────────────────┘
             │ HTTP REST  (JWT in Authorization header)
             │ http://10.0.2.2:3000/api
             ▼
┌─────────────────────────────┐
│      Express.js Server      │
│         port 3000           │
│  routes → controllers →     │
│  models → MySQL queries     │
└────────────┬────────────────┘
             │ mysql2 connection pool
             ▼
┌─────────────────────────────┐
│    XAMPP MySQL  port 3306   │
│    database: bean_and_brew  │
└─────────────────────────────┘
```

**Emulator note:** Android emulators map `10.0.2.2` to the host machine's `localhost`. For a physical device, replace with your LAN IP (e.g. `192.168.1.x`).

---

## 4. Project Structure

Both projects live as sibling folders:

```
bean_and_brew/
├── bean_and_brew_backend/    ← Express.js
└── bean_and_brew_app/        ← Flutter
```

### 4.1 Backend Structure

```
bean_and_brew_backend/
├── src/
│   ├── config/
│   │   └── db.js                  # mysql2 connection pool
│   ├── middleware/
│   │   └── auth.js                # JWT verification guard
│   ├── routes/
│   │   ├── auth.js                # POST /api/auth/*
│   │   ├── products.js            # GET  /api/products/*
│   │   ├── cart.js                # GET/POST/PUT/DELETE /api/cart/*
│   │   ├── orders.js              # GET/POST /api/orders/*
│   │   ├── profile.js             # GET/PUT /api/profile/*
│   │   └── weather.js             # GET /api/weather/recommend
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── productController.js
│   │   ├── cartController.js
│   │   ├── orderController.js
│   │   └── weatherController.js
│   ├── models/
│   │   ├── userModel.js
│   │   ├── productModel.js
│   │   ├── cartModel.js
│   │   └── orderModel.js
│   ├── helpers/
│   │   ├── jwtHelper.js           # sign / verify tokens
│   │   └── weatherHelper.js       # OpenWeather API calls
│   └── app.js                     # Express entry point
├── .env                           # ⚠ never commit this
├── .gitignore
├── package.json
└── package-lock.json
```

### 4.2 Flutter Structure

```
bean_and_brew_app/
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml    # INTERNET + LOCATION permissions
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart      # base URL + all endpoint strings
│   │   │   ├── app_colors.dart         # brand color palette
│   │   │   └── app_text_styles.dart    # shared TextStyle definitions
│   │   ├── services/
│   │   │   ├── api_service.dart        # Dio instance + auth interceptor
│   │   │   ├── auth_service.dart       # login, register, Google sign-in
│   │   │   ├── weather_service.dart    # fetch weather + recommendation
│   │   │   └── storage_service.dart    # JWT read/write (secure storage)
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── cart_model.dart
│   │   │   └── order_model.dart
│   │   └── providers/
│   │       ├── auth_provider.dart      # logged-in user + token state
│   │       ├── cart_provider.dart      # cart items + totals
│   │       └── order_provider.dart     # active + past orders
│   ├── features/
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   └── signup_page.dart
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── widgets/
│   │   │       └── weather_banner.dart
│   │   ├── menu/
│   │   │   ├── menu_page.dart
│   │   │   └── product_page.dart
│   │   ├── cart/
│   │   │   └── cart_page.dart
│   │   ├── checkout/
│   │   │   └── checkout_page.dart
│   │   ├── orders/
│   │   │   ├── orders_page.dart
│   │   │   └── order_tracking_page.dart
│   │   └── profile/
│   │       └── profile_page.dart
│   ├── shared/
│   │   └── widgets/
│   │       ├── product_card.dart
│   │       ├── custom_button.dart
│   │       ├── loading_shimmer.dart
│   │       └── bottom_nav.dart
│   └── main.dart                      # app entry point
├── pubspec.yaml                        # dependencies
└── .gitignore
```

---

## 5. Database Design

### 5.1 ERD Summary

```
users ──< addresses
users ──< payment_methods
users ──< favorites >── products
users ──  carts ──< cart_items >── products
users ──< orders ──< order_items >── products
              │
              ├──> addresses
              ├──> promo_codes
              └──< order_tracking

products ──< product_options
products ──< weather_recommendations
categories ──< products
```

### 5.2 Tables Reference

| Table | Description |
|---|---|
| `users` | All registered users (email or Google) |
| `addresses` | Saved delivery addresses per user |
| `payment_methods` | Saved cards / e-wallets per user |
| `categories` | Menu categories (Hot Coffee, Cold Brew, Food…) |
| `products` | Menu items with base price and availability |
| `product_options` | Per-product customizations (size, sugar, add-ons) |
| `favorites` | User ↔ product many-to-many |
| `carts` | One active cart per user |
| `cart_items` | Items in a cart with chosen options snapshot |
| `promo_codes` | Discount codes with usage limits and expiry |
| `orders` | Placed orders with fulfillment type and status |
| `order_items` | Items in a placed order (immutable snapshot) |
| `order_tracking` | Append-only status log per order |
| `weather_recommendations` | Product suggestions keyed by weather condition |

---

## 6. API Reference

All protected routes require the header:
```
Authorization: Bearer <jwt_token>
```

### 6.1 Auth

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/register` | No | Register with email + password |
| POST | `/api/auth/login` | No | Login with email + password |
| POST | `/api/auth/google` | No | Login/register with Google ID token |

**POST `/api/auth/login` — request body:**
```json
{
  "email": "user@example.com",
  "password": "secret123"
}
```

**Response:**
```json
{
  "token": "eyJhbGci...",
  "user": {
    "id": "uuid",
    "full_name": "Alex Henderson",
    "email": "alex@example.com",
    "profile_photo_url": "https://..."
  }
}
```

**POST `/api/auth/google` — request body:**
```json
{
  "id_token": "google_id_token_from_flutter"
}
```

### 6.2 Products

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/api/products` | No | All products (supports `?category=hot-coffee`) |
| GET | `/api/products/:id` | No | Single product with options |
| GET | `/api/products/featured` | No | Featured products for home screen |
| GET | `/api/categories` | No | All categories |

### 6.3 Cart

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/api/cart` | Yes | Get current user's cart |
| POST | `/api/cart/items` | Yes | Add item to cart |
| PUT | `/api/cart/items/:id` | Yes | Update item quantity |
| DELETE | `/api/cart/items/:id` | Yes | Remove item from cart |
| POST | `/api/cart/promo` | Yes | Apply promo code |

**POST `/api/cart/items` — request body:**
```json
{
  "product_id": "uuid",
  "quantity": 1,
  "selected_options": {
    "size": "Large",
    "temperature": "Hot",
    "sugar": "50%",
    "addons": ["Extra Vanilla Syrup"]
  },
  "item_price": 5.25
}
```

### 6.4 Orders

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/orders` | Yes | Place a new order from cart |
| GET | `/api/orders` | Yes | Get all orders for current user |
| GET | `/api/orders/:id` | Yes | Get single order with tracking |

**POST `/api/orders` — request body:**
```json
{
  "address_id": "uuid or null",
  "fulfillment_type": "pickup",
  "payment_method": "google_pay",
  "promo_code_id": "uuid or null"
}
```

### 6.5 Weather

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/api/weather/recommend` | No | Get recommended products by weather |

**Query params:** `?lat=40.71&lon=-74.00`

**Response:**
```json
{
  "condition": "rainy",
  "temperature": 18,
  "recommendations": [
    { "id": "uuid", "name": "Honey Lavender Latte", "base_price": 6.50 }
  ]
}
```

### 6.6 Profile

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/api/profile` | Yes | Get current user's profile |
| PUT | `/api/profile` | Yes | Update name or photo |
| GET | `/api/profile/favorites` | Yes | Get favorited products |
| POST | `/api/profile/favorites/:productId` | Yes | Toggle favorite |
| GET | `/api/profile/addresses` | Yes | Get saved addresses |
| POST | `/api/profile/addresses` | Yes | Add new address |

---

## 7. App Pages & Features

| Page | Route trigger | Key features |
|---|---|---|
| Login | App open (unauthenticated) | Email/password login, Google OAuth |
| Sign Up | "Don't have an account?" | Manual registration, Google OAuth |
| Home | Bottom nav — Home | Weather banner, recommended drinks, featured items, category tabs |
| Menu | Bottom nav — Menu | Grid browse, search, category filter, quick-add to cart |
| Product Detail | Tap any product | Size, temperature, sugar, add-on customization, live price |
| Cart | Cart icon / bottom nav | Item list, quantity controls, promo code, fee summary |
| Checkout | Cart → Checkout | Order summary, pickup/delivery toggle, payment selection |
| Order Tracking | Post-checkout / Orders tab | Live status stepper, order summary, estimated time |
| Orders History | Bottom nav — Orders | All past orders, re-order button |
| Profile | Bottom nav — Profile | Google info, favorites, addresses, payment methods, logout |

### Weather Recommendation Logic

| Weather Condition | Recommended Type | Banner Color |
|---|---|---|
| Clear / Sunny | Cold drinks (Iced, Cold Brew) | Warm orange |
| Rain / Drizzle | Hot drinks (Latte, Espresso) | Cool blue-grey |
| Clouds | Mix of hot and cold | Neutral grey |
| Snow | Hot drinks | Deep blue |

---

## 8. Environment Setup

### 8.1 Prerequisites

| Tool | Version | Download |
|---|---|---|
| Flutter SDK | 3.x+ | https://flutter.dev/docs/get-started/install |
| Android Studio | Latest | https://developer.android.com/studio |
| Node.js | 18+ | https://nodejs.org |
| XAMPP | 8.x | https://www.apachefriends.org |
| VS Code | Latest | https://code.visualstudio.com |

**VS Code extensions:** Flutter, Dart, REST Client

### 8.2 XAMPP & MySQL

1. Open XAMPP Control Panel
2. Start **Apache** and **MySQL**
3. Go to `http://localhost/phpmyadmin`
4. Create a new database named `bean_and_brew`
5. Open the SQL tab and paste + run the full schema from `schema.sql`

### 8.3 Backend Setup

```bash
# 1. Enter the backend folder
cd bean_and_brew_backend

# 2. Install dependencies
npm install

# 3. Create your .env file
cp .env.example .env
# then fill in your values (see below)

# 4. Start the dev server
npm run dev
# → Bean & Brew API running on port 3000
```

**.env file:**
```env
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=bean_and_brew
JWT_SECRET=your_super_secret_key_change_this
GOOGLE_CLIENT_ID=your_google_web_client_id
OPENWEATHER_API_KEY=your_openweather_api_key
```

### 8.4 Flutter Setup

```bash
# 1. Enter the Flutter folder
cd bean_and_brew_app

# 2. Install packages
flutter pub get

# 3. Start an Android emulator from Android Studio
# (AVD Manager → launch any device)

# 4. Run the app
flutter run
```

**pubspec.yaml dependencies:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  dio: ^5.4.0
  google_sign_in: ^6.2.1
  provider: ^6.1.2
  flutter_secure_storage: ^9.0.0
  geolocator: ^11.0.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
```

**AndroidManifest.xml permissions:**
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

---

## 9. Google OAuth Setup

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a new project (or select existing)
3. Navigate to **APIs & Services → Credentials**
4. Click **Create Credentials → OAuth 2.0 Client ID**
5. Create an **Android** client:
   - Package name: `com.example.bean_and_brew`
   - SHA-1: run `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
6. Create a **Web** client (needed for backend token verification)
7. Copy the **Web Client ID** into `.env` as `GOOGLE_CLIENT_ID`
8. Download `google-services.json` and place it at `android/app/google-services.json`

**Flutter usage:**
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'YOUR_ANDROID_CLIENT_ID',
);

final account = await _googleSignIn.signIn();
final auth = await account!.authentication;
final idToken = auth.idToken; // send this to POST /api/auth/google
```

**Backend verification (`authController.js`):**
```js
const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const ticket = await client.verifyIdToken({
  idToken: req.body.id_token,
  audience: process.env.GOOGLE_CLIENT_ID,
});
const payload = ticket.getPayload();
// payload.sub = google_id, payload.email, payload.name, payload.picture
```

---

## 10. OpenWeather API Setup

1. Register at [openweathermap.org](https://openweathermap.org/api)
2. Go to **My API Keys** and copy your key
3. Paste it into `.env` as `OPENWEATHER_API_KEY`
4. The free tier supports up to 1,000 calls/day — sufficient for development

**API call used:**
```
GET https://api.openweathermap.org/data/2.5/weather
    ?lat={lat}&lon={lon}&appid={key}&units=metric
```

**Weather condition mapping (`weatherHelper.js`):**
```js
function getRecommendationType(weatherMain) {
  const hot = ['Rain', 'Drizzle', 'Thunderstorm', 'Snow'];
  const cold = ['Clear'];
  if (hot.includes(weatherMain)) return 'hot';
  if (cold.includes(weatherMain)) return 'cold';
  return 'both'; // Clouds, Mist, etc.
}
```

---

## 11. Running the Project

Open two terminals simultaneously:

**Terminal 1 — Backend:**
```bash
cd bean_and_brew_backend
npm run dev
```
Expected output:
```
[nodemon] starting `node src/app.js`
Bean & Brew API running on port 3000
```

**Terminal 2 — Flutter:**
```bash
cd bean_and_brew_app
flutter run
```

### Quick Checklist

- [ ] XAMPP running (Apache + MySQL both green)
- [ ] `bean_and_brew` database created with all tables
- [ ] `.env` file filled with real values
- [ ] `npm run dev` running with no errors
- [ ] Android emulator launched
- [ ] `flutter pub get` completed successfully
- [ ] `flutter run` launches the app on emulator
- [ ] Login screen appears at app start

---

## 12. Key Implementation Notes

**JWT flow:**
The Flutter app stores the JWT token in `flutter_secure_storage` (encrypted on-device). Every Dio request attaches it via an interceptor — you never manually add the header per request.

**Cart vs Orders:**
The `carts` table is mutable and represents the user's live session. Once checkout is confirmed, a permanent `orders` record is created with a snapshot of items and prices. Cart changes after checkout never affect order history.

**Order tracking:**
`order_tracking` is an append-only log. Each status change adds a new row with a timestamp — this powers the step-by-step tracker UI and preserves the full history.

**Weather recommendations:**
The Flutter app fetches the user's GPS coordinates via `geolocator`, sends them to `GET /api/weather/recommend`, and the backend calls OpenWeather, maps the condition to a drink type, then queries `weather_recommendations` joined with `products` to return the top picks.

**Emulator vs physical device:**
- Android emulator → use `http://10.0.2.2:3000/api`
- Physical device → use your machine's LAN IP, e.g. `http://192.168.1.5:3000/api`

**Never commit `.env`:**
Add `.env` to `.gitignore` before your first commit. Use `.env.example` with empty values as a template for teammates.

---

*Bean & Brew — documentation last updated during initial project setup.*
