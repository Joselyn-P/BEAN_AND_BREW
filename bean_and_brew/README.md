# Bean & Brew — Project Documentation & Handoff Guide

> Freshly brewed, just a tap away.

A full-stack coffee shop ordering application built with **Flutter** (frontend), **Express.js** (backend), and **MySQL via XAMPP** (database). Features weather-adaptive drink recommendations, email/password authentication, and Google OAuth.

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
- Google OAuth login and registration
- Weather-adaptive home page (shows hot/cold drink recommendations based on real-time weather)
- Full menu browsing with search and category filtering
- Product detail page with customization (size, temperature, sugar, add-ons)
- Add to cart, update quantities, remove items, apply promo codes
- Full checkout flow with pickup/delivery toggle and payment method selection
- Order history with status tracking
- Order tracking page with live stepper
- Order detail/receipt page for completed orders
- Profile page with favorites, settings, and logout

---

## 2. Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | Flutter (Dart) | Cross-platform UI, running on Chrome web |
| State management | Provider | Cart count app-wide |
| HTTP client | `http` package | API requests |
| Fonts | Google Fonts | Playfair Display (headings) + Lato (body) |
| Backend | Express.js (Node.js) | REST API server |
| Auth | JWT + bcryptjs + Google OAuth 2.0 | Session management |
| Google Auth | google-auth-library | Verify Google ID tokens on backend |
| Database | MySQL 8 via XAMPP | Persistent storage |
| Weather | OpenWeatherMap API | Real-time weather (called from backend) |
| Location | `dart:html` Geolocation | Browser GPS for weather |
| Token storage | flutter_secure_storage | JWT stored on device |
| Google Sign-In | google_sign_in Flutter package | Google OAuth on frontend |

---

## 3. System Architecture

```
Flutter (Chrome web) — fixed port 8080
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
       → Backend queries DB for matching products (with category JOIN)
       → Returns { condition, temp, city, recommendationType, products[] }
```

**Google OAuth flow:**
```
Flutter → GoogleSignIn.signIn() → gets idToken
       → POST /api/auth/google { id_token }
       → Backend verifies with OAuth2Client
       → Creates or updates user in DB
       → Returns JWT + user object
       → Flutter stores token, navigates to HomePage
```

**Run Flutter with fixed port (always use this):**
```powershell
flutter run -d chrome --web-port=8080
```

---

## 4. Project Structure

```
bean_and_brew/                         ← root (renamed from "BEAN & BREW")
├── bean_and_brew_backend/             ← Express.js
└── bean_and_brew_app/                 ← Flutter
```

### Backend Structure

```
bean_and_brew_backend/
├── src/
│   ├── config/
│   │   └── db.js                     ✅ mysql2 connection pool
│   ├── middleware/
│   │   └── auth.js                   ✅ JWT verification guard
│   ├── routes/
│   │   ├── auth.js                   ✅ register, login, google
│   │   ├── products.js               ✅ full product routes
│   │   ├── cart.js                   ✅ full cart routes
│   │   ├── orders.js                 ✅ place, getAll, getOne
│   │   ├── profile.js                ✅ favorites toggle + get
│   │   └── weather.js                ✅ recommend endpoint
│   ├── controllers/
│   │   ├── authController.js         ✅ register, login, googleLogin
│   │   ├── productController.js      ✅ getAllProducts, getFeatured, getByCategory, getProduct
│   │   ├── cartController.js         ✅ getCart, addItem, updateItem, removeItem, applyPromo
│   │   ├── orderController.js        ✅ placeOrder, getOrders, getOrder
│   │   └── weatherController.js      ✅ getRecommendations
│   ├── models/                       ⬜ all empty (queries in controllers)
│   ├── helpers/                      ⬜ all empty
│   └── app.js                        ✅ all routes registered, CORS configured
├── .env                              ✅ filled
├── .gitignore                        ✅ node_modules + .env excluded
└── package.json                      ✅ nodemon via direct path
```

### Flutter Structure

