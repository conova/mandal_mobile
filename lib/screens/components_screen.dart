import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/asset_card.dart';
import '../widgets/finance_chart.dart';

class ComponentsScreen extends StatefulWidget {
  const ComponentsScreen({super.key});

  @override
  State<ComponentsScreen> createState() => _ComponentsScreenState();
}

class _ComponentsScreenState extends State<ComponentsScreen> {
  String? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Components'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Buttons'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
               CustomButton(label: 'Primary', onPressed: (){}),
               CustomButton(label: 'Secondary', variant: CustomButtonVariant.secondary, onPressed: (){}),
               CustomButton(label: 'Tertiary', variant: CustomButtonVariant.tertiary, onPressed: (){}),
               CustomButton(label: 'Text Button', variant: CustomButtonVariant.text, onPressed: (){}),
            ],
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Input States'),
          const CustomInput(
            label: 'Default',
            hint: 'Placeholder',
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: 'Typing / Active',
            controller: TextEditingController(text: 'Typing'),
          ),
          const SizedBox(height: 16),
          const CustomInput(
            label: 'Error state',
            hint: 'Placeholder',
            errorText: 'Here is a text what is wrong',
          ),
          const SizedBox(height: 16),
          const CustomInput(
            label: 'Password',
            hint: 'Enter your password',
            isPassword: true,
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Dropdowns'),
          CustomDropdown<String>(
            label: 'Default Dropdown',
            items: const [
              DropdownMenuItem(value: 'Item 1', child: Text('Item 1')),
              DropdownMenuItem(value: 'Item 2', child: Text('Item 2')),
            ],
            onChanged: (val) {},
          ),
          const SizedBox(height: 16),
          CustomDropdown<String>(
            label: 'Choosen Item',
            value: _selectedItem ?? 'Item',
            items: const [
              DropdownMenuItem(value: 'Item', child: Text('Item')),
              DropdownMenuItem(value: 'Item 2', child: Text('Item 2')),
            ],
            onChanged: (val) {
              setState(() {
                _selectedItem = val;
              });
            },
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Asset Cards'),
          const AssetCard(icon: Icons.currency_ruble, title: 'Tugrug', subtitle: 'Account', amount: '1,280,000₮'),
          const AssetCard(icon: Icons.attach_money, title: 'Dollar', subtitle: 'Account', amount: '100\$', isDark: true),

          const SizedBox(height: 24),
          _buildSectionTitle('Finance Chart'),
          const FinanceChart(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
