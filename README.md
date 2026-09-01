# 💰 ExpenseTrackor — Modern Personal Finance & Expense Manager

[![Flutter Version](https://img.shields.io/badge/Flutter-v3.27.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-v3.11.5+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Core%20%7C%20Auth%20%7C%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![State Management](https://img.shields.io/badge/State%20Management-Provider%20v6.1.5-689F38?style=for-the-badge)](https://pub.dev/packages/provider)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-4CAF50?style=for-the-badge)](https://flutter.dev/multi-platform)
[![App Version](https://img.shields.io/badge/Version-1.0.0%2B1-blueviolet?style=for-the-badge)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

---

**ExpenseTrackor** is a modern, real-time personal finance and expense tracking mobile application built with **Flutter** and **Firebase**. It empowers users to take full control of their daily finances with multi-account balance tracking, real-time income and expense categorization, seamless inter-account fund transfers, and dynamic transaction history.

---

## 📑 Table of Contents

- [✨ Key Features](#-key-features)
- [📦 Technology Stack & Versions](#-technology-stack--versions)
- [🏗️ Architecture & State Management](#️-architecture--state-management)
- [📁 Project Folder Structure](#-project-folder-structure)
- [🚀 Getting Started & Installation](#-getting-started--installation)
- [🔥 Firebase Configuration](#-firebase-configuration)
- [📱 Available Screens](#-available-screens)
- [🛠️ Utility Helpers](#️-utility-helpers)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ✨ Key Features

### 📊 1. Real-Time Dashboard & Analytics
- **Live Net Balance**: Automatically aggregated total balance across all connected accounts.
- **Credit & Debit Overview**: Instant visualization of total monthly/lifetime income vs. expenses.
- **Quick Action Bar**: Fast one-tap shortcuts to record credits, debits, transfers, or open accounts.
- **Recent Transactions Ledger**: Displays recent activities with color-coded badges and icons.

### 🏦 2. Multi-Account Management
- **Multiple Wallets / Accounts**: Support for Bank accounts, Cash / Pocket wallets, and Home Safe storage.
- **Live Account Balance Sync**: Real-time balance calculations powered by Cloud Firestore streams.
- **Dynamic Account Switcher**: Easily select source and destination accounts during transactions.

### 💸 3. Comprehensive Transaction Engine
- **Income (Credit) Tracking**: Log earnings with categories (*Salary, Monthly Support, Business Income, Received Money, Other*).
- **Expense (Debit) Tracking**: Categorize expenses (*Breakfast, Lunch, Dinner, Travel, Shopping, Bills, Needs, Other*).
- **Inter-Account Transfers**: Move funds between accounts (e.g., Bank ➡️ Pocket) with automatic balance deduction and credit.
- **Detailed Metadata**: Attach dates, categories, descriptive notes, and custom amounts.

### 🔍 4. Transaction History & Filtering
- **Multi-Filter Streams**: Filter records by transaction type (*All*, *Credit*, *Debit*, *Transfer*).
- **Formatted Currency Display**: Standardized currency formatting (`Rs. 1,000.00` / `+ Rs.` / `- Rs.`) via custom helpers.
- **Localized Date Stamps**: Human-readable date labels (*Today*, *Yesterday*, or formatted timestamps).

### 🔐 5. Secure Authentication & Profile
- **Firebase Authentication**: Robust Email & Password registration and login.
- **Password Recovery**: Integrated forgot-password reset workflow.
- **Persistent Auth State**: Smooth auth-check routing with persistent user sessions.
- **Profile Management**: Displays user details, avatar initials, and quick logout.

---

## 📦 Technology Stack & Versions

All dependencies and environment versions used in **ExpenseTrackor**:

### ⚙️ Environment & SDKs

| Component | Version Constraint | Resolved Version | Description |
| :--- | :--- | :--- | :--- |
| **App Version** | `1.0.0+1` | `1.0.0` (Build 1) | Semantic versioning |
| **Flutter SDK** | `>=3.27.0` | Latest 3.x Channel | Cross-platform framework |
| **Dart SDK** | `^3.11.5` | `>=3.11.5 <4.0.0` | Core programming language |
| **Min Android SDK** | `21` (Android 5.0 Lollipop) | 21+ | Wide device compatibility |

### 📚 Direct Dependencies

| Package | pubspec Constraint | Resolved Version | Purpose |
| :--- | :--- | :--- | :--- |
| [`provider`](https://pub.dev/packages/provider) | `^6.1.5+1` | `6.1.5+1` | Reactive state management |
| [`firebase_core`](https://pub.dev/packages/firebase_core) | `^4.14.0` | `4.14.0` | Core Firebase engine integration |
| [`firebase_auth`](https://pub.dev/packages/firebase_auth) | `^6.6.1` | `6.6.1` | User authentication & session management |
| [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) | `^6.9.0` | `6.9.0` | Cloud NoSQL database with real-time sync |
| [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) | `^1.0.8` | `1.0.9` | iOS design icon set |

### 🛠️ Dev Dependencies

| Package | pubspec Constraint | Resolved Version | Purpose |
| :--- | :--- | :--- | :--- |
| [`flutter_lints`](https://pub.dev/packages/flutter_lints) | `^6.0.0` | `6.0.0` | Dart recommended linting rules |
| [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) | `^0.14.4` | `0.14.4` | Automated app launcher icon generation |
| [`flutter_test`](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) | `sdk: flutter` | System SDK | Unit and widget test suite |

---

## 🏗️ Architecture & State Management

ExpenseTrackor is structured with a **clean, modular Service-Provider architecture** ensuring clean separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                       UI Layer (Screens)                    │
│   Dashboard | Transactions | Accounts | Forms | Profile     │
└──────────────────────────────┬──────────────────────────────┘
                               │ Watches / Listens
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    Provider State Layer                     │
│  AuthProvider | UserProvider | AccountProvider             │
│  CategoryProvider | TransactionProvider | ReportProvider    │
└──────────────────────────────┬──────────────────────────────┘
                               │ Invokes business logic
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       Service Layer                         │
│  AuthService | UserService | AccountService                │
│  TransactionService | CategoryService | ReportService       │
└──────────────────────────────┬──────────────────────────────┘
                               │ Queries / Streams
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 Cloud Firestore & Firebase Auth             │
└─────────────────────────────────────────────────────────────┘
```

### Data Models
- **`UserModel`**: Manages user ID, name, email, and created timestamp.
- **`AccountModel`**: Represents wallets/accounts (*id, title, type, balance, icon*).
- **`CreditModel`**: Income records (*id, amount, accountId, category, date, note*).
- **`DebitModel`**: Expense records (*id, amount, accountId, category, date, note*).
- **`TransferModel`**: Transfer records (*id, amount, fromAccount, toAccount, date, note*).

---

## 📁 Project Folder Structure

```text
expense_trackor/
├── android/                   # Android native platform code
├── assets/
│   └── icon/                  # Application launcher icons
├── ios/                       # iOS native platform code
├── lib/
│   ├── main.dart              # App entry point & route definitions
│   ├── models/                # Data models
│   │   ├── account_model.dart
│   │   ├── credit_model.dart
│   │   ├── debit_model.dart
│   │   ├── transfer_model.dart
│   │   └── user_model.dart
│   ├── providers/             # ChangeNotifier State Providers
│   │   ├── account_provider.dart
│   │   ├── auth_provider.dart
│   │   ├── category_provider.dart
│   │   ├── report_provider.dart
│   │   ├── transaction_provider.dart
│   │   └── user_provider.dart
│   ├── screens/               # Application UI Screens
│   │   ├── accounts_screen.dart
│   │   ├── add_account_screen.dart
│   │   ├── add_credit_screen.dart
│   │   ├── add_debit_screen.dart
│   │   ├── add_transfer_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── forgot_screen.dart
│   │   ├── login_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── signup_screen.dart
│   │   └── transactions_screen.dart
│   ├── services/              # Firebase & Firestore Service Layer
│   │   ├── account_service.dart
│   │   ├── auth_service.dart
│   │   ├── category_service.dart
│   │   ├── report_service.dart
│   │   ├── transaction_service.dart
│   │   └── user_service.dart
│   ├── utils/                 # Helpers & Application Constants
│   │   ├── app_constants.dart
│   │   ├── currency_helper.dart
│   │   └── date_helper.dart
│   └── widgets/               # Reusable UI Components
│       ├── account_card.dart
│       ├── balance_card.dart
│       ├── category_chip.dart
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── empty_state.dart
│       ├── section_header.dart
│       └── transaction_card.dart
├── pubspec.yaml               # Project dependencies & metadata
└── README.md                  # Project documentation
```

---

## 🚀 Getting Started & Installation

### Prerequisites
Make sure you have installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.27.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.11.5`)
- [Git](https://git-scm.com/)
- An IDE: [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)

### 1. Clone the Repository
```bash
git clone https://github.com/Adeel-dev540/Expense-Trackor.git
cd Expense-Trackor
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate App Icons (Optional)
```bash
flutter pub run flutter_launcher_icons
```

### 4. Run the Application
```bash
# Run on connected device or emulator
flutter run
```

---

## 🔥 Firebase Configuration

1. Create a project on the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Firebase Authentication** (Email/Password provider).
3. Enable **Cloud Firestore** and configure standard security rules.
4. Add your platform configuration:
   - **Android**: Download `google-services.json` into `android/app/`.
   - **iOS**: Download `GoogleService-Info.plist` into `ios/Runner/`.
   - Alternatively, configure via FlutterFire CLI:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```

---

## 📱 Available Screens

| Screen | Route Name | Functionality |
| :--- | :--- | :--- |
| **Auth Check** | `/` | Checks active session & routes to Login or Dashboard |
| **Login** | `/LoginScreen` | Email & password authentication |
| **Sign Up** | `/SignupScreen` | New user registration |
| **Forgot Password** | `/ForgotScreen` | Password recovery via email reset link |
| **Dashboard** | `/DashboardScreen` | Net balance, income/expense stats & quick actions |
| **Accounts** | `/AccountsScreen` | List all accounts & current balances |
| **Add Account** | `/AddAccountScreen` | Create new Bank, Pocket, or Home Safe account |
| **Transactions** | `/TransactionsScreen` | Searchable, filterable transaction history |
| **Add Credit** | `/AddCreditScreen` | Record income with category & account |
| **Add Debit** | `/AddDebitScreen` | Record expense with category & account |
| **Transfer** | `/AddTransferScreen` | Transfer money between 2 accounts |
| **Profile** | `/ProfileScreen` | User profile details, settings & sign out |

---

## 🛠️ Utility Helpers

- **`CurrencyHelper`**: Formats numbers to currency strings (`formatAmountOnly`, `format`, `formatWithoutDecimal`, `formatWithSign`).
- **`DateHelper`**: Converts timestamps and DateTime objects to friendly human formats (*"Today"*, *"Yesterday"*, *"dd MMM yyyy"*).
- **`AppConstants`**: Centralized collections, account types, and transaction category definitions.

---

## 🤝 Contributing

Contributions are always welcome!
1. Fork the Project (`https://github.com/Adeel-dev540/Expense-Trackor/fork`)
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for more information.

---

<p align="center">
  Crafted with ❤️ by <a href="https://github.com/Adeel-dev540">Adeel Dev</a> using <b>Flutter & Firebase</b>
</p>
