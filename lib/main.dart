import 'package:expense_trackor/providers/account_provider.dart';
import 'package:expense_trackor/providers/auth_provider.dart';
import 'package:expense_trackor/providers/category_provider.dart';
import 'package:expense_trackor/providers/report_provider.dart';
import 'package:expense_trackor/providers/transaction_provider.dart';
import 'package:expense_trackor/providers/user_provider.dart';

import 'package:expense_trackor/screens/accounts_screen.dart';
import 'package:expense_trackor/screens/add_account_screen.dart';
import 'package:expense_trackor/screens/add_credit_screen.dart';
import 'package:expense_trackor/screens/add_debit_screen.dart';
import 'package:expense_trackor/screens/add_transfer_screen.dart';
import 'package:expense_trackor/screens/forgot_screen.dart';
import 'package:expense_trackor/screens/dashboard_screen.dart';
import 'package:expense_trackor/screens/login_screen.dart';
import 'package:expense_trackor/screens/profile_screen.dart';
import 'package:expense_trackor/screens/signup_screen.dart';
import 'package:expense_trackor/screens/transactions_screen.dart';
import 'package:expense_trackor/testing.dart';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AccountProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => TransactionProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ReportProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Firebase decides where the user should go.
      home: const AuthCheck(),

      routes: {
        '/DashboardScreen': (context) => const DashboardScreen(),
        '/AccountsScreen': (context) => const AccountsScreen(),
        '/TransactionsScreen': (context) => const TransactionsScreen(),
        '/ProfileScreen': (context) => const ProfileScreen(),

        '/AddAccountScreen': (context) => AddAccountScreen(),
        '/AddCreditScreen': (context) => AddCreditScreen(),
        '/AddDebitScreen': (context) => AddDebitScreen(),
        '/AddTransferScreen': (context) => AddTransferScreen(),

        '/LoginScreen': (context) => LoginScreen(),
        '/SignupScreen': (context) => SignupScreen(),
        '/ForgotScreen': (context) => ForgotScreen(),

        '/DateHelperDemoScreen': (context) => DateHelperDemoScreen(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // Firebase is checking the login state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is already logged in
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // User is not logged in
        return LoginScreen();
      },
    );
  }
}