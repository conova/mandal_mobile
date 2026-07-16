import 'package:flutter/material.dart';

class ThemeColorsScreen extends StatelessWidget {
  const ThemeColorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Colors')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Primary Palette', [
            _ColorBox(name: 'Primary', color: theme.primaryColor),
            _ColorBox(name: 'Primary Light', color: theme.primaryColor.withOpacity(0.12)),
          ]),
          _buildSection('Functional Colors', [
            _ColorBox(name: 'Error', color: colorScheme.error),
            _ColorBox(name: 'Success', color: const Color(0xFF4CAF50)),
            _ColorBox(name: 'Warning', color: Colors.orange),
            _ColorBox(name: 'Info', color: Colors.blue),
          ]),
          _buildSection('Neutral Colors', [
            _ColorBox(name: 'Background', color: colorScheme.surface),
            _ColorBox(name: 'Surface', color: colorScheme.surface),
            _ColorBox(name: 'Grey 100', color: Colors.grey[100]!),
            _ColorBox(name: 'Grey 300', color: Colors.grey[300]!),
            _ColorBox(name: 'Grey 500', color: Colors.grey[500]!),
            _ColorBox(name: 'Grey 800', color: Colors.grey[800]!),
          ]),
          _buildSection('Text Colors', [
            _ColorBox(name: 'Primary Text', color: Colors.black87),
            _ColorBox(name: 'Secondary Text', color: Colors.black54),
            _ColorBox(name: 'Disabled Text', color: Colors.black26),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: children,
        ),
        const Divider(height: 32),
      ],
    );
  }
}

class _ColorBox extends StatelessWidget {
  final String name;
  final Color color;

  const _ColorBox({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    // Generate hex string
    final hexString = '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';
    
    // Determine text color based on brightness
    final isDark = color.computeLuminance() < 0.5;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            hexString,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
