import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';

/// Гэрээний загвар — assets/data/contracts.json-оос уншина
class ContractDoc {
  final String id;
  final String title;
  final String intro;
  final List<ContractSection> sections;

  const ContractDoc({
    required this.id,
    required this.title,
    required this.intro,
    required this.sections,
  });

  factory ContractDoc.fromJson(Map<String, dynamic> json) => ContractDoc(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        intro: json['intro']?.toString() ?? '',
        sections: (json['sections'] as List? ?? const [])
            .whereType<Map>()
            .map((s) => ContractSection(
                  title: s['title']?.toString() ?? '',
                  content: s['content']?.toString() ?? '',
                ))
            .toList(),
      );
}

class ContractSection {
  final String title;
  final String content;
  const ContractSection({required this.title, required this.content});
}

/// Гэрээнүүд — profile > Гэрээ цэснээс нээгдэх жагсаалт
class ContractsScreen extends StatefulWidget {
  const ContractsScreen({super.key});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  List<ContractDoc> _contracts = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/data/contracts.json');
      final body = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _contracts = (body['contracts'] as List? ?? const [])
            .whereType<Map>()
            .map((c) => ContractDoc.fromJson(Map<String, dynamic>.from(c)))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircleBackButton(),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Гэрээнүүд',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _contracts.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: extendedColors.neutral500),
                  itemBuilder: (context, i) {
                    final contract = _contracts[i];
                    return _ChevronRow(
                      title: contract.title,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ContractDetailScreen(contract: contract),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Нэг гэрээний дэлгэрэнгүй — оршил + бүлгүүдийн жагсаалт
class ContractDetailScreen extends StatelessWidget {
  final ContractDoc contract;

  const ContractDetailScreen({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CircleBackButton(),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  contract.title,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
              ),
              if (contract.intro.isNotEmpty) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    contract.intro,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral200,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              for (var i = 0; i < contract.sections.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: extendedColors.neutral500),
                _ChevronRow(
                  title: '${i + 1}. ${contract.sections[i].title}',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContractSectionScreen(
                        number: i + 1,
                        section: contract.sections[i],
                      ),
                    ),
                  ),
                ),
              ],
              Divider(height: 1, color: extendedColors.neutral500),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Гэрээний нэг бүлгийн агуулга
class ContractSectionScreen extends StatelessWidget {
  final int number;
  final ContractSection section;

  const ContractSectionScreen({
    super.key,
    required this.number,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CircleBackButton(),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$number. ${section.title}',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  section.content.isNotEmpty ? section.content : '—',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: extendedColors.neutral200,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChevronRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ChevronRow({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: extendedColors.neutral300,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
