-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 06, 2026 at 03:54 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bean_and_brew`
--

-- --------------------------------------------------------

--
-- Table structure for table `addresses`
--

CREATE TABLE `addresses` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `user_id` char(36) NOT NULL,
  `label` varchar(50) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--

CREATE TABLE `carts` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `user_id` char(36) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `carts`
--

INSERT INTO `carts` (`id`, `user_id`, `updated_at`) VALUES
('0ba84f8f-5fd5-11f1-b8fe-745d2224b197', '0ba0a0bd-5fd5-11f1-b8fe-745d2224b197', '2026-06-04 05:20:05'),
('2bb35f33-5db2-11f1-a137-745d2224b197', '6ced3ced-58fc-11f1-8f1d-745d2224b197', '2026-06-01 12:05:24'),
('2fa8681e-60f5-11f1-986f-745d2224b197', '2fa500e7-60f5-11f1-986f-745d2224b197', '2026-06-05 15:42:40');

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

CREATE TABLE `cart_items` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `cart_id` char(36) NOT NULL,
  `product_id` char(36) NOT NULL,
  `quantity` int(11) DEFAULT 1,
  `selected_options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`selected_options`)),
  `item_price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `icon_url` text DEFAULT NULL,
  `display_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `slug`, `icon_url`, `display_order`) VALUES
('47e236c6-5945-11f1-bf68-745d2224b197', 'Hot Coffee', 'hot-coffee', NULL, 1),
('47e23932-5945-11f1-bf68-745d2224b197', 'Cold Brew', 'cold-brew', NULL, 2),
('47e2398f-5945-11f1-bf68-745d2224b197', 'Tea', 'tea', NULL, 3),
('47e239b4-5945-11f1-bf68-745d2224b197', 'Pastries', 'pastries', NULL, 4);

-- --------------------------------------------------------

