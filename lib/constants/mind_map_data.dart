import 'package:flutter/material.dart';

class MindMapNode {
  final String label;
  final List<MindMapNode> children;

  MindMapNode({required this.label, this.children = const []});
}

class MindMapData {
  static final Map<String, MindMapNode> unitMaps = {
    'unit_1': MindMapNode(
      label: 'Historical Background of Indian Constitution',
      children: [
        MindMapNode(
          label: '1. Introduction',
          children: [
            MindMapNode(label: 'Evolutionary Process'),
            MindMapNode(
              label: '3 Phases',
              children: [
                MindMapNode(label: 'Company Rule (1773–1858)'),
                MindMapNode(label: 'Crown Rule (1858–1947)'),
                MindMapNode(label: 'Constitution Making'),
              ],
            ),
            MindMapNode(label: 'Key Features'),
          ],
        ),
        MindMapNode(
          label: '2. East India Company Rule',
          children: [
            MindMapNode(label: 'Started as Trade (1600)'),
            MindMapNode(label: 'Battles (Plassey, Buxar)'),
            MindMapNode(label: 'Problems (Corruption, Famine)'),
            MindMapNode(label: 'British Parliamentary Intervention'),
          ],
        ),
        MindMapNode(
          label: '3. Regulating Act 1773',
          children: [
            MindMapNode(label: '1st Parliamentary Control'),
            MindMapNode(label: 'Warren Hastings (GG of Bengal)'),
            MindMapNode(label: 'Supreme Court (1774)'),
          ],
        ),
        MindMapNode(
          label: '4. Pitt’s India Act 1784',
          children: [
            MindMapNode(label: 'Dual Control (Company/Govt)'),
            MindMapNode(label: 'Board of Control'),
          ],
        ),
        MindMapNode(
          label: '5. Charter Acts',
          children: [
            MindMapNode(label: '1813: Trade Monopoly End'),
            MindMapNode(label: '1833: GG of India (Bentinck)'),
            MindMapNode(label: '1853: Separate Legislature'),
          ],
        ),
        MindMapNode(
          label: '6. Crown Rule Begins',
          children: [
            MindMapNode(label: '1858 Act: Viceroy Added'),
            MindMapNode(label: '1861 Act: Portfolio System'),
          ],
        ),
        MindMapNode(label: '7. Representation (1892 & 1909)'),
        MindMapNode(
          label: '8. 1919 Act (Dyarchy)',
          children: [
            MindMapNode(label: 'Bicameral Legislature'),
            MindMapNode(label: 'Transferred/Reserved Subjects'),
          ],
        ),
        MindMapNode(
          label: '9. 1935 Act (Federal)',
          children: [
            MindMapNode(label: '3 Lists: Union, State, Concurrent'),
            MindMapNode(label: 'Provincial Autonomy'),
          ],
        ),
        MindMapNode(label: '10. 1947 Independence Act'),
        MindMapNode(
          label: '11. Constituent Assembly',
          children: [
            MindMapNode(label: 'Formed 1946 (389 members)'),
            MindMapNode(label: 'Dr. Ambedkar (Drafting CM)'),
          ],
        ),
      ],
    ),
  };
}
