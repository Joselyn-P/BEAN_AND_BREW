# Bean & Brew — Project Documentation & Handoff Guide

> Freshly brewed, just a tap away.

A full-stack coffee shop ordering application built with **Flutter** (frontend), **Express.js** (backend), and **MySQL via XAMPP** (database). Features weather-adaptive drink recommendations and email/password authentication.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [System Architecture](#3-system-architecture)
4. [Project Structure](#4-project-structure)
5. [Database Design](#5-database-design)
6. [API Reference](#6-api-reference)
7. [App Pages & Features](#7-app-pages--features)
8. [Progress Tracker](#8-progress-tracker)
9. [Current State of Each File](#9-current-state-of-each-file)
10. [Environment Setup](#10-environment-setup)
11. [Running the Project](#11-running-the-project)
12. [Database Seed Data](#12-database-seed-data)
13. [Key Implementation Notes](#13-key-implementation-notes)
14. [Known Issues & Decisions](#14-known-issues--decisions)
15. [What To Build Next](#15-what-to-build-next)

---

## 1. Project Overview

Bean & Brew is a mobile-first coffee shop ordering app. Current working features:

- Email/password registration and login
- Weather-adaptive home page (shows hot/cold drink recommendations based on real-time weather)
- Full menu browsing with search and category filtering
- Product detail page with customization (size, temperature, sugar, add-ons)
- Add to cart (backend connected, UI pending)
- Navigation between Home, Menu, and Product Detail pages

Not yet built: Cart page UI, Checkout, Order Tracking, Orders History, Profile, Google OAuth.

---

## 2. Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | Flutter (Dart) | Cross-platform UI, currently running on Chrome web |
| State management | Provider | App-wide state (stubs only, not fully implemented) |
| HTTP client | `http` package | API requests |
| Fonts | Google Fonts | Playfair Display (headings) + Lato (body) |
| Backend | Express.js (Node.js) | REST API server |
| Auth | JWT + bcryptjs | Session management |
| Database | MySQL 8 via XAMPP | Persistent storage |
| Weather | OpenWeatherMap API | Real-time weather (called from backend) |
| Location | `dart:html` Geolocation | Browser GPS for weather |
| Token storage | flutter_secure_storage | JWT stored on device |

---

## 3. System Architecture

```
Flutter (Chrome web)
    │
    │ HTTP REST — Authorization: Bearer <jwt>
    │ http://localhost:3000/api
    ▼
Express.js — port 3000
    │
    │ mysql2 pool
    ▼
XAMPP MySQL — port 3306
database: bean_and_brew
```

**Weather flow:**
```
Flutter → dart:html gets GPS coordinates
       → GET /api/weather/recommend?lat=x&lon=y
       → Backend calls OpenWeather API (key in .env)
       → Backend maps condition to hot/cold
       → Backend queries DB for matching products
       → Returns { condition, temp, city, recommendationType, products[] }
```

**Key URL:** Flutter uses `http://localhost:3000/api` (not `10.0.2.2` — running on Chrome, not Android emulator)

---

## 4. Project Structure

```
bean_and_brew/                          ← root (renamed from "BEAN & BREW" — & caused path errors)
├── bean_and_brew_backend/              ← Express.js
└── bean_and_brew_app/                  ← Flutter
```

### Backend Structure

```
bean_and_brew_backend/
├── src/
│   ├── config/
│   │   └── db.js                      ✅ mysql2 connection pool
│   ├── middleware/
│   │   └── auth.js                    ✅ JWT verification guard
│   ├── routes/
│   │   ├── auth.js                    ✅ POST /api/auth/register, /login
│   │   ├── products.js                ✅ GET /api/products/*
│   │   ├── cart.js                    ✅ cart routes (backend done, Flutter UI pending)
│   │   ├── orders.js                  ⬜ stub only
│   │   ├── profile.js                 ⬜ stub only
│   │   └── weather.js                 ✅ GET /api/weather/recommend
│   ├── controllers/
│   │   ├── authController.js          ✅ register + login
│   │   ├── productController.js       ✅ getAllProducts, getFeatured, getByCategory, getProduct
│   │   ├── cartController.js          ✅ getCart, addItem, updateItem, removeItem, applyPromo
│   │   ├── orderController.js         ⬜ empty
│   │   └── weatherController.js       ✅ getRecommendations (joins categories table)
│   ├── models/                        ⬜ all empty (queries written directly in controllers)
│   ├── helpers/                       ⬜ all empty
│   └── app.js                         ✅ all routes registered, CORS configured
├── .env                               ✅ filled
├── .gitignore                         ✅ node_modules + .env excluded
└── package.json                       ✅ nodemon script uses node_modules/nodemon/bin/nodemon.js
```

### Flutter Structure

```
bean_and_brew_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart     ✅ baseUrl = http://localhost:3000/api
│   │   ├── services/
│   │   │   ├── auth_service.dart      ✅ login(), register()
│   │   │   ├── weather_service.dart   ✅ getWeatherRecommendation() via dart:html
│   │   │   └── storage_service.dart   ✅ JWT read/write via flutter_secure_storage
│   │   ├── models/                    ⬜ all empty stubs
│   │   └── providers/
│   │       ├── auth_provider.dart     ⬜ stub only
│   │       ├── cart_provider.dart     ⬜ stub only
│   │       └── order_provider.dart    ⬜ stub only
│   ├── features/
│   │   ├── auth/
│   │   │   ├── login_page.dart        ✅ fully built + connected to backend
│   │   │   └── signup_page.dart       ✅ fully built + connected to backend
│   │   ├── home/
│   │   │   ├── home_page.dart         ✅ fully built + connected to backend
│   │   │   └── widgets/
│   │   │       └── weather_banner.dart ✅ extracted widget with Flutter icons
│   │   ├── menu/
│   │   │   ├── menu_page.dart         ✅ fully built + connected to backend
│   │   │   └── product_page.dart      ✅ fully built + connected to backend
│   │   ├── cart/
│   │   │   └── cart_page.dart         ⬜ empty
│   │   ├── checkout/
│   │   │   └── checkout_page.dart     ⬜ empty
│   │   ├── orders/
│   │   │   ├── orders_page.dart       ⬜ empty
│   │   │   └── order_tracking_page.dart ⬜ empty
│   │   └── profile/
│   │       └── profile_page.dart      ⬜ empty
│   ├── shared/
│   │   └── widgets/                   ⬜ all empty stubs
│   └── main.dart                      ✅ MultiProvider setup, starts at LoginPage
└── pubspec.yaml                       ✅ all dependencies installed
```

---

## 5. Database Design

### Tables

| Table | Status | Description |
|---|---|---|
| `users` | ✅ in use | Registered users (email or Google) |
| `addresses` | ⬜ empty | Saved delivery addresses |
| `payment_methods` | ⬜ empty | Saved cards/wallets |
| `categories` | ✅ seeded | Hot Coffee, Cold Brew, Tea, Pastries |
| `products` | ✅ seeded | 20 products across all categories |
| `product_options` | ✅ seeded | Add-ons for drinks and pastries |
| `favorites` | ⬜ empty | User ↔ product |
| `carts` | ✅ in use | One per user, auto-created |
| `cart_items` | ✅ in use | Items in cart with selected_options JSON |
| `promo_codes` | ⬜ empty | Discount codes |
| `orders` | ⬜ empty | Placed orders |
| `order_items` | ⬜ empty | Items in placed orders |
| `order_tracking` | ⬜ empty | Status log per order |
| `weather_recommendations` | ⬜ empty | Not used (weather logic in controller) |

### ERD Summary

```
users ──< carts ──< cart_items >── products ──< product_options
users ──< orders ──< order_items >── products
categories ──< products
```

---

## 6. API Reference

Base URL: `http://localhost:3000/api`

Protected routes require: `Authorization: Bearer <jwt_token>`

### Auth

| Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|
| POST | `/auth/register` | No | ✅ | Register with full_name, email, password |
| POST | `/auth/login` | No | ✅ | Login with email, password → returns token + user |
| POST | `/auth/google` | No | ⬜ | Google OAuth (not implemented) |

**Response format (both):**
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

### Products

| Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|
| GET | `/products` | No | ✅ | 2 per category (for home recommended) |
| GET | `/products?category=all` | No | ✅ | All products (for menu page) |
| GET | `/products?category=hot-coffee` | No | ✅ | Filter by category slug |
| GET | `/products/featured` | No | ✅ | is_featured = 1 products |
| GET | `/products/:id` | No | ✅ | Single product + options array |

**Category slugs:** `hot-coffee`, `cold-brew`, `tea`, `pastries`

### Cart

| Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|
| GET | `/cart` | Yes | ✅ | Get cart with items, subtotal, tax, total |
| POST | `/cart/items` | Yes | ✅ | Add item to cart |
| PUT | `/cart/items/:id` | Yes | ✅ | Update quantity |
| DELETE | `/cart/items/:id` | Yes | ✅ | Remove item |
| POST | `/cart/promo` | Yes | ✅ | Apply promo code |

**POST `/cart/items` body:**
```json
{
  "product_id": "uuid",
  "quantity": 1,
  "selected_options": {
    "size": "Large",
    "temperature": "Iced",
    "sugar": "50%",
    "oat_milk": true,
    "addons": {}
  },
  "item_price": "6.25"
}
```

**GET `/cart` response:**
```json
{
  "cart_id": "uuid",
  "items": [...],
  "subtotal": "12.50",
  "tax": "1.00",
  "total": "13.50",
  "item_count": 2
}
```

### Orders (pending)

| Method | Endpoint | Auth | Status |
|---|---|---|---|
| POST | `/orders` | Yes | ⬜ |
| GET | `/orders` | Yes | ⬜ |
| GET | `/orders/:id` | Yes | ⬜ |

### Weather

| Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|
| GET | `/weather/recommend?lat=x&lon=y` | No | ✅ | Weather + recommended products |

**Response:**
```json
{
  "condition": "Haze",
  "temp": 29.04,
  "city": "Ciputat",
  "recommendationType": "cold",
  "products": [{ "id": "...", "name": "...", "category_name": "Cold Brew", ... }]
}
```

**Weather → recommendation mapping:**
- Rain, Drizzle, Thunderstorm, Snow → `hot` → "Honey Lavender Latte"
- Clear, Clouds, Haze, Mist, Fog → `cold` → "Iced Caramel Macchiato"

### Profile (pending)

| Method | Endpoint | Auth | Status |
|---|---|---|---|
| GET | `/profile` | Yes | ⬜ |
| PUT | `/profile` | Yes | ⬜ |
| GET | `/profile/favorites` | Yes | ⬜ |
| POST | `/profile/favorites/:id` | Yes | ⬜ |
| GET | `/profile/addresses` | Yes | ⬜ |
| POST | `/profile/addresses` | Yes | ⬜ |

---

## 7. App Pages & Features

| Page | File | Status | Notes |
|---|---|---|---|
| Login | `login_page.dart` | ✅ | Email/password + Google button (OAuth not wired) |
| Sign Up | `signup_page.dart` | ✅ | Full registration + navigate to home on success |
| Home | `home_page.dart` | ✅ | Weather banner, recommended carousel, featured list |
| Weather Banner | `weather_banner.dart` | ✅ | Extracted widget, Flutter icons, onOrderNow callback |
| Menu | `menu_page.dart` | ✅ | Grid, search, category tabs, floating cart |
| Product Detail | `product_page.dart` | ✅ | Customization, add-ons from DB, add to cart |
| Cart | `cart_page.dart` | ⬜ | Backend ready, Flutter UI not started |
| Checkout | `checkout_page.dart` | ⬜ | Not started |
| Order Tracking | `order_tracking_page.dart` | ⬜ | Not started |
| Orders History | `orders_page.dart` | ⬜ | Not started |
| Profile | `profile_page.dart` | ⬜ | Not started |

---

## 8. Progress Tracker

### ✅ Done

- Project setup (Flutter + Express + MySQL)
- GitHub repo: `Joselyn-P/BEAN_AND_BREW`
- Google Fonts integrated (Playfair Display + Lato)
- Auth: register + login with JWT
- Home page: weather banner, recommended carousel (weather-based), featured list, category tabs, navigation
- Menu page: grid, search, category filter, floating cart button
- Product detail: size/temp/sugar/oat milk (drinks only), add-ons from DB, quantity, add to cart → backend
- Weather: browser GPS → backend → OpenWeather → DB products → Flutter
- Cart backend: getCart, addItem, updateItem, removeItem, applyPromo

### ⬜ To Do (in order)

1. **Cart page** (Flutter UI) — show items, quantities, promo code, total, checkout button
2. **Checkout page** — order summary, pickup/delivery, payment method, place order
3. **Orders backend** — orderController.js + orders.js route
4. **Order tracking page** — status stepper (Confirmed → Preparing → Ready → Enjoy)
5. **Orders history page** — list of past orders
6. **Profile page** — user info, favorites, addresses, logout
7. **Google OAuth** — Google Cloud Console setup + backend verify + Flutter sign in
8. **Polish** — shimmer loaders, empty states, error handling, cart count badge

---

## 9. Current State of Each File

### `main.dart`
Entry point. Uses `MultiProvider` with `AuthProvider`, `CartProvider`, `OrderProvider` (all stubs). Starts at `LoginPage`. Theme uses `Color(0xFF3E1F00)` seed.

### `api_constants.dart`
```dart
static const String baseUrl = 'http://localhost:3000/api';
static const String login    = '$baseUrl/auth/login';
static const String register = '$baseUrl/auth/register';
static const String products = '$baseUrl/products';
static const String cart     = '$baseUrl/cart';
static const String orders   = '$baseUrl/orders';
static const String weather  = '$baseUrl/weather/recommend';
static const String profile  = '$baseUrl/profile';
```

### `auth_service.dart`
- `login(email, password)` → POST `/auth/login` → saves token + user to storage → returns `{success, user}`
- `register(fullName, email, password)` → POST `/auth/register` → same

### `storage_service.dart`
- `saveToken(token)`, `getToken()`, `deleteToken()`
- `saveUser(userJson)`, `getUser()`
- `clearAll()` — used for logout

### `weather_service.dart`
- Uses `dart:html` for browser GPS
- Calls backend `/api/weather/recommend?lat=x&lon=y`
- Falls back to `{ condition: 'Clear', city: 'Your City', ... }` on error
- Has `_getBannerText(String)` and `_getBannerColor(String)` with cases for: Rain, Drizzle, Thunderstorm, Snow, Clear, Clouds, Haze, Mist, Fog, Smoke

### `login_page.dart`
- Email + password fields, show/hide password toggle
- Sign In → `AuthService.login()` → navigate to `HomePage` on success
- Sign Up link → navigate to `SignupPage`
- Google button present but `_signInWithGoogle()` is empty TODO

### `signup_page.dart`
- Full Name, Email, Password, Confirm Password fields
- Validates passwords match
- Sign Up → `AuthService.register()` → navigate to `HomePage` on success
- Sign In link → `Navigator.pop()`

### `home_page.dart`
- `_initData()` calls `_loadWeather()` then `_loadProducts()` sequentially
- `_loadWeather()` → sets `_weatherData` + `_recommended` from weather products
- `_loadProducts()` → sets `_featured`, only updates `_recommended` if empty
- `_loadByCategory(slug)` → replaces `_recommended` with category products
- `_loadUser()` → reads username from storage
- Bottom nav: Home (index 0), Menu (index 1 → pushes MenuPage), Orders/Profile (TODO)
- Floating cart button shows count `'0'` (hardcoded, needs cart provider)
- Order Now button uses `onOrderNow` callback — finds product by name in `_recommended`
- Recommended carousel items → navigate to `ProductPage`
- Featured items → navigate to `ProductPage`

### `weather_banner.dart`
- Accepts `weatherData` Map and `onOrderNow` VoidCallback
- Has own `_getBannerText()`, `_getBannerBgColor()`, `_getWeatherIcon()`, `_getRecommendedDrink()`
- Uses Flutter icons instead of emoji (no Noto font warnings)
- Conditions handled: Rain, Drizzle, Thunderstorm, Snow, Clear, Clouds, Haze, Mist, Fog, Smoke

### `menu_page.dart`
- Category tabs: All, Hot Coffee, Cold Brew, Tea, Pastries
- `_loadAllProducts()` → `GET /products?category=all`
- `_loadByCategory(slug)` → `GET /products?category=slug`
- Search filters `_allProducts` client-side by name + description
- `_ProductCard` onTap + `+` button both → navigate to `ProductPage(product: item)`
- Floating cart button (count hardcoded `'0'`)
- Bottom nav: Menu selected (index 1), Home tap → `Navigator.pop()`

### `product_page.dart`
- Receives `product` Map from previous page
- `_isDrink` getter: `category_name != 'Pastries'`
- If drink: shows Size (Small/Medium/Large), Temperature (Hot/Iced — filtered by `temperature_type`), Sugar (0%/50%/100%), Oat Milk toggle
- If pastry: hides all drink options, shows only add-ons from DB + Warmed toggle (`_warmed` bool)
- `_loadProductOptions()` → `GET /products/:id` → sets `_options` (add-ons from DB)
- `_totalPrice` → base + size modifier + oat milk + addon counts × price_modifier × quantity
- `_addToCart()` → POST `/cart/items` with JWT → shows snackbar → pops on success
- Quantity stepper at bottom left, "Add to Cart — $X.XX" button at bottom right

### `productController.js`
- `getAllProducts`: no params → 2 per category via `ROW_NUMBER() OVER (PARTITION BY category_id)`; `?category=all` → all products; `?category=slug` → filtered
- `getFeatured`: `is_featured = 1`, LIMIT 6
- `getByCategory`: by slug
- `getProduct`: single product + options array

### `weatherController.js`
- Calls OpenWeather with lat/lon from query params
- Maps Rain/Drizzle/Thunder/Snow → hot, everything else → cold
- Queries: `SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ...`
- Returns RAND() ORDER, LIMIT 5

### `cartController.js`
- `getOrCreateCart(userId)` helper — auto-creates cart if none exists
- Tax rate: 8% (`subtotal * 0.08`)
- `addItem`: checks for existing product in cart, increments quantity if found
- Returns full cart object with subtotal, tax, total, item_count

---

## 10. Environment Setup

### Prerequisites

| Tool | Version |
|---|---|
| Flutter | 3.32.2 (stable) |
| Dart | included with Flutter |
| Node.js | 18+ |
| XAMPP | 8.x (Apache + MySQL) |
| VS Code | Latest |

### `.env` file (`bean_and_brew_backend/.env`)

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

### `pubspec.yaml` dependencies

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

### `package.json` scripts

```json
"scripts": {
  "start": "node src/app.js",
  "dev": "node node_modules/nodemon/bin/nodemon.js src/app.js"
}
```

> ⚠️ Uses direct nodemon path because `BEAN & BREW` folder name with `&` broke standard nodemon execution on Windows PowerShell.

---

## 11. Running the Project

**Terminal 1 — Backend:**
```powershell
cd bean_and_brew_backend
npm run dev
# Expected: Bean & Brew API running on port 3000
```

**Terminal 2 — Flutter:**
```powershell
cd bean_and_brew_app
flutter run -d chrome
```

**XAMPP:** Make sure Apache and MySQL are both green before starting.

**Location permission:** Chrome will ask for location when home page loads. Click Allow for weather to work. If denied, falls back to default weather (Clear/cold).

---

## 12. Database Seed Data

### Categories (4)

| id (auto UUID) | name | slug | display_order |
|---|---|---|---|
| - | Hot Coffee | hot-coffee | 1 |
| - | Cold Brew | cold-brew | 2 |
| - | Tea | tea | 3 |
| - | Pastries | pastries | 4 |

### Products (20 total)

| Name | Category | Price | Featured | Temp Type |
|---|---|---|---|---|
| Artisan Latte | Hot Coffee | $4.50 | No | hot |
| Flat White | Hot Coffee | $4.25 | Yes | hot |
| Cappuccino | Hot Coffee | $4.75 | No | hot |
| Americano | Hot Coffee | $3.50 | No | hot |
| Honey Lavender Latte | Hot Coffee | $6.00 | Yes | hot |
| Caramel Macchiato | Hot Coffee | $5.50 | No | hot |
| Oat Milk Latte | Cold Brew | $5.50 | Yes | cold |
| Cold Brew | Cold Brew | $5.00 | No | cold |
| Iced Caramel Macchiato | Cold Brew | $5.75 | Yes | cold |
| Nitro Cold Brew | Cold Brew | $6.50 | No | cold |
| Iced Americano | Cold Brew | $4.00 | No | cold |
| Ceremonial Matcha | Tea | $6.00 | Yes | both |
| Chamomile Honey Tea | Tea | $4.00 | No | hot |
| Iced Matcha Latte | Tea | $5.50 | No | cold |
| Earl Grey Latte | Tea | $4.75 | No | hot |
| Almond Croissant | Pastries | $4.25 | Yes | both |
| Butter Croissant | Pastries | $3.50 | No | both |
| Blueberry Muffin | Pastries | $3.75 | Yes | both |
| Cinnamon Roll | Pastries | $4.50 | Yes | both |
| Banana Bread | Pastries | $3.75 | No | both |

### Product Options (add-ons seeded for major drinks and some pastries)

Examples: Extra Espresso Shot (+$0.75), Extra Vanilla Syrup (+$0.50), Oat Milk (+$0.75), Caramel Drizzle (+$0.50), Sweet Cream (+$0.75), Extra Matcha (+$0.75), Extra Almond Cream (+$0.50), Extra Cream Cheese Frosting (+$0.50)

---

## 13. Key Implementation Notes

**Running on Chrome instead of Android:**
The project folder was originally named `BEAN & BREW`. The `&` character is a special command separator in Windows PowerShell, causing Gradle, nodemon, and file operations to fail. Folder renamed to `BEAN_AND_BREW`. Flutter runs on Chrome (`flutter run -d chrome`) instead of Android emulator.

**`dart:html` for location:**
`geolocator` package removed since app runs on web. Uses `dart:html`'s `window.navigator.geolocation` instead. Has `// ignore: avoid_web_libraries_in_flutter` comment to suppress lint.

**Price type mismatch:**
MySQL returns DECIMAL as String in JSON. All price fields use:
```dart
double.parse(item['base_price'].toString()).toStringAsFixed(2)
```

**`_isDrink` check in product page:**
Drink vs pastry detection uses `category_name`:
```dart
bool get _isDrink {
  final category = widget.product['category_name'] ?? '';
  return category != 'Pastries';
}
```
**Important:** Products from weather API must include `category_name` (join with categories table in weatherController.js). Products from home page recommended carousel that came from weather didn't originally include `category_name`, causing all products to show pastry options — fixed by adding LEFT JOIN in weatherController.

**`withOpacity` deprecated:**
Use `Colors.black.withValues(alpha: 0.06)` instead of `Colors.black.withOpacity(0.06)` throughout all files.

**Cart auto-creation:**
The `getOrCreateCart(userId)` helper in cartController.js automatically creates a cart for new users — no manual cart creation needed.

**Sequential data loading on home page:**
`_initData()` calls `_loadWeather()` then `_loadProducts()` with `await` to prevent race condition where products override weather recommendations.

---

## 14. Known Issues & Decisions

**Cart count badge:** Both home and menu floating cart buttons show hardcoded `'0'`. Needs `CartProvider` to track real count.

**Bottom nav incomplete:** Orders and Profile tabs in bottom nav don't navigate anywhere yet — only Home↔Menu navigation is wired.

**Google OAuth:** Button exists on login/signup but `_signInWithGoogle()` is empty. Deferred because Chrome localhost port changes every run, making OAuth redirect URLs unstable during development.

**Providers are stubs:** `AuthProvider`, `CartProvider`, `OrderProvider` are empty `ChangeNotifier` classes. They need to be implemented to share state (cart count, logged-in user) across pages.

**Profile photo:** Shows generic `Icons.person` icon everywhere. Google profile photo will work after OAuth is implemented.

**`_warmed` bool in product_page:** Declared and toggleable but not included in `selected_options` sent to cart. Add it to the options map when cart is being finalized.

---

## 15. What To Build Next

### Immediate next step: Cart Page (`cart_page.dart`)

The backend is fully ready (`GET /cart`, `POST /cart/items`, etc.). Build the Flutter UI:

**Cart page should show:**
- List of cart items with image, name, selected options summary, price, quantity stepper
- Remove item (swipe or × button)
- Promo code input + Apply button → `POST /cart/promo`
- Subtotal, Tax (8%), Delivery Fee (FREE), Total
- "Checkout →" button at bottom

**Cart page API calls:**
```dart
// Load cart
GET /api/cart (with JWT)

// Update quantity
PUT /api/cart/items/:id  body: { quantity: 2 }

// Remove item
DELETE /api/cart/items/:id

// Apply promo
POST /api/cart/promo  body: { code: "SAVE10" }
```

**After cart page, build in this order:**
1. `CartProvider` — holds cart state app-wide, exposes item count for badge
2. Checkout page — order summary, pickup/delivery, payment method, `POST /orders`
3. Orders backend — `orderController.js` with place order, get orders, get single order
4. Order tracking page — status stepper
5. Orders history page
6. Profile page — user info, favorites, saved addresses, logout
7. Google OAuth
8. Polish — shimmer loaders, empty states, error handling, real cart count badge

### Design references
Original mockup images were provided for all pages:
- Cart: items list, promo code, fee breakdown, Checkout button
- Checkout: numbered steps (Order Summary → Delivery/Pickup → Payment), Place Order button
- Order Tracking: vertical stepper (Confirmed → Preparing → Ready → Enjoy), order summary
- Profile: profile photo, Recent Favorites horizontal scroll, Saved Addresses, Payment Methods, Notifications toggle, Logout

### Color palette
```
Primary dark brown:  #2C1A0E
Medium brown:        #7A6652
Light brown border:  #E0D5C5
Background cream:    #F5F0E8
Accent orange:       #B87333
White:               #FFFFFF
```

### Font usage
- `GoogleFonts.playfairDisplay()` — page titles, section headers, product names
- `GoogleFonts.lato()` — body text, labels, prices, buttons

---

*Last updated: After completing Home, Menu, and Product Detail pages. Cart backend complete. Cart Flutter UI is next.*
