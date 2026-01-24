import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_button.dart';

class RegisterBankSelectionScreen extends StatefulWidget {
  const RegisterBankSelectionScreen({super.key});

  @override
  State<RegisterBankSelectionScreen> createState() => _RegisterBankSelectionScreenState();
}

class _RegisterBankSelectionScreenState extends State<RegisterBankSelectionScreen> {
  String? _selectedBank;

  final List<Map<String, dynamic>> _banks = [
    {
      'name': 'Хаан банк',
      'icon': '🏦',
      'color': const Color(0xFF2D5F3E),
    },
    {
      'name': 'Худалдаа хөгжлийн банк',
      'icon': '🏦',
      'color': const Color(0xFF1E5FA8),
    },
    {
      'name': 'M bank',
      'icon': '🏦',
      'color': const Color(0xFF00BFA5),
    },
    {
      'name': 'Хас банк',
      'icon': '🏦',
      'color': const Color(0xFFFF6B35),
    },
    {
      'name': 'Төрийн банк',
      'icon': '🏦',
      'color': const Color(0xFF1B4B7F),
    },
  ];

  void _handleContinue() {
    if (_selectedBank == null) return;
    // Navigate to success screen
    Navigator.pushNamed(context, '/register_success');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                '4/5',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            l10n.selectYourBank,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '₮5,000',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _banks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final bank = _banks[index];
                final isSelected = _selectedBank == bank['name'];
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedBank = bank['name'];
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1E8675) : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: bank['color'],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              bank['icon'],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            bank['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: CustomButton(
              label: l10n.selectBankToContinue,
              onPressed: _selectedBank != null ? _handleContinue : null,
              variant: CustomButtonVariant.primary,
            ),
          ),
        ],
      ),
    );
  }
}
