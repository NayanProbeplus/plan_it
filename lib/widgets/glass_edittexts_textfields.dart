// lib/widgets/glass_inputs.dart
import 'package:flutter/material.dart';
import 'package:planit/theme/glass.dart';
import 'dart:math' as math;

class GlassInputWrapper extends StatelessWidget {
  final Widget child;
  final bool focused;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double? height;

  const GlassInputWrapper({
    super.key,
    required this.child,
    this.focused = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    this.borderRadius,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    final double buttonHeight = (screenWidth * 0.14).clamp(56.0, 82.0);
    final double adjustedHeight =
        screenHeight < 600 ? math.max(52.0, buttonHeight * 0.9) : buttonHeight;

    return SizedBox(
      height: height ?? adjustedHeight,
      width: double.infinity,
      child: GlassContainer(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        padding: padding,
        child: Center(child: child),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              TEXT FIELD                                    */
/* -------------------------------------------------------------------------- */

class RoundedTextFieldContent extends StatefulWidget {
  final TextEditingController? controller;

  final String? initialValue;
  final String labelText;
  final Widget? prefixIcon;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;

  const RoundedTextFieldContent({
    super.key,
    this.controller,
    this.initialValue,
    required this.labelText,
    this.prefixIcon,
    this.onSaved,
    this.validator,
    this.keyboardType,
  });

  @override
  State<RoundedTextFieldContent> createState() =>
      _RoundedTextFieldContentState();
}

class _RoundedTextFieldContentState extends State<RoundedTextFieldContent> {
  final _focusNode = FocusNode();
  late final TextEditingController _internalController;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();

    _internalController =
        TextEditingController(text: widget.initialValue ?? '');

    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(covariant RoundedTextFieldContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only sync text when NOT using external controller
    if (widget.controller == null &&
        widget.initialValue != oldWidget.initialValue &&
        !_focusNode.hasFocus) {
      _internalController.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final mq = MediaQuery.of(context);
    final buttonHeight = (mq.size.width * 0.14).clamp(56.0, 82.0);
    final textSize = math.max(14.0, buttonHeight * 0.28);

    final iconColor = _focused ? cs.primary : cs.onSurface.withOpacity(0.6);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.prefixIcon != null) ...[
          IconTheme.merge(
            data: IconThemeData(color: iconColor, size: textSize),
            child: widget.prefixIcon!,
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            onSaved: widget.onSaved,
            validator: widget.validator,
            cursorColor: cs.primary,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
              fontSize: textSize,
              color: cs.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.labelText,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w700,
                fontSize: textSize * 0.95,
                color: cs.onSurface.withOpacity(0.55),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              DROPDOWN                                      */
/* -------------------------------------------------------------------------- */

class RoundedDropdownContent<T> extends StatefulWidget {
  final T value;
  final String labelText;
  final Widget? prefixIcon;
  final List<T> items;
  final ValueChanged<T?>? onChanged;

  const RoundedDropdownContent({
    super.key,
    required this.value,
    required this.labelText,
    this.prefixIcon,
    required this.items,
    this.onChanged,
  });

  @override
  State<RoundedDropdownContent<T>> createState() =>
      _RoundedDropdownContentState<T>();
}

class _RoundedDropdownContentState<T> extends State<RoundedDropdownContent<T>> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final mq = MediaQuery.of(context);
    final buttonHeight = (mq.size.width * 0.14).clamp(56.0, 82.0);
    final textSize = math.max(14.0, buttonHeight * 0.28);

    final iconColor = _open ? cs.primary : cs.onSurface.withOpacity(0.6);

    return GestureDetector(
      onTapDown: (_) => setState(() => _open = true),
      onTapUp: (_) => Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _open = false);
      }),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.prefixIcon != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: iconColor, size: textSize),
              child: widget.prefixIcon!,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: DropdownButtonFormField<T>(
              value: widget.value,
              isExpanded: true,
              icon: const SizedBox.shrink(),
              dropdownColor: cs.surface,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
                fontSize: textSize,
                color: cs.onSurface,
              ),
              items: widget.items
                  .map(
                    (i) => DropdownMenuItem<T>(
                      value: i,
                      child: Text(
                        '$i',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w600,
                          fontSize: textSize,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: widget.onChanged,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: textSize,
            color: iconColor,
          ),
        ],
      ),
    );
  }
}
