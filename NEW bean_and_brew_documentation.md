# Bean & Brew — Project Documentation

> Freshly brewed, just a tap away.

A full-stack coffee shop ordering application built with **Flutter** (frontend), **Express.js** (backend), and **MySQL via XAMPP** (database). Features Google OAuth login and weather-adaptive drink recommendations.

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
8. [Progress Tracker](#8-progress-tracker)
9. [Environment Setup](#9-environment-setup)
   - [Prerequisites](#91-prerequisites)
   - [XAMPP & MySQL](#92-xampp--mysql)
   - [Backend Setup](#93-backend-setup)
   - [Flutter Setup](#94-flutter-setup)
10. [Google OAuth Setup](#10-google-oauth-setup)
11. [OpenWeather API Setup](#11-openweather-api-setup)
12. [Running the Project](#12-running-the-project)
13. [Database Seed Data](#13-database-seed-data)
14. [Key Implementation Notes](#14-key-implementation-notes)

---

## 1. Project Overview

Bean & Brew is a mobile-first coffee shop ordering app that allows customers to:

- Register and log in via Google account or email/password
- Browse the full menu by category (Hot Coffee, Cold Brew, Tea, Pastries)
- Receive daily drink recommendations based on real-time local weather
- Customize products (size, temperature, sugar level, add-ons)
- Add items to cart, apply promo codes, and checkout
- Choose pickup or delivery, and select a payment method
- Track live order status (Confirmed → Preparing → Ready → Enjoy)
- Manage profile, saved addresses, favorites, and past orders

---

## 2. Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Mobile frontend | Flutter (Dart) | Cross-platform UI |
| State management | Provider | App-wide state |
| HTTP client | http / Dio | API requests |
| Fonts | Google Fonts | Playfair Display + Lato |
| Backend | Express.js (Node.js) | REST API server |
| Authentication | JWT + Google OAuth 2.0 | Secure sessions |
| Database | MySQL 8 via XAMPP | Persistent data storage |
| Weather | OpenWeatherMap API | Real-time weather data |
| Location | dart:html Geolocation | Browser GPS (web) |
| Secure storage | flutter_secure_storage | JWT token storage on device |

---

## 3. System Architecture

```
┌─────────────────────────────┐
│        Flutter App          │
│  (Dart + Provider + http)   │
│  Running on Chrome (web)    │
└────────────┬────────────────┘
             │ HTTP REST  (JWT in Authorization header)
             │ http://localhost:3000/api
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

**Weather flow:**
```
Flutter gets GPS (dart:html)
    ↓
GET /api/weather/recommend?lat=x&lon=y
    ↓
Backend calls OpenWeather API (key stored in .env)
    ↓
Backend maps condition → hot/cold
    ↓
Backend queries DB for matching products
    ↓
Flutter gets weather + recommended products in one response
```

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
│   │   ├── authController.js      # register, login
│   │   ├── productController.js   # getAllProducts, getFeatured, getByCategory, getProduct
│   │   ├── cartController.js      # (pending)
│   │   ├── orderController.js     # (pending)
│   │   └── weatherController.js   # getRecommendations
│   ├── models/
│   │   ├── userModel.js           # (pending)
│   │   ├── productModel.js        # (pending)
│   │   ├── cartModel.js           # (pending)
│   │   └── orderModel.js          # (pending)
│   ├── helpers/
│   │   ├── jwtHelper.js           # (pending)
│   │   └── weatherHelper.js       # (pending)
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
│   │   │   ├── app_colors.dart         # (pending)
│   │   │   └── app_text_styles.dart    # (pending)
│   │   ├── services/
│   │   │   ├── api_service.dart        # (pending)
│   │   │   ├── auth_service.dart       # login, register API calls
│   │   │   ├── weather_service.dart    # fetch weather + recommendations
│   │   │   └── storage_service.dart    # JWT read/write (secure storage)
│   │   ├── models/
│   │   │   ├── user_model.dart         # (pending)
│   │   │   ├── product_model.dart      # (pending)
│   │   │   ├── cart_model.dart         # (pending)
│   │   │   └── order_model.dart        # (pending)
│   │   └── providers/
│   │       ├── auth_provider.dart      # (pending)
│   │       ├── cart_provider.dart      # (pending)
│   │       └── order_provider.dart     # (pending)
│   ├── features/
│   │   ├── auth/
│   │   │   ├── login_page.dart         # ✅ done
│   │   │   └── signup_page.dart        # ✅ done
│   │   ├── home/
│   │   │   ├── home_page.dart          # ✅ done
│   │   │   └── widgets/
│   │   │       └── weather_banner.dart # ✅ done
│   │   ├── menu/
│   │   │   ├── menu_page.dart          # (pending)
│   │   │   └── product_page.dart       # (pending)
│   │   ├── cart/
│   │   │   └── cart_page.dart          # (pending)
│   │   ├── checkout/
│   │   │   └── checkout_page.dart      # (pending)
│   │   ├── orders/
│   │   │   ├── orders_page.dart        # (pending)
│   │   │   └── order_tracking_page.dart # (pending)
│   │   └── profile/
│   │       └── profile_page.dart       # (pending)
│   ├── shared/
│   │   └── widgets/
│   │       ├── product_card.dart       # (pending)
│   │       ├── custom_button.dart      # (pending)
│   │       ├── loading_shimmer.dart    # (pending)
│   │       └── bottom_nav.dart         # (pending)
│   └── main.dart                       # ✅ done
├── pubspec.yaml
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
| `categories` | Menu categories (Hot Coffee, Cold Brew, Tea, Pastries) |
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

| Method | Endpoint | Auth | Description | Status |
|---|---|---|---|---|
| POST | `/api/auth/register` | No | Register with email + password | ✅ |
| POST | `/api/auth/login` | No | Login with email + password | ✅ |
| POST | `/api/auth/google` | No | Login/register with Google ID token | ⬜ |

**POST `/api/auth/register` — request body:**
```json
{
  "full_name": "Budi Santoso",
  "email": "budi@example.com",
  "password": "secret123"
}
```

**POST `/api/auth/login` — request body:**
```json
{
  "email": "budi@example.com",
  "password": "secret123"
}
```

**Response (both):**
```json
{
  "token": "eyJhbGci...",
  "user": {
    "id": "uuid",
    "full_name": "Budi Santoso",
    "email": "budi@example.com",
    "profile_photo_url": null
  }
}
```

### 6.2 Products

| Method | Endpoint | Auth | Description | Status |
|---|---|---|---|---|
| GET | `/api/products` | No | All products (2 per category default) | ✅ |
| GET | `/api/products?category=slug` | No | All products in a category | ✅ |
| GET | `/api/products/featured` | No | Featured products for home screen | ✅ |
| GET | `/api/products/category/:slug` | No | Products by category slug | ✅ |
| GET | `/api/products/:id` | No | Single product with options | ✅ |

**Recommended logic:**
- `GET /api/products` with no query → returns 2 products per category (for home recommended carousel)
- `GET /api/products?category=hot-coffee` → returns all products in that category

### 6.3 Cart

| Method | Endpoint | Auth | Description | Status |
|---|---|---|---|---|
| GET | `/api/cart` | Yes | Get current user's cart | ⬜ |
| POST | `/api/cart/items` | Yes | Add item to cart | ⬜ |
| PUT | `/api/cart/items/:id` | Yes | Update item quantity | ⬜ |
| DELETE | `/api/cart/items/:id` | Yes | Remove item from cart | ⬜ |
| POST | `/api/cart/promo` | Yes | Apply promo code | ⬜ |

### 6.4 Orders

| Method | Endpoint | Auth | Description | Status |
|---|---|---|---|---|
| POST | `/api/orders` | Yes | Place a new order from cart | ⬜ |
| GET | `/api/orders` | Yes | Get all orders for current user | ⬜ |
| GET | `/api/orders/:id` | Yes | Get single order with tracking | ⬜ |

### 6.5 Weather

| Method | Endpoint | Auth | Description | Status |
|---|---|---|---|---|
| GET | `/api/weather/recommend` | No | Get weather + recommended products | ✅ |

**Query params:** `?lat=40.71&lon=-74.00`

**Response:**
```json
{
  "condition": "Clear",
  "temp": 28,
  "city": "Soreang",
  "recommendationType": "cold",
  "products": [
    { "id": "uuid", "name": "Oat Milk Latte", "base_price": "5.50" }
  ]
}
```

**Weather → recommendation mapping:**

| Condition | Type | Today's Pick |
|---|---|---|
| Clear / Sunny | cold | Iced Caramel Macchiato |
| Rain / Drizzle / Thunder | hot | Honey Lavender Latte |
| Snow | hot | Honey Lavender Latte |
| Clouds | cold | Iced Caramel Macchiato |

### 6.6 Profile

| Method | Endpoint | Auth | Description | Status |
|---|---|---|---|---|
| GET | `/api/profile` | Yes | Get current user's profile | ⬜ |
| PUT | `/api/profile` | Yes | Update name or photo | ⬜ |
| GET | `/api/profile/favorites` | Yes | Get favorited products | ⬜ |
| POST | `/api/profile/favorites/:productId` | Yes | Toggle favorite | ⬜ |
| GET | `/api/profile/addresses` | Yes | Get saved addresses | ⬜ |
| POST | `/api/profile/addresses` | Yes | Add new address | ⬜ |

---

## 7. App Pages & Features

| Page | File | Status | Key Features |
|---|---|---|---|
| Login | `login_page.dart` | ✅ | Email/password login, Google OAuth button, navigate to signup |
| Sign Up | `signup_page.dart` | ✅ | Manual registration, Google OAuth button, navigate to login |
| Home | `home_page.dart` | ✅ | Weather banner, category tabs, recommended carousel, featured list |
| Weather Banner | `weather_banner.dart` | ✅ | Flutter icons, weather-adaptive colors, Today's Pick |
| Menu | `menu_page.dart` | ⬜ | Grid browse, search, category filter, quick-add |
| Product Detail | `product_page.dart` | ⬜ | Size, temperature, sugar, add-on customization, live price |
| Cart | `cart_page.dart` | ⬜ | Item list, quantity controls, promo code, fee summary |
| Checkout | `checkout_page.dart` | ⬜ | Order summary, pickup/delivery toggle, payment selection |
| Order Tracking | `order_tracking_page.dart` | ⬜ | Live status stepper, order summary, estimated time |
| Orders History | `orders_page.dart` | ⬜ | All past orders, re-order button |
| Profile | `profile_page.dart` | ⬜ | Google info, favorites, addresses, payment methods, logout |

### Home Page — Recommended Carousel Logic

```
Page loads
    ↓
_loadWeather() called
    ↓
Weather API returns products? ──YES──► show weather-based products
    ↓ NO
_loadProducts() called
    ↓
Show 2 products per category as fallback
    ↓
User taps category tab
    ↓
_loadByCategory(slug) called → show ALL products in that category
    ↓
User taps VIEW ALL
    ↓
_loadProducts() called → reset to 2 per category
```

---

## 8. Progress Tracker

### ✅ Done

**Setup**
- Flutter project created and structured
- Express.js backend created and structured
- XAMPP MySQL database created with all tables
- Both projects pushed to GitHub (`Joselyn-P/BEAN_AND_BREW`)
- Google Fonts integrated (Playfair Display + Lato)

**Backend**
- `db.js` — MySQL connection pool
- `app.js` — all routes registered with CORS
- `auth.js` route + `authController.js` — register & login with bcrypt + JWT
- `products.js` route + `productController.js` — full product CRUD
- `weather.js` route + `weatherController.js` — weather + product recommendations
- `.env` — DB, JWT, OpenWeather credentials

**Flutter**
- `main.dart` — app entry with MultiProvider
- `api_constants.dart` — all endpoint URLs
- `auth_service.dart` — login & register API calls
- `storage_service.dart` — JWT token secure storage
- `weather_service.dart` — calls backend weather endpoint via browser GPS
- `login_page.dart` — full UI + backend connected + navigates to home
- `signup_page.dart` — full UI + backend connected + navigates to home
- `home_page.dart` — weather banner, category tabs, recommended carousel, featured list
- `weather_banner.dart` — extracted weather widget with Flutter icons

### ⬜ To Do

**Backend**
- `cartController.js` + `cart.js` route
- `orderController.js` + `orders.js` route
- `profileController.js` + `profile.js` route
- `middleware/auth.js` — JWT guard for protected routes
- `auth/google` endpoint — Google OAuth verification

**Flutter Pages**
- `menu_page.dart`
- `product_page.dart`
- `cart_page.dart`
- `checkout_page.dart`
- `order_tracking_page.dart`
- `orders_page.dart`
- `profile_page.dart`

**Flutter Core**
- `product_model.dart`, `user_model.dart`, `cart_model.dart`, `order_model.dart`
- `auth_provider.dart`, `cart_provider.dart`, `order_provider.dart`
- `bottom_nav.dart`, `product_card.dart`, `custom_button.dart`, `loading_shimmer.dart`

**Other**
- Google OAuth setup (Google Cloud Console)
- Navigation between all pages (bottom nav wiring)
- Empty states (empty cart, no orders)
- Error handling & loading shimmer throughout

### Suggested Build Order
1. Menu page
2. Product detail page
3. Cart backend + page
4. Checkout page
5. Order tracking page
6. Orders history page
7. Profile page
8. Google OAuth
9. Polish (shimmer loaders, empty states, error handling)

---

## 9. Environment Setup

### 9.1 Prerequisites

| Tool | Version | Download |
|---|---|---|
| Flutter SDK | 3.32.2 | https://flutter.dev/docs/get-started/install |
| Android Studio | 2024.3.2 | https://developer.android.com/studio |
| Node.js | 18+ | https://nodejs.org |
| XAMPP | 8.x | https://www.apachefriends.org |
| VS Code | Latest | https://code.visualstudio.com |

**VS Code extensions:** Flutter, Dart, REST Client

### 9.2 XAMPP & MySQL

1. Open XAMPP Control Panel
2. Start **Apache** and **MySQL**
3. Go to `http://localhost/phpmyadmin`
4. Create database named `bean_and_brew`
5. Open SQL tab and run the full schema SQL

### 9.3 Backend Setup

```bash
cd bean_and_brew_backend
npm install
# fill in .env file
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
JWT_SECRET=your_secret_key_here
GOOGLE_CLIENT_ID=your_google_client_id
OPENWEATHER_API_KEY=your_openweather_key
```

**package.json scripts:**
```json
"scripts": {
  "start": "node src/app.js",
  "dev": "node node_modules/nodemon/bin/nodemon.js src/app.js"
}
```

### 9.4 Flutter Setup

```bash
cd bean_and_brew_app
flutter pub get
flutter run -d chrome
```

**pubspec.yaml dependencies:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  dio: ^5.4.0
  http: ^1.2.0
  google_sign_in: ^6.2.1
  provider: ^6.1.2
  flutter_secure_storage: ^9.0.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  google_fonts: ^6.2.1
```

**AndroidManifest.xml permissions:**
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

---

## 10. Google OAuth Setup

> ⚠️ Pending — will be set up after all pages are complete and app runs on a stable URL.

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a new project
3. Navigate to **APIs & Services → Credentials**
4. Create **OAuth 2.0 Client ID → Web**
5. Add `http://localhost` to authorized JavaScript origins
6. Copy **Web Client ID** into `.env` as `GOOGLE_CLIENT_ID`
7. Backend verifies Google ID token using `google-auth-library`

---

## 11. OpenWeather API Setup

1. Register at [openweathermap.org](https://openweathermap.org/api)
2. Go to **My API Keys** and copy your key
3. Paste into `.env` as `OPENWEATHER_API_KEY`
4. Free tier: 1,000 calls/day

**API endpoint used:**
```
GET https://api.openweathermap.org/data/2.5/weather
    ?lat={lat}&lon={lon}&appid={key}&units=metric
```

---

## 12. Running the Project

**Terminal 1 — Backend:**
```powershell
cd bean_and_brew_backend
npm run dev
```
Expected:
```
Bean & Brew API running on port 3000
```

**Terminal 2 — Flutter:**
```powershell
cd bean_and_brew_app
flutter run -d chrome
```

### Quick Checklist
- [ ] XAMPP running (Apache + MySQL both green)
- [ ] `bean_and_brew` database created with all tables
- [ ] `.env` file filled with real values
- [ ] `npm run dev` running with no errors
- [ ] `flutter run -d chrome` launches the app
- [ ] Login page appears
- [ ] Can register a new account
- [ ] Can login and reach home page
- [ ] Weather banner loads
- [ ] Products appear in recommended carousel

---

## 13. Database Seed Data

Run this in phpMyAdmin to populate categories and products:

```sql
USE bean_and_brew;

-- Categories
INSERT INTO categories (id, name, slug, display_order) VALUES
(UUID(), 'Hot Coffee', 'hot-coffee', 1),
(UUID(), 'Cold Brew', 'cold-brew', 2),
(UUID(), 'Tea', 'tea', 3),
(UUID(), 'Pastries', 'pastries', 4);

-- Products (21 total across all categories)
-- See full seed SQL in project repository
```

**Current products (21 total):**

| Name | Category | Price | Featured |
|---|---|---|---|
| Artisan Latte | Hot Coffee | $4.50 | No |
| Flat White | Hot Coffee | $4.25 | Yes |
| Cappuccino | Hot Coffee | $4.75 | No |
| Americano | Hot Coffee | $3.50 | No |
| Honey Lavender Latte | Hot Coffee | $6.00 | Yes |
| Caramel Macchiato | Hot Coffee | $5.50 | No |
| Oat Milk Latte | Cold Brew | $5.50 | Yes |
| Cold Brew | Cold Brew | $5.00 | No |
| Iced Caramel Macchiato | Cold Brew | $5.75 | Yes |
| Nitro Cold Brew | Cold Brew | $6.50 | No |
| Iced Americano | Cold Brew | $4.00 | No |
| Ceremonial Matcha | Tea | $6.00 | Yes |
| Chamomile Honey Tea | Tea | $4.00 | No |
| Iced Matcha Latte | Tea | $5.50 | No |
| Earl Grey Latte | Tea | $4.75 | No |
| Almond Croissant | Pastries | $4.25 | Yes |
| Butter Croissant | Pastries | $3.50 | No |
| Blueberry Muffin | Pastries | $3.75 | Yes |
| Cinnamon Roll | Pastries | $4.50 | Yes |
| Banana Bread | Pastries | $3.75 | No |

---

## 14. Key Implementation Notes

**JWT flow:**
Flutter stores JWT in `flutter_secure_storage`. Every request attaches it via the `Authorization: Bearer` header. The token expires in 7 days.

**Running on Chrome (web):**
Since the emulator had path issues (`BEAN & BREW` folder name with `&`), the app currently runs on Chrome. The project folder was renamed to `BEAN_AND_BREW` to fix path-related errors with Gradle, nodemon, and PowerShell.

**`dart:html` for location:**
Since the app runs on Chrome, `geolocator` package was replaced with `dart:html`'s native `window.navigator.geolocation`. The `// ignore: avoid_web_libraries_in_flutter` comment suppresses the lint warning.

**Price type mismatch:**
MySQL returns `DECIMAL` columns as strings in JSON. All price fields use `double.parse(item['base_price'].toString()).toStringAsFixed(2)` to convert safely.

**Cart vs Orders:**
`carts` is mutable (live session). Once checkout is confirmed, a permanent `orders` record is created with a snapshot of items and prices.

**Weather recommendations:**
Browser GPS → backend `/api/weather/recommend` → OpenWeather API → DB query for hot/cold products → returned to Flutter. API key stays on server, never exposed to client.

**`BEAN & BREW` path issue:**
The `&` character is a special symbol in PowerShell/Windows CMD that means "run next command". This caused Gradle, nodemon, and file operations to fail. Fixed by renaming the folder to `BEAN_AND_BREW`.

**Never commit `.env`:**
The `.env` file contains DB credentials, JWT secret, and API keys. It is listed in `.gitignore` and should never be pushed to GitHub.

---

*Bean & Brew documentation — last updated after Home page completion.*
