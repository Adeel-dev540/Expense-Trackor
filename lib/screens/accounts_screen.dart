
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../utils/currency_helper.dart';
import '../widgets/empty_state.dart';

class AccountsScreen extends StatefulWidget {
const AccountsScreen({super.key});

@override
State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
@override
void initState() {
super.initState();

WidgetsBinding.instance.addPostFrameCallback((_) {
context.read<AccountProvider>().startListening();
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF7F9F7),

appBar: AppBar(
backgroundColor: const Color(0xFFF7F9F7),
elevation: 0,
title: const Text(
'Accounts',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: Colors.black87,
),
),
),

body: SafeArea(
child: Padding(
padding: const EdgeInsets.all(16),
child: Consumer<AccountProvider>(
builder: (context, provider, child) {
// ----------------------------------------------------------
// Loading
// ----------------------------------------------------------

if (provider.isLoading &&
provider.accounts.isEmpty) {
return const Center(
child: CircularProgressIndicator(
color: Color(0xFF2E7D32),
),
);
}

// ----------------------------------------------------------
// Total Balance
// ----------------------------------------------------------

double totalBalance = 0;

for (final account in provider.accounts) {
final data = account.data();

final balance = data['balance'];

if (balance is num) {
totalBalance += balance.toDouble();
}
}

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ------------------------------------------------------
// Total Balance Card
// ------------------------------------------------------

Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: const Color(0xFF2E7D32),
borderRadius: BorderRadius.circular(18),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Total Balance',
style: TextStyle(
color: Colors.white70,
fontSize: 14,
),
),

const SizedBox(height: 8),

Text(
CurrencyHelper.format(totalBalance),
style: const TextStyle(
color: Colors.white,
fontSize: 28,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(
'Across ${provider.accounts.length} '
'${provider.accounts.length == 1 ? 'account' : 'accounts'}',
style: TextStyle(
color: Colors.white.withOpacity(0.75),
fontSize: 13,
),
),
],
),
),

const SizedBox(height: 24),

// ------------------------------------------------------
// My Accounts Header
// ------------------------------------------------------

Row(
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
children: [
const Text(
'My Accounts',
style: TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
),
),

TextButton.icon(
onPressed: () {
Navigator.pushNamed(
context,
'/AddAccountScreen',
);
},
icon: const Icon(Icons.add),
label: const Text('Add'),
),
],
),

const SizedBox(height: 8),

// ------------------------------------------------------
// Accounts List
// ------------------------------------------------------

Expanded(
child: provider.accounts.isEmpty
? EmptyState(
icon: Icons
    .account_balance_wallet_outlined,
title: 'No accounts yet',
message:
'Add your first account to start '
'tracking your money.',
buttonText: 'Add Account',
onPressed: () {
Navigator.pushNamed(
context,
'/AddAccountScreen',
);
},
)
    : ListView.separated(
itemCount:
provider.accounts.length,
separatorBuilder:
(context, index) {
return const SizedBox(
height: 12,
);
},
itemBuilder: (context, index) {
final account =
provider.accounts[index];

final data = account.data();

// Account name
final String name =
data['name']?.toString() ??
'Unnamed Account';

// Account type
final String accountType =
data['type']?.toString() ??
'Account';

// Account balance
final double balance =
data['balance'] is num
? (data['balance'] as num)
    .toDouble()
    : 0.0;

return Container(
padding:
const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(16),
border: Border.all(color: Colors.grey.shade200),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.04),
blurRadius: 8,
offset: const Offset(0, 3),
),
],
),
child: Row(
children: [
// Account Icon
Container(
height: 50,
width: 50,
decoration: BoxDecoration(
color: const Color(
0xFFE8F5E9,
),
borderRadius:
BorderRadius.circular(
14,
),
),
child: const Icon(
Icons
    .account_balance_wallet_outlined,
color:
Color(0xFF2E7D32),
),
),

const SizedBox(width: 14),

// Account Information
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
name,
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.bold,
color: Color(0xFF202624),
),
),

const SizedBox(
height: 5,
),

Text(
accountType,
style:
TextStyle(
fontSize: 13,
color:
Colors.grey.shade600,
),
),
],
),
),

// Balance
Text(
CurrencyHelper.format(balance),
style: const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.bold,
color:
Color(0xFF2E7D32),
),
),

const SizedBox(width: 4),

