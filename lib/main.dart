import 'package:flutter/material.dart';

void main() {
  runApp(const CollegeFundApp());
}

class CollegeFundApp extends StatelessWidget {
  const CollegeFundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Fund',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CollegeFundPage(),
    );
  }
}

class CollegeFundPage extends StatefulWidget {
  const CollegeFundPage({super.key});

  @override
  State<CollegeFundPage> createState() => _CollegeFundPageState();
}

class _CollegeFundPageState extends State<CollegeFundPage> {
  // Sample data - will be replaced with Firebase data later
  final String campaignTitle = "College Fund for New Baby";
  final String campaignDescription = 
      "Help us save for our new baby's college education! Every contribution, big or small, makes a difference in securing their future.";
  double totalRaised = 2450.00;
  final double goalAmount = 10000.00;
  
  final List<Contributor> contributors = [
    Contributor(name: "John & Sarah", amount: 500.00, isAnonymous: false),
    Contributor(name: "Anonymous", amount: 250.00, isAnonymous: true),
    Contributor(name: "Grandma Rose", amount: 1000.00, isAnonymous: false),
    Contributor(name: "Anonymous", amount: 100.00, isAnonymous: true),
    Contributor(name: "Uncle Mike", amount: 300.00, isAnonymous: false),
    Contributor(name: "Anonymous", amount: 300.00, isAnonymous: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('College Fund'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Title
            Text(
              campaignTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Campaign Description
            Text(
              campaignDescription,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            // Progress Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Raised',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '\$${totalRaised.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: totalRaised / goalAmount,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(totalRaised / goalAmount * 100).toStringAsFixed(1)}% of goal',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Goal: \$${goalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Contributors Section
            Text(
              'Contributors (${contributors.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Contributors List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contributors.length,
              itemBuilder: (context, index) {
                final contributor = contributors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        contributor.isAnonymous ? '?' : contributor.name[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(contributor.name),
                    trailing: Text(
                      '\$${contributor.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Contribute Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showContributionDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Contribute Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContributionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ContributionDialog();
      },
    );
  }
}

class Contributor {
  final String name;
  final double amount;
  final bool isAnonymous;

  Contributor({
    required this.name,
    required this.amount,
    required this.isAnonymous,
  });
}

class ContributionDialog extends StatefulWidget {
  const ContributionDialog({super.key});

  @override
  State<ContributionDialog> createState() => _ContributionDialogState();
}

class _ContributionDialogState extends State<ContributionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _paymentMethod = 'stripe';
  bool _isAnonymous = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Make a Contribution'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (!_isAnonymous && (value == null || value.isEmpty)) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (\$)',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Contribute anonymously'),
              value: _isAnonymous,
              onChanged: (value) {
                setState(() {
                  _isAnonymous = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment Method:'),
                RadioListTile<String>(
                  title: const Text('Pay with Card (Stripe)'),
                  value: 'stripe',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Interac Transfer'),
                  value: 'interac',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _processContribution();
            }
          },
          child: Text(_paymentMethod == 'stripe' ? 'Pay Now' : 'Pledge Amount'),
        ),
      ],
    );
  }

  void _processContribution() {
    final amount = double.parse(_amountController.text);
    final name = _isAnonymous ? 'Anonymous' : _nameController.text;
    
    if (_paymentMethod == 'stripe') {
      // TODO: Integrate with Stripe
      _showPaymentInstructions('Stripe payment integration coming soon!');
    } else {
      // Show Interac instructions
      _showPaymentInstructions(
        'Please send \$${amount.toStringAsFixed(2)} via Interac e-Transfer to: collegefund@example.com\n\n'
        'Your contribution will be added to the total once payment is received.'
      );
    }
  }

  void _showPaymentInstructions(String message) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Instructions'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
