import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/campaign.dart';
import 'models/contribution.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseConfigured = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize sample data for development
    await FirestoreService.initializeSampleData();
    firebaseConfigured = true;
  } catch (e) {
    print('Firebase not configured properly: $e');
    print('Running in demo mode with mock data');
  }
  
  runApp(CollegeFundApp(firebaseConfigured: firebaseConfigured));
}

class CollegeFundApp extends StatelessWidget {
  final bool firebaseConfigured;
  
  const CollegeFundApp({super.key, required this.firebaseConfigured});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Fund',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: CollegeFundPage(firebaseConfigured: firebaseConfigured),
    );
  }
}

class CollegeFundPage extends StatefulWidget {
  final bool firebaseConfigured;
  
  const CollegeFundPage({super.key, required this.firebaseConfigured});

  @override
  State<CollegeFundPage> createState() => _CollegeFundPageState();
}

class _CollegeFundPageState extends State<CollegeFundPage> {
  Campaign? campaign;
  List<Contribution> contributions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCampaignData();
  }

  Future<void> _loadCampaignData() async {
    if (widget.firebaseConfigured) {
      try {
        // Get the active campaign from Firebase
        Campaign? activeCampaign = await FirestoreService.getActiveCampaign();
        if (activeCampaign != null) {
          // Get contributions for this campaign
          List<Contribution> campaignContributions = 
              await FirestoreService.getContributionsForCampaign(activeCampaign.id);
          
          setState(() {
            campaign = activeCampaign;
            contributions = campaignContributions;
            isLoading = false;
          });

          // Set up real-time listeners
          _setupRealtimeListeners(activeCampaign.id);
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading campaign data: $e');
        _loadMockData();
      }
    } else {
      // Load mock data when Firebase is not configured
      _loadMockData();
    }
  }

  void _loadMockData() {
    // Create mock campaign data
    Campaign mockCampaign = Campaign(
      id: 'mock-campaign-id',
      title: 'College Fund for New Baby',
      description: 'Help us save for our little one\'s future education. Every contribution, big or small, makes a difference in building a bright future for our child.\n\n⚠️ Demo Mode: Firebase not configured. This is sample data.',
      goalAmount: 10000.0,
      currentAmount: 2450.0,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    // Create mock contributions
    List<Contribution> mockContributions = [
      Contribution(
        id: '1',
        campaignId: 'mock-campaign-id',
        contributorName: 'Sarah Johnson',
        amount: 500.0,
        isAnonymous: false,
        paymentMethod: PaymentMethod.stripe,
        status: ContributionStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        completedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Contribution(
        id: '2',
        campaignId: 'mock-campaign-id',
        contributorName: null,
        amount: 250.0,
        isAnonymous: true,
        paymentMethod: PaymentMethod.interac,
        status: ContributionStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        completedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Contribution(
        id: '3',
        campaignId: 'mock-campaign-id',
        contributorName: 'Mike Chen',
        amount: 750.0,
        isAnonymous: false,
        paymentMethod: PaymentMethod.stripe,
        status: ContributionStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        completedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Contribution(
        id: '4',
        campaignId: 'mock-campaign-id',
        contributorName: 'Emily Davis',
        amount: 300.0,
        isAnonymous: false,
        paymentMethod: PaymentMethod.interac,
        status: ContributionStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        completedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Contribution(
        id: '5',
        campaignId: 'mock-campaign-id',
        contributorName: null,
        amount: 400.0,
        isAnonymous: true,
        paymentMethod: PaymentMethod.stripe,
        status: ContributionStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Contribution(
        id: '6',
        campaignId: 'mock-campaign-id',
        contributorName: 'David Wilson',
        amount: 250.0,
        isAnonymous: false,
        paymentMethod: PaymentMethod.interac,
        status: ContributionStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    setState(() {
      campaign = mockCampaign;
      contributions = mockContributions;
      isLoading = false;
    });
  }

  void _setupRealtimeListeners(String campaignId) {
    // Listen to campaign changes
    FirestoreService.watchCampaign(campaignId).listen((updatedCampaign) {
      if (updatedCampaign != null && mounted) {
        setState(() {
          campaign = updatedCampaign;
        });
      }
    });

    // Listen to contributions changes
    FirestoreService.watchContributionsForCampaign(campaignId).listen((updatedContributions) {
      if (mounted) {
        setState(() {
          contributions = updatedContributions;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('College Fund'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (campaign == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('College Fund'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('No active campaign found'),
        ),
      );
    }
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
              campaign!.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Campaign Description
            Text(
              campaign!.description,
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
                          '\$${campaign!.currentAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: campaign!.currentAmount / campaign!.goalAmount,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${campaign!.progressPercentage.toStringAsFixed(1)}% of goal',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Goal: \$${campaign!.goalAmount.toStringAsFixed(2)}',
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
              'Contributors (${contributions.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Contributors List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contributions.length,
              itemBuilder: (context, index) {
                final contribution = contributions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        contribution.isAnonymous ? '?' : contribution.displayName[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(contribution.displayName),
                    trailing: Text(
                      '\$${contribution.amount.toStringAsFixed(2)}',
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
    if (campaign != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ContributionDialog(campaignId: campaign!.id);
        },
      );
    }
  }
}

class ContributionDialog extends StatefulWidget {
  final String campaignId;
  
  const ContributionDialog({super.key, required this.campaignId});

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

  Future<void> _processContribution() async {
    final amount = double.parse(_amountController.text);
    final name = _isAnonymous ? null : _nameController.text;
    
    if (widget.campaignId == 'mock-campaign-id') {
      // Demo mode - show instructions without saving to Firebase
      if (_paymentMethod == 'stripe') {
        _showPaymentInstructions(
          '🎯 Demo Mode\n\n'
          'Stripe payment integration coming soon!\n\n'
          'In a real deployment with Firebase configured, your contribution would be recorded and processed once payment is completed.'
        );
      } else {
        _showPaymentInstructions(
          '🎯 Demo Mode\n\n'
          'Please send \$${amount.toStringAsFixed(2)} via Interac e-Transfer to: collegefund@example.com\n\n'
          'In a real deployment with Firebase configured, your contribution would be recorded and added to the total once payment is received.'
        );
      }
      return;
    }

    // Real Firebase mode
    Contribution contribution = Contribution(
      id: '',
      campaignId: widget.campaignId,
      contributorName: name,
      amount: amount,
      isAnonymous: _isAnonymous,
      paymentMethod: _paymentMethod == 'stripe' ? PaymentMethod.stripe : PaymentMethod.interac,
      status: ContributionStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      String? contributionId = await FirestoreService.createContribution(contribution);
      
      if (contributionId != null) {
        if (_paymentMethod == 'stripe') {
          // TODO: Integrate with Stripe
          _showPaymentInstructions('Stripe payment integration coming soon!\n\nYour contribution has been recorded and will be processed once payment is completed.');
        } else {
          // Show Interac instructions
          _showPaymentInstructions(
            'Please send \$${amount.toStringAsFixed(2)} via Interac e-Transfer to: collegefund@example.com\n\n'
            'Your contribution has been recorded and will be added to the total once payment is received.'
          );
        }
      } else {
        _showErrorMessage('Failed to record contribution. Please try again.');
      }
    } catch (e) {
      _showErrorMessage('Error processing contribution: $e');
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

  void _showErrorMessage(String message) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
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
