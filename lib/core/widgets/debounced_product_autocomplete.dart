import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/formatters.dart';
import '../utils/unit_price_resolver.dart';

/// حقل إكمال تلقائي للمنتجات مع debounce 300ms.
class DebouncedProductAutocomplete extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function(String query) onSearch;
  final void Function(Map<String, dynamic> product) onSelected;
  final String hintText;
  final bool isLoading;

  const DebouncedProductAutocomplete({
    super.key,
    required this.onSearch,
    required this.onSelected,
    this.hintText = 'ابحث عن منتج...',
    this.isLoading = false,
  });

  @override
  State<DebouncedProductAutocomplete> createState() =>
      _DebouncedProductAutocompleteState();
}

class _DebouncedProductAutocompleteState
    extends State<DebouncedProductAutocomplete> {
  final _focusNode = FocusNode();
  final _textController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _options = const [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final q = value.trim();
      if (q.isEmpty) {
        if (mounted) setState(() => _options = const []);
        return;
      }
      setState(() => _searching = true);
      try {
        final results = await widget.onSearch(q);
        if (mounted) {
          setState(() {
            _options = results;
            _searching = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  String _label(Map<String, dynamic> item) {
    final name = (item['productName'] ?? item['name'] ?? '').toString();
    final code = (item['productCode'] ?? item['code'] ?? '').toString();
    final price = resolveUnitPrice(item);
    final stock = item['quantity'] ?? item['mainWarehouseStock'] ?? item['stockQuantity'] ?? 0;
    final stockStr = stock is num ? stock.toInt().toString() : stock.toString();
    if (code.isNotEmpty) {
      return '$name ($code) — ${Formatters.currency(price)} · مخزون: $stockStr';
    }
    return '$name — ${Formatters.currency(price)} · مخزون: $stockStr';
  }

  @override
  Widget build(BuildContext context) {
    final loading = widget.isLoading || _searching;

    return RawAutocomplete<Map<String, dynamic>>(
      textEditingController: _textController,
      focusNode: _focusNode,
      optionsBuilder: (TextEditingValue value) {
        if (value.text.trim().isEmpty) return const Iterable.empty();
        return _options;
      },
      displayStringForOption: (item) =>
          (item['productName'] ?? item['name'] ?? '').toString(),
      onSelected: (item) {
        widget.onSelected(item);
        _textController.clear();
        _focusNode.unfocus();
        setState(() => _options = const []);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: _onTextChanged,
          onSubmitted: (_) => onFieldSubmitted(),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.cairo(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (_textController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _textController.clear();
                          setState(() => _options = const []);
                        },
                      )
                    : null),
            filled: true,
            fillColor: Theme.of(context).cardTheme.color,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        if (options.isEmpty) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 500),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      _label(item),
                      style: GoogleFonts.cairo(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onSelected(item),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
