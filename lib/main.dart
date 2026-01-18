import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ClockPage(),
    );
  }
}

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _formatTime(DateTime dateTime) {
    final hours = _twoDigits(dateTime.hour);
    final minutes = _twoDigits(dateTime.minute);
    final seconds = _twoDigits(dateTime.second);
    return '$hours:$minutes:$seconds';
  }

  String _formatDate(DateTime dateTime) {
    final day = _twoDigits(dateTime.day);
    final month = _twoDigits(dateTime.month);
    final year = dateTime.year;
    return '$day.$month.$year';
  }

  void _openCalculator(BuildContext context) {
    Navigator.of(context).pop(); // close drawer
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CalculatorPage()));
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _formatTime(_now);
    final dateText = _formatDate(_now);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ceas'), centerTitle: true),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: colors.primary),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Meniu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calculate),
                title: const Text('Calculator'),
                onTap: () => _openCalculator(context),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Ceas'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeText,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                dateText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double? _storedValue;
  String? _pendingOperator;
  bool _clearOnNextDigit = false;

  void _handleDigit(String digit) {
    setState(() {
      if (_clearOnNextDigit || _display == '0') {
        _display = digit;
        _clearOnNextDigit = false;
      } else {
        _display = '$_display$digit';
      }
    });
  }

  void _handleDecimal() {
    setState(() {
      if (_clearOnNextDigit) {
        _display = '0.';
        _clearOnNextDigit = false;
      } else if (!_display.contains('.')) {
        _display = '$_display.';
      }
    });
  }

  void _handleClear() {
    setState(() {
      _display = '0';
      _storedValue = null;
      _pendingOperator = null;
      _clearOnNextDigit = false;
    });
  }

  void _handleToggleSign() {
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
    });
  }

  void _handlePercent() {
    setState(() {
      final value = double.tryParse(_display) ?? 0;
      _display = _formatNumber(value / 100);
    });
  }

  void _handleOperator(String operator) {
    final currentValue = double.tryParse(_display) ?? 0;

    setState(() {
      if (_storedValue != null &&
          _pendingOperator != null &&
          !_clearOnNextDigit) {
        final result = _calculate(
          _storedValue!,
          currentValue,
          _pendingOperator!,
        );
        _display = _formatNumber(result);
        _storedValue = result;
      } else {
        _storedValue = currentValue;
      }

      _pendingOperator = operator;
      _clearOnNextDigit = true;
    });
  }

  void _handleEquals() {
    final currentValue = double.tryParse(_display) ?? 0;

    setState(() {
      if (_storedValue != null && _pendingOperator != null) {
        final result = _calculate(
          _storedValue!,
          currentValue,
          _pendingOperator!,
        );
        _display = _formatNumber(result);
        _storedValue = null;
        _pendingOperator = null;
        _clearOnNextDigit = true;
      }
    });
  }

  double _calculate(double left, double right, String operator) {
    switch (operator) {
      case '+':
        return left + right;
      case '-':
        return left - right;
      case '×':
        return left * right;
      case '÷':
        return right == 0 ? double.nan : left / right;
      default:
        return right;
    }
  }

  String _formatNumber(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';

    final asInt = value.toInt();
    if (value == asInt) return asInt.toString();

    final text = value.toStringAsFixed(6);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              label,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Calculator'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Text(
                  _display,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildButton(
                        label: 'C',
                        onPressed: _handleClear,
                        backgroundColor: colorScheme.surfaceVariant,
                        foregroundColor: colorScheme.onSurfaceVariant,
                      ),
                      _buildButton(
                        label: '±',
                        onPressed: _handleToggleSign,
                        backgroundColor: colorScheme.surfaceVariant,
                        foregroundColor: colorScheme.onSurfaceVariant,
                      ),
                      _buildButton(
                        label: '%',
                        onPressed: _handlePercent,
                        backgroundColor: colorScheme.surfaceVariant,
                        foregroundColor: colorScheme.onSurfaceVariant,
                      ),
                      _buildButton(
                        label: '÷',
                        onPressed: () => _handleOperator('÷'),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton(
                        label: '7',
                        onPressed: () => _handleDigit('7'),
                      ),
                      _buildButton(
                        label: '8',
                        onPressed: () => _handleDigit('8'),
                      ),
                      _buildButton(
                        label: '9',
                        onPressed: () => _handleDigit('9'),
                      ),
                      _buildButton(
                        label: '×',
                        onPressed: () => _handleOperator('×'),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton(
                        label: '4',
                        onPressed: () => _handleDigit('4'),
                      ),
                      _buildButton(
                        label: '5',
                        onPressed: () => _handleDigit('5'),
                      ),
                      _buildButton(
                        label: '6',
                        onPressed: () => _handleDigit('6'),
                      ),
                      _buildButton(
                        label: '-',
                        onPressed: () => _handleOperator('-'),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton(
                        label: '1',
                        onPressed: () => _handleDigit('1'),
                      ),
                      _buildButton(
                        label: '2',
                        onPressed: () => _handleDigit('2'),
                      ),
                      _buildButton(
                        label: '3',
                        onPressed: () => _handleDigit('3'),
                      ),
                      _buildButton(
                        label: '+',
                        onPressed: () => _handleOperator('+'),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton(
                        label: '0',
                        onPressed: () => _handleDigit('0'),
                        flex: 2,
                      ),
                      _buildButton(label: '.', onPressed: _handleDecimal),
                      _buildButton(
                        label: '=',
                        onPressed: _handleEquals,
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
