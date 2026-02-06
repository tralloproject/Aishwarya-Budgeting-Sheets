import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/expense_provider.dart';
import '../models/payment_method.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    for (var pm in provider.paymentMethods) {
      if (!_controllers.containsKey(pm.id)) {
        _controllers[pm.id] = TextEditingController(text: pm.initialBalance.toString());
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPaymentMethod() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'e.g. Bank Account'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newPm = PaymentMethod(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  iconCodePoint: Icons.account_balance_wallet_rounded.codePoint,
                  initialBalance: 0.0,
                );
                Provider.of<ExpenseProvider>(context, listen: false).addPaymentMethod(newPm);
                setState(() {
                  _controllers[newPm.id] = TextEditingController(text: '0.0');
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _finishSetup() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    for (var pm in provider.paymentMethods) {
      final amount = double.tryParse(_controllers[pm.id]?.text ?? '0') ?? 0.0;
      final updatedPm = PaymentMethod(
        id: pm.id,
        name: pm.name,
        iconCodePoint: pm.iconCodePoint,
        initialBalance: amount,
      );
      provider.updatePaymentMethod(updatedPm);
    }
    provider.completeSetup();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome! 🌟'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Let\'s set up your balances', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Enter the starting amount for each payment method.', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: provider.paymentMethods.length,
                itemBuilder: (context, index) {
                  final pm = provider.paymentMethods[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        Icon(IconData(pm.iconCodePoint, fontFamily: 'MaterialIcons')),
                        const SizedBox(width: 12),
                        Expanded(child: Text(pm.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _controllers[pm.id],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixText: 'HKD ',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: _addPaymentMethod,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Method'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _finishSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Start Budgeting! 🚀', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
