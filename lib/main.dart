import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScotiaBank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red,
          secondary: Colors.white,
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });

    return Scaffold(
      body: Center(
        child: SizedBox.expand(
          child: Image.asset(
            'assets/splash_screen2.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  final String correctUsername = 'user';
  final String correctPassword = 'password';

  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username == correctUsername && password == correctPassword) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Account Details')),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid credentials';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? accountData;
  List<dynamic>? chequingTransactions;
  List<dynamic>? savingsTransactions;
  String? errorMessage;
  bool _showChequingTransactions = false;
  bool _showSavingsTransactions = false;

  @override
  void initState() {
    super.initState();
    fetchAccountData();
  }

  Future<void> fetchAccountData() async {
    try {
      final response = await http.get(Uri.parse('http://nawazchowdhury.com/acc.php'));

      if (response.statusCode == 200) {
        setState(() {
          accountData = json.decode(response.body);
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load account data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> fetchChequingTransactions() async {
    try {
      final response = await http.get(Uri.parse('https://nawazchowdhury.com/chq.php'));

      if (response.statusCode == 200) {
        setState(() {
          chequingTransactions = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load chequing transactions: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> fetchSavingsTransactions() async {
    try {
      final response = await http.get(Uri.parse('https://nawazchowdhury.com/sav.php'));

      if (response.statusCode == 200) {
        setState(() {
          savingsTransactions = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load savings transactions: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

  void _showWithdrawForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Withdraw'),
          content: WithdrawForm(onWithdraw: _handleWithdraw),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showTransferForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Transfer'),
          content: TransferForm(onTransfer: _handleTransfer),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _handleWithdraw(double amount) {
    // Handle withdraw logic here
    print('Withdrawn amount: \$${amount}');
  }

  void _handleTransfer(String toAccount, double amount) {
    // Handle transfer logic here
    print('Transferred \$${amount} to account: ${toAccount}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: errorMessage != null
            ? Center(
          child: Text(
            errorMessage!,
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        )
            : accountData == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        'Chequing Account',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Account Number: ${accountData!['chequing']['accountNumber']}'),
                          Text('Balance: \$${accountData!['chequing']['balance']}'),
                          Text('Currency: ${accountData!['chequing']['currency']}'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        'Savings Account',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Account Number: ${accountData!['savings']['accountNumber']}'),
                          Text('Balance: \$${accountData!['savings']['balance']}'),
                          Text('Currency: ${accountData!['savings']['currency']}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    _showChequingTransactions = true;
                    _showSavingsTransactions = false;
                    fetchChequingTransactions();
                  },
                  child: const Text(
                    'View Chequing Transactions',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(160, 50),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showSavingsTransactions = true;
                    _showChequingTransactions = false;
                    fetchSavingsTransactions();
                  },
                  child: const Text(
                    'View Savings Transactions',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(160, 50),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_showChequingTransactions && chequingTransactions != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Chequing Transactions',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: chequingTransactions!.length,
                    itemBuilder: (context, index) {
                      final transaction = chequingTransactions![index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text('${transaction['date']} - ${transaction['description']}'),
                          subtitle: Text('Amount: \$${transaction['amount']}'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            if (_showSavingsTransactions && savingsTransactions != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Savings Transactions',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: savingsTransactions!.length,
                    itemBuilder: (context, index) {
                      final transaction = savingsTransactions![index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text('${transaction['date']} - ${transaction['description']}'),
                          subtitle: Text('Amount: \$${transaction['amount']}'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _showWithdrawForm,
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(160, 50),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _showTransferForm,
                  child: const Text(
                    'Transfer',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(160, 50),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WithdrawForm extends StatefulWidget {
  final void Function(double) onWithdraw;

  const WithdrawForm({super.key, required this.onWithdraw});

  @override
  _WithdrawFormState createState() => _WithdrawFormState();
}

class _WithdrawFormState extends State<WithdrawForm> {
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            if (amount != null && amount > 0) {
              widget.onWithdraw(amount);
              Navigator.of(context).pop();
            } else {
              // Handle invalid amount input
            }
          },
          child: const Text('Withdraw'),
        ),
      ],
    );
  }
}

class TransferForm extends StatefulWidget {
  final void Function(String, double) onTransfer;

  const TransferForm({super.key, required this.onTransfer});

  @override
  _TransferFormState createState() => _TransferFormState();
}

class _TransferFormState extends State<TransferForm> {
  final _toAccountController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: _toAccountController,
          decoration: const InputDecoration(
            labelText: 'To Account',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final toAccount = _toAccountController.text;
            final amount = double.tryParse(_amountController.text);
            if (toAccount.isNotEmpty && amount != null && amount > 0) {
              widget.onTransfer(toAccount, amount);
              Navigator.of(context).pop();
            } else {
              // Handle invalid input
            }
          },
          child: const Text('Transfer'),
        ),
      ],
    );
  }
}
