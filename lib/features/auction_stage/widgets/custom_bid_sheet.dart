import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../cores/constants/colors.dart';

class CustomBidSheet extends StatefulWidget {
  final double currentBid;
  final double minIncrement;
  final Future<void> Function(double amount) onPlaceBid;
  final VoidCallback onClose;

  const CustomBidSheet({
    super.key,
    required this.currentBid,
    required this.minIncrement,
    required this.onPlaceBid,
    required this.onClose,
  });

  @override
  State<CustomBidSheet> createState() => _CustomBidSheetState();
}

class _CustomBidSheetState extends State<CustomBidSheet> {
  late double _selectedAmount;
  late TextEditingController _controller;

  double get _minimumBid => widget.currentBid + widget.minIncrement;

  @override
  void initState() {
    super.initState();
    _selectedAmount = _minimumBid;
    _controller =
        TextEditingController(text: _formattedAmount(_selectedAmount));
  }

  String _formattedAmount(double value) => value.toStringAsFixed(0);

  void _setAmount(double value, {bool updateController = true}) {
    final rounded = value < _minimumBid ? _minimumBid : value;
    setState(() {
      _selectedAmount = rounded;
      if (updateController) {
        _controller.text = _formattedAmount(rounded);
        _controller.selection =
            TextSelection.collapsed(offset: _controller.text.length);
      }
    });
  }

  void _onInputChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    _setAmount(parsed, updateController: false);
  }

  void _applyQuickIncrement(double increment) {
    _setAmount(_selectedAmount + increment);
  }

  Future<void> _handlePlaceBid() async {
    final parsed = double.tryParse(_controller.text) ?? _selectedAmount;
    final target = parsed < _minimumBid ? _minimumBid : parsed;
    await widget.onPlaceBid(target);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quickOptions = [10.0, 50.0, 100.0];

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(color: Colors.black.withOpacity(0.45)),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                decoration: BoxDecoration(
                  color: colors.surfaceDark.withOpacity(0.85),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, -12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Place Manual Bid',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current Highest: \$${widget.currentBid.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.slate300,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 100,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                TextField(
                                  controller: _controller,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onChanged: _onInputChanged,
                                  onSubmitted: (_) => _handlePlaceBid(),
                                ),
                                Positioned(
                                  left: 8,
                                  child: Text(
                                    '\$',
                                    style: TextStyle(
                                      color: colors.slate400,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _MiniIconButton(
                              icon: Icons.add,
                              onPressed: () => _setAmount(
                                  _selectedAmount + widget.minIncrement),
                            ),
                            const SizedBox(height: 8),
                            _MiniIconButton(
                              icon: Icons.remove,
                              onPressed: () => _setAmount(
                                  _selectedAmount - widget.minIncrement),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: quickOptions
                          .map(
                            (value) => Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: _QuickIncrementButton(
                                  label: '+\$${value.toInt()}',
                                  onTap: () => _applyQuickIncrement(value),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _handlePlaceBid,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors.primary, colors.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withOpacity(0.5),
                              blurRadius: 22,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Place Bid',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickIncrementButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickIncrementButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: colors.slate200,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MiniIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
