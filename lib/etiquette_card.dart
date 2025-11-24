import 'package:flutter/material.dart';

import 'country_guide.dart';
import 'flag_badge.dart';

class EtiquetteCard extends StatefulWidget {
  const EtiquetteCard({required this.country, super.key});

  final CountryGuide country;

  @override
  State<EtiquetteCard> createState() => _EtiquetteCardState();
}

class _EtiquetteCardState extends State<EtiquetteCard> {
  TipCategory _selected = TipCategory.etiquette;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final country = widget.country;

    final tips = _selected == TipCategory.etiquette
        ? country.etiquetteTips
        : country.travelTips;

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        leading: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 52, maxWidth: 60),
          child: Center(
            child: FlagBadge(
              fallbackColor: country.accent,
              assetPath: country.flagAsset,
            ),
          ),
        ),
        title: Text(
          country.name,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          _selected == TipCategory.etiquette
              ? 'Travel etiquette essentials'
              : 'On-the-go travel tips',
          style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
        children: [
          const SizedBox(height: 6),
          _DescriptionTile(text: country.description),
          const SizedBox(height: 12),
          ToggleButtons(
            borderRadius: BorderRadius.circular(12),
            selectedColor: Colors.white,
            fillColor: country.accent,
            color: Colors.black87,
            constraints: const BoxConstraints(minWidth: 120, minHeight: 42),
            isSelected: [
              _selected == TipCategory.etiquette,
              _selected == TipCategory.travel,
            ],
            onPressed: (index) {
              setState(() {
                _selected =
                    index == 0 ? TipCategory.etiquette : TipCategory.travel;
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('Etiquette'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('Travel Tips'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tips
                .map(
                  (tip) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.fiber_manual_record,
                            size: 10, color: country.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.black87,
                                  height: 1.35,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DescriptionTile extends StatelessWidget {
  const _DescriptionTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              height: 1.35,
            ),
      ),
    );
  }
}

enum TipCategory { etiquette, travel }
