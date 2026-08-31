class AppConstants {
  AppConstants._();

  static const String appName = 'ExpenseTrackor';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String accountsCollection = 'accounts';
  static const String creditsCollection = 'credits';
  static const String debitsCollection = 'debits';
  static const String transfersCollection = 'transfers';

  // Account types
  static const String bank = 'Bank';
  static const String homeSafe = 'Home Safe';
  static const String pocket = 'Pocket';

  // Transaction types
  static const String creditType = 'credit';
  static const String debitType = 'debit';
  static const String transferType = 'transfer';

  // Debit categories
  static const List<String> debitCategories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Travel',
    'Shopping',
    'Bills',
    'Needs',
    'Other',
  ];

  // Credit categories
  static const List<String> creditCategories = [
    'Monthly Support',
    'Salary',
    'Income',
    'Received Money',
    'Other',
  ];
}