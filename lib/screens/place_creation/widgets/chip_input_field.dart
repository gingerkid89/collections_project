// lib/screens/place_creation/widgets/chip_input_field.dart

import 'package:flutter/material.dart';

class ChipInputField extends StatefulWidget {
  final List<String> chips;
  final Function(List<String>) onChipsChanged;
  final String hintText;
  final int maxChips;

  const ChipInputField({
    super.key,
    required this.chips,
    required this.onChipsChanged,
    required this.hintText,
    this.maxChips = 10,
  });

  @override
  State<ChipInputField> createState() => _ChipInputFieldState();
}

class _ChipInputFieldState extends State<ChipInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Existing chips
          if (widget.chips.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.chips.map((chip) {
                  return _buildChip(chip);
                }).toList(),
              ),
            ),
          
          // Input field
          if (widget.chips.length < widget.maxChips)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: widget.chips.isEmpty 
                          ? widget.hintText 
                          : 'Add another...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: _addChip,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _addChip(_controller.text),
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          
          // Max chips reached message
          if (widget.chips.length >= widget.maxChips)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Text(
                'Maximum ${widget.maxChips} items reached',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String chip) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
            child: Text(
              chip,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _removeChip(chip),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _addChip(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isNotEmpty && 
        !widget.chips.contains(trimmedText) &&
        widget.chips.length < widget.maxChips) {
      
      final newChips = List<String>.from(widget.chips);
      newChips.add(trimmedText);
      widget.onChipsChanged(newChips);
      
      _controller.clear();
    }
  }

  void _removeChip(String chip) {
    final newChips = List<String>.from(widget.chips);
    newChips.remove(chip);
    widget.onChipsChanged(newChips);
  }
}