```
bean_and_brew_app/
├── web/
│   └── index.html                    ✅ google-signin-client_id meta tag added
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart    ✅ all endpoints
│   │   ├── services/
│   │   │   ├── auth_service.dart     ✅ login, register, loginWithGoogle, logout
│   │   │   ├── weather_service.dart  ✅ GPS → backend weather
│   │   │   └── storage_service.dart  ✅ JWT secure storage
│   │   ├── models/                   ⬜ all empty stubs
│   │   └── providers/
│   │       ├── auth_provider.dart    ⬜ stub
│   │       ├── cart_provider.dart    ✅ loadCart, increment, reset, itemCount
│   │       └── order_provider.dart   ⬜ stub
│   ├── features/
│   │   ├── auth/
│   │   │   ├── login_page.dart       ✅ email/password + Google OAuth
│   │   │   └── signup_page.dart      ✅ email/password + Google OAuth
│   │   ├── home/
│   │   │   ├── home_page.dart        ✅ weather, recommended, featured, nav
│   │   │   └── widgets/
│   │   │       └── weather_banner.dart ✅ Flutter icons, onOrderNow callback
│   │   ├── menu/
│   │   │   ├── menu_page.dart        ✅ grid, search, category tabs, cart button
│   │   │   └── product_page.dart     ✅ customization, add-ons, add to cart
│   │   ├── cart/
│   │   │   └── cart_page.dart        ✅ items, qty, promo, summary, checkout
│   │   ├── checkout/
│   │   │   └── checkout_page.dart    ✅ order summary, pickup/delivery, payment, OrderConfirmedPage
│   │   ├── orders/
│   │   │   ├── orders_page.dart      ✅ order history, tap routing
│   │   │   ├── order_tracking_page.dart ✅ live stepper, 5-step flow
│   │   │   └── order_detail_page.dart ✅ receipt view for completed orders
│   │   └── profile/
│   │       └── profile_page.dart     ✅ user info, favorites, settings, logout
│   ├── shared/
│   │   └── widgets/                  ⬜ all empty stubs
│   └── main.dart                     ✅ MultiProvider, starts at LoginPage
└── pubspec.yaml                      ✅ all dependencies installed
```

---

## 5. Database Design

### Tables

| Table | Status | Description |
|---|---|---|
| `users` | ✅ in use | email + Google auth users |
| `addresses` | ⬜ empty | Saved delivery addresses |
| `payment_methods` | ⬜ empty | Saved cards/wallets |
| `categories` | ✅ seeded | Hot Coffee, Cold Brew, Tea, Pastries |
| `products` | ✅ seeded | 20 products |
| `product_options` | ✅ seeded | Add-ons for drinks + pastries |
| `favorites` | ✅ in use | User ↔ product toggle |
| `carts` | ✅ in use | One per user, auto-created |
| `cart_items` | ✅ in use | Items with selected_options JSON |
| `promo_codes` | ✅ seeded | BREW10, SAVE5, WELCOME |
| `orders` | ✅ in use | Full order lifecycle |
| `order_items` | ✅ in use | Snapshot of cart items at order time |
| `order_tracking` | ✅ in use | Append-only status log |
| `weather_recommendations` | ⬜ empty | Not used (logic in controller) |

### Order Status ENUM
```sql
ENUM('placed','confirmed','preparing','delivery','pickup','completed','cancelled')
```

### Order Status Flow
```
placed → confirmed → preparing → delivery OR pickup → completed
```

---

## 6. API Reference

Base URL: `http://localhost:3000/api`

Protected routes require: `Authorization: Bearer <jwt_token>`

### Auth

| Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|
| POST | `/auth/register` | No | ✅ | Register with full_name, email, password |
| POST | `/auth/login` | No | ✅ | Login → returns token + user |
| POST | `/auth/google` | No | ✅ | Google OAuth → returns token + user |

**POST `/auth/google` body:**
```json
{ "id_token": "google_id_token_from_flutter" }
```

### Products

| Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|
| GET | `/products` | No | ✅ | 2 per category (home recommended) |
| GET | `/products?category=all` | No | ✅ | All products (menu page) |
| GET | `/products?category=hot-coffee` | No | ✅ | Filter by slug |
| GET | `/products/featured` | No | ✅ | is_featured = 1 |
| GET | `/products/:id` | No | ✅ | Single product + options array |

### Cart

| Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|
| GET | `/cart` | Yes | ✅ | Cart with items, subtotal, tax, total, item_count |
| POST | `/cart/items` | Yes | ✅ | Add item |
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
    "warmed": false,
    "addons": {}
  },
  "item_price": "6.25"
}
```

### Orders

| Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|
| POST | `/orders` | Yes | ✅ | Place order → clears cart, creates tracking |
| GET | `/orders` | Yes | ✅ | All orders for user (newest first) |
| GET | `/orders/:id` | Yes | ✅ | Single order + items + tracking |

**POST `/orders` body:**
```json
{
  "fulfillment_type": "pickup",
  "payment_method": "cash",
  "address_id": null,
  "promo_code_id": null
}
```

**GET `/orders/:id` response includes:**
```json
{
  "id": "uuid",
  "status": "placed",
  "fulfillment_type": "pickup",
  "subtotal": "10.75",
  "tax": "0.86",
  "delivery_fee": "0.00",
  "total": "11.61",
  "payment_method": "cash",
  "placed_at": "2024-01-01T10:00:00",
  "items": [...],
  "tracking": [...]
}
```

### Weather

| Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|
| GET | `/weather/recommend?lat=x&lon=y` | No | ✅ | Weather + recommended products |

**Weather → recommendation mapping:**
- Rain, Drizzle, Thunderstorm, Snow → `hot` → "Honey Lavender Latte"
- Clear, Clouds, Haze, Mist, Fog, Smoke → `cold` → "Iced Caramel Macchiato"

### Profile

| Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|
| GET | `/profile/favorites` | Yes | ✅ | Get user's favorited products |
| POST | `/profile/favorites/:productId` | Yes | ✅ | Toggle favorite (add/remove) |

---

## 7. App Pages & Features

| Page | File | Status | Notes |
|---|---|---|---|
| Login | `login_page.dart` | ✅ | Email/password + Google OAuth wired |
| Sign Up | `signup_page.dart` | ✅ | Email/password + Google OAuth wired |
| Home | `home_page.dart` | ✅ | Weather, recommended, featured, bottom nav |
| Weather Banner | `weather_banner.dart` | ✅ | Flutter icons, onOrderNow callback |
| Menu | `menu_page.dart` | ✅ | Grid, search, category tabs, cart button |
| Product Detail | `product_page.dart` | ✅ | Drink vs pastry detection, add to cart |
| Cart | `cart_page.dart` | ✅ | Items, qty stepper, promo, fee summary |
| Checkout | `checkout_page.dart` | ✅ | 3-step flow, place order, OrderConfirmedPage |
| Order Tracking | `order_tracking_page.dart` | ✅ | 5-step stepper, auto-refresh 30s |
| Order Detail | `order_detail_page.dart` | ✅ | Receipt view for completed/cancelled orders |
| Orders History | `orders_page.dart` | ✅ | All orders, tap routing by status |
| Profile | `profile_page.dart` | ✅ | User info, favorites, settings, logout |

### Order Tap Routing Logic
```
status == 'completed' OR 'cancelled' → OrderDetailPage (receipt)
status == anything else              → OrderTrackingPage (live stepper)
```

### Stepper Steps (order_tracking_page.dart)
```
placed → confirmed → preparing → delivery/pickup → completed
```
Delivery step shows for delivery orders, pickup step shows for pickup orders (filtered via `_relevantSteps` getter).

---

## 8. Progress Tracker

### ✅ Done
- Project setup, GitHub repo (`Joselyn-P/BEAN_AND_BREW`)
- Google Fonts (Playfair Display + Lato)
- Auth: email/password + Google OAuth (full flow)
- Home page: weather banner, recommended, featured, navigation
- Menu page: grid, search, category filter
- Product detail: drink vs pastry detection, customization, add to cart
- Cart: full CRUD, promo codes, fee summary
- Checkout: order placement, pickup/delivery, payment method
- Order Confirmed page
- Orders History: all orders, status-based routing
- Order Tracking: 5-step stepper, auto-refresh, fulfillment-aware
- Order Detail: receipt view for completed orders
- Profile: user info, favorites, settings, logout
- CartProvider: real item count badge

### ⬜ Still To Do
- **Shared widgets** — `product_card.dart`, `custom_button.dart`, `loading_shimmer.dart`, `bottom_nav.dart` (all empty stubs, not yet extracted)
- **Models** — `user_model.dart`, `product_model.dart`, `cart_model.dart`, `order_model.dart` (all empty, not needed urgently)
- **AuthProvider** — currently stub, user state managed via StorageService directly
- **Polish** — shimmer loading skeletons, better error handling throughout
- **Favorite toggle on product page** — heart button exists but not wired to backend
- **Profile photo** — shows generic icon, Google photo works after OAuth
- **Addresses & Payment Methods** — settings rows exist but don't navigate anywhere
- **Re-order button** — not implemented on order detail/history

---

## 9. Current State of Each File

### `main.dart`
MultiProvider with AuthProvider (stub), CartProvider (✅), OrderProvider (stub). Starts at `LoginPage`. Theme seed: `Color(0xFF3E1F00)`.

### `api_constants.dart`
```dart
static const String baseUrl     = 'http://localhost:3000/api';
static const String login       = '$baseUrl/auth/login';
static const String register    = '$baseUrl/auth/register';
static const String googleLogin = '$baseUrl/auth/google';
static const String products    = '$baseUrl/products';
static const String cart        = '$baseUrl/cart';
static const String orders      = '$baseUrl/orders';
static const String weather     = '$baseUrl/weather/recommend';
static const String profile     = '$baseUrl/profile';
```

### `auth_service.dart`
- `login(email, password)` → POST `/auth/login`
- `register(fullName, email, password)` → POST `/auth/register`
- `loginWithGoogle()` → GoogleSignIn → POST `/auth/google` → saves token + user
- `logout()` → `_googleSignIn.signOut()` + `StorageService.clearAll()`
- `GoogleSignIn` initialized with clientId from Google Cloud Console

### `storage_service.dart`
- `saveToken/getToken/deleteToken`
- `saveUser/getUser`
- `clearAll()` — used for logout

### `weather_service.dart`
- Uses `dart:html` + `// ignore: avoid_web_libraries_in_flutter`
- Calls `GET /api/weather/recommend?lat=x&lon=y`
- Falls back to `{ condition: 'Clear', city: 'Your City', ... }` on error
- Has `_getBannerText(String)` and `_getBannerColor(String)` — handles: Rain, Drizzle, Thunderstorm, Snow, Clear, Clouds, Haze, Mist, Fog, Smoke