--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `user_id` char(36) NOT NULL,
  `product_id` char(36) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `user_id` char(36) NOT NULL,
  `address_id` char(36) DEFAULT NULL,
  `promo_code_id` char(36) DEFAULT NULL,
  `fulfillment_type` enum('pickup','delivery') DEFAULT 'pickup',
  `status` enum('placed','confirmed','preparing','delivery','pickup','completed','cancelled') DEFAULT 'placed',
  `subtotal` decimal(10,2) DEFAULT NULL,
  `tax` decimal(10,2) DEFAULT NULL,
  `delivery_fee` decimal(10,2) DEFAULT 0.00,
  `total` decimal(10,2) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `placed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `address_id`, `promo_code_id`, `fulfillment_type`, `status`, `subtotal`, `tax`, `delivery_fee`, `total`, `payment_method`, `placed_at`, `updated_at`) VALUES
('2aa945ee-6149-11f1-a964-745d2224b197', '6ced3ced-58fc-11f1-8f1d-745d2224b197', NULL, 'deaa995e-5fee-11f1-ab0e-745d2224b197', 'pickup', 'placed', 12.00, 0.96, 0.00, 12.96, 'cash', '2026-06-06 01:43:50', '2026-06-06 01:43:50'),
('3111d5e1-60f7-11f1-986f-745d2224b197', '6ced3ced-58fc-11f1-8f1d-745d2224b197', NULL, 'deaa995e-5fee-11f1-ab0e-745d2224b197', 'pickup', 'preparing', 8.00, 0.64, 0.00, 8.64, 'visa', '2026-06-05 15:57:02', '2026-06-06 01:48:35'),
('74b831b5-60cc-11f1-89db-745d2224b197', '6ced3ced-58fc-11f1-8f1d-745d2224b197', NULL, 'deaa995e-5fee-11f1-ab0e-745d2224b197', 'pickup', 'pickup', 14.75, 1.18, 0.00, 15.93, 'cash', '2026-06-05 10:51:07', '2026-06-05 10:54:52'),
('a44c964c-60cc-11f1-89db-745d2224b197', '6ced3ced-58fc-11f1-8f1d-745d2224b197', NULL, 'deaa995e-5fee-11f1-ab0e-745d2224b197', 'pickup', 'completed', 6.75, 0.54, 0.00, 7.29, 'cash', '2026-06-05 10:52:27', '2026-06-05 10:58:46'),
('e34f0c73-5ff2-11f1-ab0e-745d2224b197', '6ced3ced-58fc-11f1-8f1d-745d2224b197', NULL, 'deaa995e-5fee-11f1-ab0e-745d2224b197', 'pickup', 'confirmed', 6.00, 0.48, 0.00, 6.48, 'cash', '2026-06-04 08:53:42', '2026-06-04 08:53:42');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `order_id` char(36) NOT NULL,
  `product_id` char(36) NOT NULL,
  `quantity` int(11) DEFAULT 1,
  `selected_options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`selected_options`)),
  `item_price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `quantity`, `selected_options`, `item_price`) VALUES
('2aaa0c48-6149-11f1-a964-745d2224b197', '2aa945ee-6149-11f1-a964-745d2224b197', 'd1ef0682-5a84-11f1-9b9a-745d2224b197', 1, '\"{\\\"size\\\":\\\"Small\\\",\\\"temperature\\\":\\\"Hot\\\",\\\"sugar\\\":\\\"50%\\\",\\\"oat_milk\\\":false,\\\"addons\\\":{}}\"', 3.50),
('2aaa9e18-6149-11f1-a964-745d2224b197', '2aa945ee-6149-11f1-a964-745d2224b197', '47e96982-5945-11f1-bf68-745d2224b197', 1, '\"{\\\"size\\\":\\\"Large\\\",\\\"temperature\\\":\\\"Iced\\\",\\\"sugar\\\":\\\"50%\\\",\\\"oat_milk\\\":true,\\\"addons\\\":{\\\"4ddc0503-5be6-11f1-8a3f-745d2224b197\\\":1}}\"', 8.50),
('311418b2-60f7-11f1-986f-745d2224b197', '3111d5e1-60f7-11f1-986f-745d2224b197', 'd1e6b530-5a84-11f1-9b9a-745d2224b197', 1, '\"{\\\"size\\\":\\\"Large\\\",\\\"temperature\\\":\\\"Iced\\\",\\\"sugar\\\":\\\"50%\\\",\\\"oat_milk\\\":true,\\\"addons\\\":{\\\"4dd4b7e5-5be6-11f1-8a3f-745d2224b197\\\":1}}\"', 8.00),
('74bac5af-60cc-11f1-89db-745d2224b197', '74b831b5-60cc-11f1-89db-745d2224b197', '47e96982-5945-11f1-bf68-745d2224b197', 1, '\"{\\\"size\\\":\\\"Small\\\",\\\"temperature\\\":\\\"Iced\\\",\\\"sugar\\\":\\\"100%\\\",\\\"oat_milk\\\":false,\\\"addons\\\":{}}\"', 6.00),
('74bb60db-60cc-11f1-89db-745d2224b197', '74b831b5-60cc-11f1-89db-745d2224b197', '47e70854-5945-11f1-bf68-745d2224b197', 1, '\"{\\\"size\\\":\\\"Small\\\",\\\"temperature\\\":\\\"Iced\\\",\\\"sugar\\\":\\\"50%\\\",\\\"oat_milk\\\":false,\\\"addons\\\":{}}\"', 5.00),
('74bbdd93-60cc-11f1-89db-745d2224b197', '74b831b5-60cc-11f1-89db-745d2224b197', 'd1f03595-5a84-11f1-9b9a-745d2224b197', 1, '\"{\\\"size\\\":\\\"Small\\\",\\\"temperature\\\":\\\"Hot\\\",\\\"sugar\\\":\\\"50%\\\",\\\"oat_milk\\\":false,\\\"addons\\\":{}}\"', 3.75),
('a4502253-60cc-11f1-89db-745d2224b197', 'a44c964c-60cc-11f1-89db-745d2224b197', 'd1e6b530-5a84-11f1-9b9a-745d2224b197', 1, '\"{\\\"size\\\":\\\"Large\\\",\\\"temperature\\\":\\\"Iced\\\",\\\"sugar\\\":\\\"50%\\\",\\\"oat_milk\\\":false,\\\"addons\\\":{}}\"', 6.75),
('e3529164-5ff2-11f1-ab0e-745d2224b197', 'e34f0c73-5ff2-11f1-ab0e-745d2224b197', '47e96982-5945-11f1-bf68-745d2224b197', 1, '\"{\\\"size\\\":\\\"Small\\\",\\\"temperature\\\":\\\"Iced\\\",\\\"sugar\\\":\\\"50%\\\",\\\"oat_milk\\\":false,\\\"addons\\\":{}}\"', 6.00);

-- --------------------------------------------------------

--
-- Table structure for table `order_tracking`
--

CREATE TABLE `order_tracking` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `order_id` char(36) NOT NULL,
  `status` varchar(50) NOT NULL,
  `note` text DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_tracking`
