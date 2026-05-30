# 💰 Expense Management

A modern iOS expense tracking application built with **Swift**, **UIKit**, and **Core Data** that helps users manage expenses, monitor spending habits, and visualize financial insights through interactive reports.

---

## 📱 Overview

Expense Management is a native iOS application designed to simplify personal finance tracking. The app allows users to record expenses, organize them into categories, track monthly spending, and gain insights through visual reports.

The project follows the **VIPER Architecture** to ensure maintainability, scalability, and separation of concerns.

---

## ✨ Features

### Dashboard
- View monthly financial summary
- Track:
  - Total Income
  - Total Expenses
  - Savings
- Display recent expenses
- Quick access to all expenses
- Automatic sample data generation for first-time users

### Expense Management
- Add new expenses
- Edit existing expenses
- Delete expenses
- Categorize expenses
- Add notes to transactions
- Select payment methods
- Filter expenses by category

### Reports & Analytics
- Monthly expense breakdown
- Interactive category-based charts
- Spending distribution visualization
- Month-to-month navigation
- Spending comparison with previous months

### Settings
- Manage categories
- Configure application preferences
- Reset application data

---

## 🏗️ Architecture

This project follows the **VIPER Architecture Pattern**.

```text
View
 ↓
Presenter
 ↓
Interactor
 ↓
Entity (Core Data Models)

Router handles navigation
```

Benefits:

- Separation of concerns
- Testability
- Scalable module structure
- Easier maintenance

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|----------|
| Swift | Application Development |
| UIKit | User Interface |
| Core Data | Local Persistence |
| VIPER | Application Architecture |
| Auto Layout | Responsive UI |
| SFSymbols | Icons |

---

## 📂 Project Structure

```text
ExpenseManagement
│
├── App
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── CoreDataStack.swift
│
├── CoreData
│   └── CoreDataHelpers.swift
│
├── Modules
│   ├── Dashboard
│   ├── Expense
│   ├── Reports
│   ├── Settings
│   └── MainTabBarController.swift
│
├── Util
│   ├── ArcChartView.swift
│   ├── UIColor+Extensions.swift
│   ├── UITextField+Extensions.swift
│   └── Utilities
│
├── Assets.xcassets
│
└── ExpenseManagement.xcdatamodeld
```

---

## 🗄️ Data Model

### User
Stores user information and income details.

```text
User
├── id
├── name
├── email
├── income
└── expenses
```

### Expense

```text
Expense
├── id
├── amount
├── date
├── note
├── paymentMethod
├── category
├── createdAt
└── updatedAt
```

### Category

```text
Category
├── id
├── name
├── colorHex
└── iconName
```

### Budget

```text
Budget
├── id
├── amount
├── month
└── category
```

---

## 📊 Reporting Features

The Reports module provides:

- Monthly expense summaries
- Category-wise spending distribution
- Percentage contribution of each category
- Previous month comparison
- Visual chart representation using custom `ArcChartView`

---


## 👨‍💻 Author

**Afsal Baaqir A**

GitHub: https://github.com/AfsalBaaqirA

---

⭐ If you found this project useful, please consider giving it a star.