### `cart_provider.dart`
- `loadCart()` → GET `/api/cart` → sets `_itemCount`
- `setCount(int)`, `increment()`, `reset()`
- `itemCount` getter used by home + menu cart badge

### `login_page.dart`
- Email + password → `AuthService.login()` → `CartProvider.loadCart()` → HomePage
- Google button → `AuthService.loginWithGoogle()` → `CartProvider.loadCart()` → HomePage
- Sign Up link → `SignupPage`

### `signup_page.dart`
- Full Name, Email, Password, Confirm Password
- Validates passwords match
- Register button → `AuthService.register()` → `CartProvider.loadCart()` → HomePage
- Google button → `AuthService.loginWithGoogle()` → same flow
- Sign In link → `Navigator.pop()`

### `home_page.dart`
- `_initData()` → awaits `_loadWeather()` then `_loadProducts()`
- `_loadWeather()` sets `_weatherData` + `_recommended` from weather products
- `_loadProducts()` sets `_featured`, only updates `_recommended` if empty
- `_loadByCategory(slug)` replaces `_recommended`
- `_loadUser()` reads username from StorageService
- Bottom nav: Home(0), Menu(1→MenuPage), Orders(2→OrdersPage), Profile(3→ProfilePage)
- Cart button → CartPage, reloads cart count on return
- Order Now → finds product by name in `_recommended` → ProductPage
- Recommended items → ProductPage
- Featured items → ProductPage
- CartProvider.itemCount used for badge

### `weather_banner.dart`
- Props: `weatherData` Map + `onOrderNow` VoidCallback
- Own `_getBannerText()`, `_getBannerBgColor()`, `_getWeatherIcon()`, `_getRecommendedDrink()`
- Handles: Rain, Drizzle, Thunderstorm, Snow, Clear, Clouds, Haze, Mist, Fog, Smoke
- Uses Flutter icons (no emoji → no Noto font warnings)

### `menu_page.dart`
- Category tabs: All, Hot Coffee, Cold Brew, Tea, Pastries
- `_loadAllProducts()` → `GET /products?category=all`
- `_loadByCategory(slug)` → `GET /products?category=slug`
- Search filters `_allProducts` client-side
- Product card tap + `+` button both → ProductPage
- Cart button → CartPage
- Bottom nav: Menu selected, Home tap → pop

