import 'package:flutter/material.dart';

import 'package:arrow_puzzle/ui/core/skeuo.dart';
import 'package:arrow_puzzle/ui/core/widgets/chunky_button.dart';
import 'package:arrow_puzzle/ui/core/widgets/skeuo_panel.dart';
import 'package:arrow_puzzle/ui/core/widgets/sticker_text.dart';
import 'package:arrow_puzzle/ui/features/legal/legal_content.dart';

/// Read-only page that renders a bundled [LegalDocument].
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: Skeuo.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    ChunkyButton(
                      color: Skeuo.orange,
                      radius: 18,
                      lipDepth: 5,
                      padding: const EdgeInsets.all(10),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back_rounded, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: StickerText(document.title),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: SkeuoPanel(
                    radius: 22,
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final section in document.sections) ...[
                          Text(
                            section.heading,
                            style: textTheme.titleMedium?.copyWith(
                              color: Skeuo.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            section.body,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Skeuo.inkSoft,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
