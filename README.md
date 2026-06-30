<p align="center">
  <img src="assets/screenshots/Banner.png" width="100%" alt="iServe-U Marketplace Banner"/>
</p>
# 🚀 iServe-U Marketplace

<p align="center">
A Flutter Marketplace & Food Delivery Application powered by Firebase
</p>

<p align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)
![Platform](https://img.shields.io/badge/Platform-Android%20|%20Web%20|%20Windows-success)
![License](https://img.shields.io/badge/License-MIT-green)

</p>

---

## 📱 Overview

**iServe-U Marketplace** is a cross-platform Flutter application that combines food ordering, marketplace shopping, restaurant management, and an admin dashboard into a single platform.

The project is designed to help restaurants, local businesses, and customers interact through one modern application.

---

## ✨ Key Features

### 👤 Customer

- 🍔 Food Ordering
- 🛒 Marketplace Shopping
- 📦 Weekly & Monthly Tiffin
- ❤️ Favorite Products
- 🔔 Notifications
- 📍 Delivery Address
- 🛍 Cart Management
- 💳 Online Payment Ready

---

### 🏪 Restaurant

- Restaurant Dashboard
- Product Upload
- Menu Management
- Order Management
- Sales Report
- Restaurant Profile

---

### 👨‍💼 Admin

- Restaurant Approval
- User Management
- Order Monitoring
- Sales Reports
- Notification Management

---

## 🛠 Tech Stack

| Technology | Description |
|------------|-------------|
| Flutter | Cross Platform Framework |
| Dart | Programming Language |
| Firebase Authentication | Login System |
| Cloud Firestore | Database |
| Firebase Storage | Image Storage |
| Firebase Cloud Messaging | Notifications |
| Provider | State Management |

# 📱 Application Screenshots

## 🔐 Authentication

| Login Screen | Location Selection |
|--------------|--------------------|
| ![](assets/screenshots/login_page.png) | ![](assets/screenshots/location_page.png) |

---

## 🏠 Customer Application

| Home | Food |
|------|------|
| ![](assets/screenshots/home_page.png) | ![](assets/screenshots/food_page.png) |

| Home (Alternative View) | Cart |
|-------------------------|------|
| ![](assets/screenshots/home_page2.png) | ![](assets/screenshots/cart_page.png) |

---

## 🛍 Marketplace & Orders

| Orders | Notifications |
|--------|---------------|
| ![](assets/screenshots/order_page.png) | ![](assets/screenshots/notification_page.png) |

---

## 🍽 Restaurant Dashboard

| Dashboard | Add Product |
|-----------|-------------|
| ![](assets/screenshots/restaurant_dashboard_page.png) | ![](assets/screenshots/add_product_page.png) |

---

## 👨‍💼 Admin Dashboard

| Sales Report | Order Assignment |
|-------------|------------------|
| ![](assets/screenshots/admin_sales_report.png) | ![](assets/screenshots/order_assigning_page.png) |

# 🏗️ System Modules

```text
iServe-U Platform
│
├── 🔐 Authentication
├── 🛒 Marketplace
├── 🍔 Food Ordering
├── 📦 Weekly & Monthly Tiffin
├── 🍽 Restaurant Dashboard
├── 🤝 Partner Module
├── 👨‍💼 Admin Dashboard
├── 🔔 Notifications
├── 📢 Advertisement System
├── 👤 Customer Profile
├── 🛠 Support Center
└── 📊 Analytics
```


## 📂 Architecture Overview

The application follows a modular architecture to keep features organized and maintainable.

# 📂 Project Structure

```text
lib/
├── core/
├── data/
├── features/
├── players/
├── screens/
├── shared_widgets/
├── firebase_options.dart
└── main.dart
```

### Core
Contains reusable utilities, services, widgets, caching, and helper classes used throughout the application.

### Data
Responsible for Firebase services, analytics, advertisements, and storage operations.

### Features
Business logic grouped by domain:

- 🍔 Food Ordering
- 🔔 Notifications
- 🤝 Partner Management
- 👤 Profile
- 🍽 Restaurant Management
- 🛠 Support System

### Players
Platform-specific media handling for Android and Web.

### Screens
UI screens for Admin, Authentication, Food, Marketplace, Home, and Profile.

### Shared Widgets
Reusable widgets used across multiple modules.

# 🚀 Installation

Clone the repository

```bash
git clone https://github.com/gsoftranchi-ship-it/iserve-u-marketplace.git
```

Go to the project

```bash
cd iserve-u-marketplace
```

Install packages

```bash
flutter pub get
```

Run the application

```bash
flutter run
```
# 🚀 Future Roadmap

- Live Order Tracking
- Customer Ratings & Reviews
- Coupon & Discount Engine
- Wallet Integration
- Loyalty Rewards
- Multi-language Support
- AI Product Recommendations

- # 👨‍💻 Developer

**Kumar Gaurav**

Flutter Developer | Firebase | AI Data Annotation

📧 Email: gsoftranchi@gmail.com

🔗 LinkedIn

https://www.linkedin.com/in/kumar-gaurav-b12749389/

# ⭐ Support

If you found this project helpful, please consider giving it a ⭐ on GitHub.

Your support motivates further development.

---