### `product_page.dart`
- Receives `product` Map
- `_isDrink`: `category_name != 'Pastries'`
- Drinks: Size (Small/Medium/Large +$0/+$0.50/+$1.00), Temperature (filtered by temperature_type), Sugar (0%/50%/100%), Oat Milk toggle (+$0.75)
- Pastries: Warmed toggle only (`_warmed` bool)
- `_loadProductOptions()` → `GET /products/:id` → sets `_options`
- `_totalPrice`: base + size + oat milk + addon counts × modifier × quantity
- `_addToCart()` → POST `/cart/items` → `CartProvider.increment()` → snackbar → pop
- `_warmed` is included in `selected_options` sent to backend

### `cart_page.dart`
- `_loadCart()` → GET `/cart`
- `_updateQuantity(id, qty)` → PUT `/cart/items/:id` (qty≤0 calls `_removeItem`)
- `_removeItem(id)` → DELETE `/cart/items/:id`
- `_applyPromo()` → POST `/cart/promo` → calculates discount
- `_buildOptionsSubtitle()` parses selected_options JSON → readable string
- `_finalTotal` = total - discount
- Checkout button → CheckoutPage with items, subtotal, tax, discount, promoCodeId
- Reloads cart on return from checkout

### `checkout_page.dart`
- Receives: items, subtotal, tax, discount, promoCodeId
- `_fulfillmentType`: 'pickup' or 'delivery'
- `_paymentMethod`: 'google_pay', 'visa', 'cash'
- `_deliveryFee`: $2.00 for delivery, $0 for pickup
- `_placeOrder()` → POST `/orders` → `CartProvider.reset()` → OrderConfirmedPage
- `OrderConfirmedPage` (same file): shows order ID, total, Back to Home + Track My Order buttons

### `orders_page.dart`
- `_loadOrders()` → GET `/orders`
- `_onOrderTap()`: completed/cancelled → OrderDetailPage, else → OrderTrackingPage
- Status colors: placed(brown), confirmed(blue), preparing(orange), delivery/pickup(purple), completed(green), cancelled(red)
- "View Receipt →" for completed, "Track Order →" for active
- Pull-to-refresh supported

### `order_tracking_page.dart`
- `_loadOrder()` → GET `/orders/:id` → sets `_order`, `_items`
- Auto-refreshes every 30 seconds via `Timer.periodic`
- `_relevantSteps` filters delivery vs pickup step based on `fulfillment_type`
- 5 steps: placed → confirmed → preparing → delivery/pickup → completed
- `_currentStepIndex` based on order status
- Completed steps: strikethrough text, green dot with checkmark
- Active step: dark brown filled dot, sublabel shown
- Future steps: grey empty dot

### `order_detail_page.dart`
- `_loadOrder()` → GET `/orders/:id`
- Read-only receipt view
- Shows: completed badge, order ID, date, fulfillment type, payment method, items, price summary

### `profile_page.dart`
- Reads user from StorageService (no extra API call for basic info)
- `_loadFavorites()` → GET `/profile/favorites`
- Logout → confirmation dialog → `AuthService.logout()` → LoginPage (removes all routes)
- Notifications toggle (local state only, not persisted)
- Settings rows (Saved Addresses, Payment Methods) → TODO navigate

### `authController.js`
- `register`: bcrypt hash, INSERT user, return JWT
- `login`: find by email, bcrypt compare, return JWT
- `googleLogin`: OAuth2Client.verifyIdToken → find/create user → return JWT

### `productController.js`
- `getAllProducts`: no params → 2/category via ROW_NUMBER OVER PARTITION; `?category=all` → all; `?category=slug` → filtered
- `getFeatured`: is_featured=1, LIMIT 6
- `getProduct`: single + options array

### `cartController.js`
- `getOrCreateCart(userId)` helper — auto-creates if none
- Tax: 8% of subtotal
- `addItem`: checks existing product, increments qty or inserts new
- Returns full cart object on every mutation

### `orderController.js`
- `placeOrder`: gets cart → calculates totals → INSERT order with status='placed' → copies cart_items to order_items → INSERT tracking entry → DELETE cart_items
- `getOrders`: includes item_count subquery
- `getOrder`: returns order + items (with product name/image) + tracking log