// Actions Menu
PopupMenuButton<String>(
padding: EdgeInsets.zero,
icon: Icon(
Icons.more_vert_rounded,
size: 20,
color: Colors.grey.shade600,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
onSelected: (value) {
if (value == 'edit') {
_showEditAccountDialog(context, account.id, name, balance);
} else if (value == 'delete') {
_showDeleteAccountDialog(context, account.id, name);
}
},
itemBuilder: (context) => [
const PopupMenuItem<String>(
value: 'edit',
child: Row(
children: [
Icon(Icons.edit_outlined, size: 18, color: Color(0xFF1E88E5)),
SizedBox(width: 10),
Text('Edit', style: TextStyle(fontSize: 14)),
],
),
),
const PopupMenuItem<String>(
value: 'delete',
child: Row(
children: [
Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
SizedBox(width: 10),
Text('Delete', style: TextStyle(fontSize: 14, color: Colors.red)),
],
),
),
],
),
],
),
);
},
),
),
],
);
},
),
),
),

// ------------------------------------------------------------
// Floating Action Button
// ------------------------------------------------------------

floatingActionButton: FloatingActionButton(
backgroundColor: const Color(0xFF2E7D32),
foregroundColor: Colors.white,
onPressed: () {
Navigator.pushNamed(
context,
'/AddAccountScreen',
);
},
child: const Icon(Icons.add),
),
);
}

void _showEditAccountDialog(
BuildContext context,
String accountId,
String currentName,
double currentBalance,
) {
final nameController = TextEditingController(text: currentName);
final balanceController =
TextEditingController(text: currentBalance.toStringAsFixed(2));
final formKey = GlobalKey<FormState>();

showDialog(
context: context,
builder: (ctx) => AlertDialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(18),
),
title: const Row(
children: [
Icon(Icons.edit_outlined, color: Color(0xFF2E7D32)),
SizedBox(width: 10),
Text(
'Edit Account',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
),
],
),
content: Form(
key: formKey,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextFormField(
controller: nameController,
decoration: InputDecoration(
labelText: 'Account Name',
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
),
validator: (v) {
if (v == null || v.trim().isEmpty) {
return 'Please enter account name';
}
return null;
},
),
const SizedBox(height: 14),
TextFormField(
controller: balanceController,
keyboardType:
const TextInputType.numberWithOptions(decimal: true),
decoration: InputDecoration(
labelText: 'Balance',
prefixText: 'Rs. ',
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
prefixIcon: const Icon(Icons.attach_money_rounded),
),
validator: (v) {
if (v == null || v.trim().isEmpty) {
return 'Please enter balance';
}
final numVal = double.tryParse(v);
if (numVal == null || numVal < 0) {
return 'Please enter a valid non-negative balance';
}
return null;
},
),
],
),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(ctx),
child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
),
ElevatedButton(
onPressed: () async {
if (!formKey.currentState!.validate()) return;
final newName = nameController.text.trim();
final newBal = double.parse(balanceController.text.trim());

Navigator.pop(ctx);
final provider = context.read<AccountProvider>();
final success = await provider.updateAccount(
accountId: accountId,
name: newName,
balance: newBal,
);

if (context.mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
success
? 'Account updated successfully'
: (provider.errorMessage ?? 'Failed to update account'),
),
backgroundColor:
success ? const Color(0xFF2E7D32) : Colors.red.shade800,
behavior: SnackBarBehavior.floating,
),
);
}
},
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFF2E7D32),
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
),
child: const Text('Save'),
),
],
),
);
}

void _showDeleteAccountDialog(
BuildContext context,
String accountId,
String accountName,
) {
showDialog(
context: context,
builder: (ctx) => AlertDialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(18),
),
title: const Row(
children: [
Icon(Icons.warning_amber_rounded, color: Colors.red),
SizedBox(width: 10),
Text(
'Delete Account',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
),
],
),
content: Text(
'Are you sure you want to delete "$accountName"? This action cannot be undone.',
style: const TextStyle(fontSize: 14),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(ctx),
child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
),
ElevatedButton(
onPressed: () async {
Navigator.pop(ctx);
final provider = context.read<AccountProvider>();
final success = await provider.deleteAccount(
accountId: accountId,
);

if (context.mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
success
? 'Account deleted successfully'
: (provider.errorMessage ?? 'Failed to delete account'),
),
backgroundColor:
success ? const Color(0xFF2E7D32) : Colors.red.shade800,
behavior: SnackBarBehavior.floating,
),
);
}
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red.shade700,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
),
child: const Text('Delete'),
),
],
),
);
}
}