--

INSERT INTO `order_tracking` (`id`, `order_id`, `status`, `note`, `timestamp`) VALUES
('2aab179a-6149-11f1-a964-745d2224b197', '2aa945ee-6149-11f1-a964-745d2224b197', 'placed', 'Order placed, waiting for store confirmation', '2026-06-06 01:43:50'),
('3114d447-60f7-11f1-986f-745d2224b197', '3111d5e1-60f7-11f1-986f-745d2224b197', 'placed', 'Order placed, waiting for store confirmation', '2026-06-05 15:57:02'),
('74bdb268-60cc-11f1-89db-745d2224b197', '74b831b5-60cc-11f1-89db-745d2224b197', 'placed', 'Order placed, waiting for store confirmation', '2026-06-05 10:51:07'),
('86871ca7-60cd-11f1-89db-745d2224b197', 'a44c964c-60cc-11f1-89db-745d2224b197', 'completed', '', '2026-06-05 10:58:46'),
('a450dae9-60cc-11f1-89db-745d2224b197', 'a44c964c-60cc-11f1-89db-745d2224b197', 'placed', 'Order placed, waiting for store confirmation', '2026-06-05 10:52:27'),
('d50100f9-6149-11f1-a964-745d2224b197', '3111d5e1-60f7-11f1-986f-745d2224b197', 'preparing', 'Barista is making your drink', '2026-06-06 01:48:35'),
('e353df8e-5ff2-11f1-ab0e-745d2224b197', 'e34f0c73-5ff2-11f1-ab0e-745d2224b197', 'confirmed', 'Order received and confirmed', '2026-06-04 08:53:42'),
('fb11683b-60cc-11f1-89db-745d2224b197', '74b831b5-60cc-11f1-89db-745d2224b197', 'Confirmed', 'Ready at the counter!', '2026-06-05 10:54:52');

-- --------------------------------------------------------

--
-- Table structure for table `payment_methods`
--

CREATE TABLE `payment_methods` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `user_id` char(36) NOT NULL,
  `type` varchar(50) DEFAULT NULL,
  `provider` varchar(50) DEFAULT NULL,
  `last_four` char(4) DEFAULT NULL,
  `expiry` varchar(7) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `category_id` char(36) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `base_price` decimal(10,2) NOT NULL,
  `image_url` text DEFAULT NULL,
  `temperature_type` enum('hot','cold','both') DEFAULT 'both',
  `is_available` tinyint(1) DEFAULT 1,
  `is_featured` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `category_id`, `name`, `description`, `base_price`, `image_url`, `temperature_type`, `is_available`, `is_featured`) VALUES