### `weatherController.js`
- Calls OpenWeather with lat/lon
- Maps Rain/Drizzle/Thunder/Snow → hot, else → cold
- `SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c` (category JOIN required for `_isDrink` check in Flutter)
- ORDER BY RAND(), LIMIT 5

### `profile.js` (route file, no separate controller)
- `GET /profile/favorites` → joins favorites + products
- `POST /profile/favorites/:productId` → toggle (delete if exists, insert if not)

---

## 10. Environment Setup

### Prerequisites

| Tool | Version |
|---|---|
| Flutter | 3.32.2 (stable) |
| Node.js | 18+ |
| XAMPP | 8.x |
| VS Code | Latest |

### `.env`
```env
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=bean_and_brew
JWT_SECRET=your_secret_key_here
GOOGLE_CLIENT_ID=your_web_client_id.apps.googleusercontent.com
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

### `web/index.html` — inside `<head>`
```html
<meta name="google-signin-client_id" 
      content="YOUR_CLIENT_ID.apps.googleusercontent.com">
```

### Google Cloud Console Setup
- Project: `Bean and Brew`
- OAuth Consent Screen: External, test user added
- Credential: OAuth 2.0 Client ID → Web application
- Authorized JavaScript origins: `http://localhost:8080`
- Authorized redirect URIs: `http://localhost:8080`

### `package.json` scripts
```json
"scripts": {
  "start": "node src/app.js",
  "dev": "node node_modules/nodemon/bin/nodemon.js src/app.js"
}
```

---

## 11. Running the Project

**Terminal 1 — Backend:**
```powershell
cd bean_and_brew_backend
npm run dev
# Expected: Bean & Brew API running on port 3000
```

**Terminal 2 — Flutter (always use fixed port):**
```powershell
cd bean_and_brew_app
flutter run -d chrome --web-port=8080
```

**XAMPP:** Apache + MySQL both green before starting.

**Location permission:** Chrome asks for GPS on home page load. Click Allow for weather to work. Falls back to default on deny.

### Quick Checklist
- [ ] XAMPP running (Apache + MySQL green)
- [ ] Backend running on port 3000
- [ ] `flutter run -d chrome --web-port=8080` launches
- [ ] Login page appears
- [ ] Email/password login works
- [ ] Google OAuth login works
- [ ] Home page shows weather + products
- [ ] Menu, Product Detail, Cart, Checkout all work
- [ ] Orders History shows placed orders
- [ ] Order Tracking stepper shows correct step

---

## 12. Database Seed Data

### Categories (4)
Hot Coffee, Cold Brew, Tea, Pastries

### Products (20)

| Name | Category | Price | Featured | Temp |
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

### Promo Codes
| Code | Type | Value | Max Uses |
|---|---|---|---|
| BREW10 | percent | 10% | 100 |
| SAVE5 | fixed | $5.00 | 50 |
| WELCOME | percent | 15% | 1000 |

### Product Options (add-ons seeded for major items)
Examples: Extra Espresso Shot (+$0.75), Extra Vanilla Syrup (+$0.50), Caramel Drizzle (+$0.50), Sweet Cream (+$0.75), Extra Matcha (+$0.75), Extra Almond Cream (+$0.50), Extra Cream Cheese Frosting (+$0.50)

---

## 13. Key Implementation Notes

**Fixed port for Google OAuth:**
Always run `flutter run -d chrome --web-port=8080`. Google Cloud Console has `http://localhost:8080` as the only authorized origin. Using a different port breaks OAuth.

**`dart:html` for GPS:**
`geolocator` removed. Uses `window.navigator.geolocation`. Has `// ignore: avoid_web_libraries_in_flutter`.

**`_isDrink` check:**
```dart
bool get _isDrink => (widget.product['category_name'] ?? '') != 'Pastries';
```
Products from weather API must include `category_name` — weatherController uses LEFT JOIN with categories table.

**Price parsing:**
MySQL DECIMAL comes as String in JSON:
```dart
double.parse(item['base_price'].toString()).toStringAsFixed(2)
```

**withOpacity deprecated:**
Use `.withValues(alpha: 0.xx)` throughout all files.

**Nodemon path:**
`node node_modules/nodemon/bin/nodemon.js src/app.js` — direct path required because `BEAN & BREW` folder `&` broke standard nodemon on Windows PowerShell.

