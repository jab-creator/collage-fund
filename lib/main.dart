import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const CollageFundApp());
}

class CollageFundApp extends StatelessWidget {
  const CollageFundApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF003366));
    return MaterialApp(
      title: 'College Fund',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      home: const ContributionDashboard(),
    );
  }
}

class ContributionDashboard extends StatefulWidget {
  const ContributionDashboard({super.key});

  @override
  State<ContributionDashboard> createState() => _ContributionDashboardState();
}

class _ContributionDashboardState extends State<ContributionDashboard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _paymentMethod = 'stripe';
  bool _isAnonymous = false;
  bool _pledged = true;

  final List<Contribution> _contributions = [
    Contribution(
      displayName: 'Grandma & Grandpa',
      amount: 150.00,
      currency: 'CAD',
      paymentMethod: PaymentMethod.interac,
      isAnonymous: false,
      status: ContributionStatus.paid,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Contribution(
      displayName: 'Anonymous',
      amount: 50.00,
      currency: 'CAD',
      paymentMethod: PaymentMethod.stripe,
      isAnonymous: true,
      status: ContributionStatus.paid,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _totalPaid => _contributions
      .where((c) => c.status == ContributionStatus.paid)
      .fold(0, (previous, c) => previous + c.amount);

  double get _totalPledged => _contributions.fold(0, (previous, c) => previous + c.amount);

  void _addContribution() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final contribution = Contribution(
      displayName: _nameController.text.trim().isEmpty
          ? 'Anonymous'
          : _nameController.text.trim(),
      amount: amount,
      currency: 'CAD',
      paymentMethod:
          _paymentMethod == 'stripe' ? PaymentMethod.stripe : PaymentMethod.interac,
      isAnonymous: _isAnonymous,
      status: _pledged ? ContributionStatus.pledged : ContributionStatus.paid,
      createdAt: DateTime.now(),
    );

    setState(() {
      _contributions.add(contribution);
    });

    _formKey.currentState!.reset();
    _nameController.clear();
    _amountController.clear();
    setState(() {
      _paymentMethod = 'stripe';
      _isAnonymous = false;
      _pledged = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          contribution.paymentMethod == PaymentMethod.stripe
              ? 'Redirecting to Stripe checkout is required in production.'
              : 'Please follow the Interac transfer instructions to complete the pledge.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Avery College Fund'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final formWidth = isWide ? constraints.maxWidth - 420 : double.infinity;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        SizedBox(
                          width: isWide ? 360 : double.infinity,
                          child: _OverviewCard(
                            totalPaid: _totalPaid,
                            totalPledged: _totalPledged,
                            contributions: _contributions,
                          ),
                        ),
                        SizedBox(
                          width: formWidth,
                          child: _ContributionForm(
                            formKey: _formKey,
                            nameController: _nameController,
                            amountController: _amountController,
                            paymentMethod: _paymentMethod,
                            onPaymentMethodChanged: (value) {
                              setState(() => _paymentMethod = value);
                            },
                            isAnonymous: _isAnonymous,
                            onAnonymousChanged: (value) {
                              setState(() => _isAnonymous = value);
                            },
                            pledged: _pledged,
                            onPledgedChanged: (value) {
                              setState(() => _pledged = value);
                            },
                            onSubmit: _addContribution,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Recent Contributions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _ContributionList(contributions: _contributions),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.totalPaid,
    required this.totalPledged,
    required this.contributions,
  });

  final double totalPaid;
  final double totalPledged;
  final List<Contribution> contributions;

  static const _currency = 36;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Help us kickstart Baby Avery's future!",
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              "We're raising funds for Baby Avery's education. "
              "Your generosity will help cover future tuition, supplies, and opportunities.",
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _ProgressRow(
              label: 'Total Collected',
              amountLabel: '${String.fromCharCode(_currency)}${totalPaid.toStringAsFixed(2)}',
              icon: Icons.savings_outlined,
            ),
            const SizedBox(height: 16),
            _ProgressRow(
              label: 'Including Pledges',
              amountLabel: '${String.fromCharCode(_currency)}${totalPledged.toStringAsFixed(2)}',
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 24),
            Text(
              'Thank you to the ${contributions.length} supporters who have already pledged or paid!',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.amountLabel,
    required this.icon,
  });

  final String label;
  final String amountLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.bodyMedium),
            Text(
              amountLabel,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContributionForm extends StatelessWidget {
  const _ContributionForm({
    required this.formKey,
    required this.nameController,
    required this.amountController,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
    required this.isAnonymous,
    required this.onAnonymousChanged,
    required this.pledged,
    required this.onPledgedChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final String paymentMethod;
  final ValueChanged<String> onPaymentMethodChanged;
  final bool isAnonymous;
  final ValueChanged<bool> onAnonymousChanged;
  final bool pledged;
  final ValueChanged<bool> onPledgedChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Make a contribution', style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(
                'Choose the method that works best for you. Credit card payments are processed via Stripe. '
                "Alternatively, pledge an Interac e-Transfer and we'll email you the banking details.",
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  helperText: 'Leave blank to appear as Anonymous',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (CAD)',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: const [
                  DropdownMenuItem(value: 'stripe', child: Text('Pay now with Stripe')),
                  DropdownMenuItem(value: 'interac', child: Text('Pledge Interac e-Transfer')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onPaymentMethodChanged(value);
                  }
                },
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: isAnonymous,
                onChanged: (value) {
                  onAnonymousChanged(value ?? false);
                },
                title: const Text('Contribute anonymously'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: pledged,
                onChanged: (value) => onPledgedChanged(value),
                title: Text(pledged ? 'Mark as pledge' : 'Mark as paid'),
                subtitle: const Text('Toggle off if the contribution has already been paid'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.favorite),
                  label: const Text('Contribute'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContributionList extends StatelessWidget {
  const _ContributionList({required this.contributions});

  final List<Contribution> contributions;

  static const _currency = 36;

  @override
  Widget build(BuildContext context) {
    if (contributions.isEmpty) {
      return const Text('No contributions yet. Be the first to pledge!');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return DataTable(
          columns: const [
            DataColumn(label: Text('Supporter')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Method')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Date')),
          ],
          rows: contributions
              .map(
                (c) => DataRow(
                  cells: [
                    DataCell(Text(c.isAnonymous ? 'Anonymous' : c.displayName)),
                    DataCell(
                      Text(
                        '${String.fromCharCode(_currency)}${c.amount.toStringAsFixed(2)} ${c.currency}',
                      ),
                    ),
                    DataCell(Text(c.paymentMethod.label)),
                    DataCell(Text(c.status.label)),
                    DataCell(Text(_formatDate(c.createdAt))),
                  ],
                ),
              )
              .toList(),
          dataRowMinHeight: isWide ? 56 : 72,
          columnSpacing: isWide ? 24 : 12,
          headingRowColor: MaterialStateProperty.resolveWith(
            (states) => Theme.of(context).colorScheme.surfaceVariant,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

enum PaymentMethod { stripe, interac }

enum ContributionStatus { pledged, paid }

extension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.stripe:
        return 'Stripe';
      case PaymentMethod.interac:
        return 'Interac';
    }
  }
}

extension on ContributionStatus {
  String get label {
    switch (this) {
      case ContributionStatus.pledged:
        return 'Pledged';
      case ContributionStatus.paid:
        return 'Paid';
    }
  }
}

class Contribution {
  Contribution({
    required this.displayName,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.isAnonymous,
    required this.status,
    required this.createdAt,
  });

  final String displayName;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final bool isAnonymous;
  final ContributionStatus status;
  final DateTime createdAt;
}