('47e34e7d-5945-11f1-bf68-745d2224b197', '47e236c6-5945-11f1-bf68-745d2224b197', 'Artisan Latte', 'Rich espresso with steamed milk', 4.50, 'https://images.unsplash.com/photo-1593443320739-77f74939d0da?w=400', 'hot', 1, 0),
('47e4989d-5945-11f1-bf68-745d2224b197', '47e236c6-5945-11f1-bf68-745d2224b197', 'Flat White', 'Smooth espresso with velvety milk', 4.25, 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=400', 'hot', 1, 1),
('47e5cd86-5945-11f1-bf68-745d2224b197', '47e23932-5945-11f1-bf68-745d2224b197', 'Oat Milk Latte', 'Espresso with creamy oat milk', 5.50, 'https://images.unsplash.com/photo-1561047029-3000c68339ca?w=400', 'cold', 1, 1),
('47e70854-5945-11f1-bf68-745d2224b197', '47e23932-5945-11f1-bf68-745d2224b197', 'Cold Brew', 'Slow steeped for 12 hours', 5.00, 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400', 'cold', 1, 0),
('47e83112-5945-11f1-bf68-745d2224b197', '47e239b4-5945-11f1-bf68-745d2224b197', 'Almond Croissant', 'Twice-baked with almond cream and topped with toasted almonds.', 4.25, 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400', 'both', 1, 1),
('47e96982-5945-11f1-bf68-745d2224b197', '47e2398f-5945-11f1-bf68-745d2224b197', 'Ceremonial Matcha', 'Premium grade matcha whisked with your choice of milk.', 6.00, 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=400', 'cold', 1, 1),
('d1df78d2-5a84-11f1-9b9a-745d2224b197', '47e236c6-5945-11f1-bf68-745d2224b197', 'Cappuccino', 'Equal parts espresso, steamed milk, and thick foam.', 4.75, 'https://images.unsplash.com/photo-1534778101976-62847782c213?w=400', 'hot', 1, 0),
('d1e130ff-5a84-11f1-9b9a-745d2224b197', '47e236c6-5945-11f1-bf68-745d2224b197', 'Americano', 'Bold espresso diluted with hot water for a clean finish.', 3.50, 'https://images.unsplash.com/photo-1551030173-122aabc4489c?w=400', 'hot', 1, 0),
('d1e3e23c-5a84-11f1-9b9a-745d2224b197', '47e236c6-5945-11f1-bf68-745d2224b197', 'Honey Lavender Latte', 'Espresso with lavender syrup, honey, and oat milk.', 6.00, 'https://images.unsplash.com/photo-1496318447583-f524534e9ce1?w=400', 'hot', 1, 1),
('d1e54aa6-5a84-11f1-9b9a-745d2224b197', '47e236c6-5945-11f1-bf68-745d2224b197', 'Caramel Macchiato', 'Vanilla-flavored drink marked with espresso and caramel drizzle.', 5.50, 'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?w=400', 'hot', 1, 0),
('d1e6b530-5a84-11f1-9b9a-745d2224b197', '47e23932-5945-11f1-bf68-745d2224b197', 'Iced Caramel Macchiato', 'Layered espresso, milk, and caramel over ice.', 5.75, 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400', 'cold', 1, 1),
('d1e7fa04-5a84-11f1-9b9a-745d2224b197', '47e23932-5945-11f1-bf68-745d2224b197', 'Nitro Cold Brew', 'Cold brew infused with nitrogen for a creamy, velvety texture.', 6.50, 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400', 'cold', 1, 0),
('d1e94fbf-5a84-11f1-9b9a-745d2224b197', '47e23932-5945-11f1-bf68-745d2224b197', 'Iced Americano', 'Bold espresso shots over ice with a splash of cold water.', 4.00, 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400', 'cold', 1, 0),
('d1ea89c8-5a84-11f1-9b9a-745d2224b197', '47e2398f-5945-11f1-bf68-745d2224b197', 'Chamomile Honey Tea', 'Soothing chamomile blended with a touch of natural honey.', 4.00, 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=400', 'hot', 1, 0),
('d1ebf0fa-5a84-11f1-9b9a-745d2224b197', '47e2398f-5945-11f1-bf68-745d2224b197', 'Iced Matcha Latte', 'Ceremonial matcha shaken with milk poured over ice.', 5.50, 'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=400', 'cold', 1, 0),
('d1ed7e3e-5a84-11f1-9b9a-745d2224b197', '47e2398f-5945-11f1-bf68-745d2224b197', 'Earl Grey Latte', 'Fragrant Earl Grey tea with steamed milk and vanilla.', 4.75, 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400', 'hot', 1, 0),
('d1ef0682-5a84-11f1-9b9a-745d2224b197', '47e239b4-5945-11f1-bf68-745d2224b197', 'Butter Croissant', 'Classic flaky croissant with a golden buttery crust.', 3.50, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400', 'both', 1, 0),
('d1f03595-5a84-11f1-9b9a-745d2224b197', '47e239b4-5945-11f1-bf68-745d2224b197', 'Blueberry Muffin', 'Fluffy muffin bursting with fresh blueberries.', 3.75, 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400', 'both', 1, 1),
('d1f1801b-5a84-11f1-9b9a-745d2224b197', '47e239b4-5945-11f1-bf68-745d2224b197', 'Cinnamon Roll', 'Soft, gooey cinnamon roll drizzled with cream cheese frosting.', 4.50, 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=400', 'both', 1, 1),
('d1f2c4e1-5a84-11f1-9b9a-745d2224b197', '47e239b4-5945-11f1-bf68-745d2224b197', 'Banana Bread', 'Moist homemade banana bread with a hint of cinnamon.', 3.75, 'https://images.unsplash.com/photo-1481391319762-47dff72954d9?w=400', 'both', 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `product_options`
--

CREATE TABLE `product_options` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `product_id` char(36) NOT NULL,
  `option_type` enum('size','temperature','sugar','addon') NOT NULL,
  `label` varchar(100) NOT NULL,
  `price_modifier` decimal(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_options`
--

INSERT INTO `product_options` (`id`, `product_id`, `option_type`, `label`, `price_modifier`) VALUES
('4db720f9-5be6-11f1-8a3f-745d2224b197', '47e34e7d-5945-11f1-bf68-745d2224b197', 'addon', 'Extra Espresso Shot', 0.75),
('4dba0301-5be6-11f1-8a3f-745d2224b197', '47e34e7d-5945-11f1-bf68-745d2224b197', 'addon', 'Extra Vanilla Syrup', 0.50),
('4dbc9007-5be6-11f1-8a3f-745d2224b197', '47e4989d-5945-11f1-bf68-745d2224b197', 'addon', 'Extra Espresso Shot', 0.75),
('4dbf0380-5be6-11f1-8a3f-745d2224b197', '47e4989d-5945-11f1-bf68-745d2224b197', 'addon', 'Extra Vanilla Syrup', 0.50),
('4dc14770-5be6-11f1-8a3f-745d2224b197', 'd1df78d2-5a84-11f1-9b9a-745d2224b197', 'addon', 'Extra Espresso Shot', 0.75),
('4dc35a4a-5be6-11f1-8a3f-745d2224b197', 'd1df78d2-5a84-11f1-9b9a-745d2224b197', 'addon', 'Caramel Drizzle', 0.50),
('4dc5dff1-5be6-11f1-8a3f-745d2224b197', 'd1e3e23c-5a84-11f1-9b9a-745d2224b197', 'addon', 'Extra Honey', 0.50),
('4dc7e34d-5be6-11f1-8a3f-745d2224b197', 'd1e3e23c-5a84-11f1-9b9a-745d2224b197', 'addon', 'Extra Lavender Syrup', 0.50),
('4dca4451-5be6-11f1-8a3f-745d2224b197', '47e5cd86-5945-11f1-bf68-745d2224b197', 'addon', 'Extra Espresso Shot', 0.75),
('4dccefd1-5be6-11f1-8a3f-745d2224b197', '47e5cd86-5945-11f1-bf68-745d2224b197', 'addon', 'Caramel Drizzle', 0.50),
('4dcff2aa-5be6-11f1-8a3f-745d2224b197', '47e70854-5945-11f1-bf68-745d2224b197', 'addon', 'Sweet Cream', 0.75),
('4dd26ab7-5be6-11f1-8a3f-745d2224b197', '47e70854-5945-11f1-bf68-745d2224b197', 'addon', 'Vanilla Syrup', 0.50),
('4dd4b7e5-5be6-11f1-8a3f-745d2224b197', 'd1e6b530-5a84-11f1-9b9a-745d2224b197', 'addon', 'Extra Caramel Drizzle', 0.50),
('4dd829fe-5be6-11f1-8a3f-745d2224b197', 'd1e6b530-5a84-11f1-9b9a-745d2224b197', 'addon', 'Extra Espresso Shot', 0.75),
('4ddc0503-5be6-11f1-8a3f-745d2224b197', '47e96982-5945-11f1-bf68-745d2224b197', 'addon', 'Extra Matcha', 0.75),
('4dde7fff-5be6-11f1-8a3f-745d2224b197', '47e96982-5945-11f1-bf68-745d2224b197', 'addon', 'Honey', 0.50),
('4de1e149-5be6-11f1-8a3f-745d2224b197', '47e83112-5945-11f1-bf68-745d2224b197', 'addon', 'Extra Almond Cream', 0.50),
('4de46ba2-5be6-11f1-8a3f-745d2224b197', 'd1f1801b-5a84-11f1-9b9a-745d2224b197', 'addon', 'Extra Cream Cheese Frosting', 0.50);

-- --------------------------------------------------------

--
-- Table structure for table `promo_codes`
--

CREATE TABLE `promo_codes` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `code` varchar(50) NOT NULL,
  `discount_type` enum('percent','fixed') NOT NULL,
  `discount_value` decimal(10,2) NOT NULL,
  `max_uses` int(11) DEFAULT NULL,
  `used_count` int(11) DEFAULT 0,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promo_codes`
--

INSERT INTO `promo_codes` (`id`, `code`, `discount_type`, `discount_value`, `max_uses`, `used_count`, `expires_at`) VALUES
('deaa995e-5fee-11f1-ab0e-745d2224b197', 'BREW10', 'percent', 10.00, 100, 0, '2026-12-31 16:59:59'),
('deaaa2d0-5fee-11f1-ab0e-745d2224b197', 'SAVE5', 'fixed', 5.00, 50, 0, '2026-12-31 16:59:59'),
('deaaa431-5fee-11f1-ab0e-745d2224b197', 'WELCOME', 'percent', 15.00, 1000, 0, '2026-12-31 16:59:59');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `google_id` varchar(255) DEFAULT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `profile_photo_url` text DEFAULT NULL,
  `auth_provider` enum('google','email') DEFAULT 'email',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `google_id`, `full_name`, `email`, `password_hash`, `profile_photo_url`, `auth_provider`, `created_at`, `updated_at`) VALUES
('0ba0a0bd-5fd5-11f1-b8fe-745d2224b197', NULL, 'Budi', 'test123@gmail.com', '$2b$10$bZycpV5tBe8w.fGl6UPMieZDStkn1kYpgJJFK2oLyJf6wYDg9iyFK', NULL, 'email', '2026-06-04 05:20:05', '2026-06-04 05:20:05'),
('2fa500e7-60f5-11f1-986f-745d2224b197', '102565941662948089897', 'spoopi de nachos', 'spoopidenachos@gmail.com', NULL, 'https://lh3.googleusercontent.com/a/ACg8ocKP-LqmJjl_wOnE-mhDNZSeYaTvt0oN3JtVcYIb4PRwbiYcZg=s96-c', 'google', '2026-06-05 15:42:40', '2026-06-05 15:42:40'),
('6ced3ced-58fc-11f1-8f1d-745d2224b197', NULL, 'JOZU', 'ajwriter798@gmail.com', '$2b$10$VPE7p3BXm/a42J7g46nwyutdm9nlQH31OssEFczeO0RVS4hD1csVC', NULL, 'email', '2026-05-26 12:14:20', '2026-05-26 12:14:20'),
('ea40a5a7-5bcb-11f1-9e3e-745d2224b197', NULL, 'Jejen', 'ellyka.jeanette@gmail.com', '$2b$10$O6QuZgrYvm.kXD8OnMj7POvTimp7GItaernvm4k0URMBw5LgVDSxK', NULL, 'email', '2026-05-30 02:04:39', '2026-05-30 02:04:39');

-- --------------------------------------------------------

--
-- Table structure for table `weather_recommendations`
--

CREATE TABLE `weather_recommendations` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `weather_condition` varchar(50) NOT NULL,
  `temperature_range` varchar(50) DEFAULT NULL,
  `product_id` char(36) NOT NULL,
  `priority` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cart_id` (`cart_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_fav` (`user_id`,`product_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `address_id` (`address_id`),
  ADD KEY `promo_code_id` (`promo_code_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `order_tracking`
--
ALTER TABLE `order_tracking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `product_options`
--
ALTER TABLE `product_options`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `promo_codes`
--
ALTER TABLE `promo_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `google_id` (`google_id`);

--
-- Indexes for table `weather_recommendations`
--
ALTER TABLE `weather_recommendations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_ibfk_1` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`),
  ADD CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`promo_code_id`) REFERENCES `promo_codes` (`id`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `order_tracking`
--
ALTER TABLE `order_tracking`
  ADD CONSTRAINT `order_tracking_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD CONSTRAINT `payment_methods_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);

--
-- Constraints for table `product_options`
--
ALTER TABLE `product_options`
  ADD CONSTRAINT `product_options_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `weather_recommendations`
--
ALTER TABLE `weather_recommendations`
  ADD CONSTRAINT `weather_recommendations_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