**Cart auto-creation:**
`getOrCreateCart(userId)` in cartController automatically creates a cart — no manual setup needed.

**Sequential home page loading:**
`_initData()` awaits `_loadWeather()` before `_loadProducts()` to prevent race condition overwriting weather-based recommendations.

**Order initial status:**
New orders start as `'placed'` (not `'confirmed'`). The store confirms manually (update via phpMyAdmin or future admin panel).

**`_warmed` in product page:**
Warmed toggle for pastries is included in `selected_options` sent to cart backend.

---

## 14. Known Issues & Decisions

**Favorite heart button on product page:** Button exists (top-right) but `onTap` is empty. Backend endpoint `POST /profile/favorites/:productId` is ready — just needs Flutter wiring.

**Profile photo:** Shows generic `Icons.person`. Google users get real photo after OAuth login (stored in `profile_photo_url`). Display logic exists but photo URL from Google may expire.

**Addresses & Payment Methods:** Settings rows in profile page navigate nowhere (onTap: `() {}`). Backend not implemented for these.

**AuthProvider stub:** User state is read directly from StorageService in each page instead of shared via Provider. Works but not ideal architecture.

**Cart count badge:** Powered by CartProvider. Increments on addToCart, reloads on returning from CartPage, resets on order placement.

**`_warmed` not in `_totalPrice`:** Warmed is a free option (no price modifier), so not added to total calculation. Correct behavior.

---

## 15. What To Build Next

### Priority 1 — Wire up favorites heart button on product page

Backend is ready. In `product_page.dart`:
```dart
// Add state variable
bool _isFavorited = false;

// Check favorite status on load
Future<void> _checkFavorite() async {
  final token = await StorageService.getToken();
  final res = await http.get(
    Uri.parse('${ApiConstants.profile}/favorites'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode == 200) {
    final favs = List<Map<String,dynamic>>.from(json.decode(res.body));
    setState(() {
      _isFavorited = favs.any((f) => f['id'] == widget.product['id']);
    });
  }
}

// Toggle on heart tap
Future<void> _toggleFavorite() async {
  final token = await StorageService.getToken();
  await http.post(
    Uri.parse('${ApiConstants.profile}/favorites/${widget.product['id']}'),
    headers: {'Authorization': 'Bearer $token'},
  );
  setState(() => _isFavorited = !_isFavorited);
}
```

### Priority 2 — Shimmer loading skeletons

Replace `CircularProgressIndicator` with shimmer effects using the `shimmer` package (already in pubspec). Create `lib/shared/widgets/loading_shimmer.dart`.

### Priority 3 — Extract shared widgets

Move repeated code into shared widgets:
- `bottom_nav.dart` — shared bottom nav used on all pages
- `product_card.dart` — reusable card for menu + home
- `custom_button.dart` — reusable primary/outlined button

### Priority 4 — Admin order status updates

Currently order status must be changed manually in phpMyAdmin. Consider a simple admin endpoint:
```js
// PUT /api/orders/:id/status (admin only)
router.put('/:id/status', auth, async (req, res) => {
  const { status } = req.body;
  await pool.query('UPDATE orders SET status = ? WHERE id = ?', [status, req.params.id]);
  await pool.query(
    'INSERT INTO order_tracking (id, order_id, status) VALUES (UUID(), ?, ?)',
    [req.params.id, status]
  );
  res.json({ message: 'Status updated' });
});
```

### Priority 5 — Polish
- Error states (network errors, empty states)
- Better form validation (email format, password strength)
- Re-order button on OrderDetailPage
- Saved addresses and payment methods in profile

---

## Color Palette
```
Primary dark brown:  #2C1A0E
Medium brown:        #7A6652
Light brown border:  #E0D5C5
Background cream:    #F5F0E8
Accent orange:       #B87333
Success green:       #2E7D52
Info blue:           #4285F4
White:               #FFFFFF
```

## Font Usage
- `GoogleFonts.playfairDisplay()` — page titles, section headers, product names, brand name
- `GoogleFonts.lato()` — body text, labels, prices, buttons, subtitles

---

*Last updated: After completing all major pages including Google OAuth, Orders History, Order Tracking, Order Detail, and Profile. Favorites wiring and shimmer loaders are next.*
