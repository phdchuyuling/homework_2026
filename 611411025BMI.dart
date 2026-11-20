import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const BmiApp());

// =====================================================
// 資料模型與計算
// =====================================================

enum Gender { male, female }

class BmiRecord {
  BmiRecord({
    required this.time,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
  });

  final DateTime time;
  final double height; // cm
  final double weight; // kg
  final int age;
  final Gender gender;

  double get bmi => calcBmi(height, weight);
}

class BmiCategory {
  const BmiCategory(this.name, this.min, this.max, this.color, this.tip);

  final String name;
  final double min;
  final double max;
  final Color color;
  final String tip;
}

// 台灣衛福部國健署成人體位分類
const List<BmiCategory> kCategories = [
  BmiCategory('體重過輕', 0, 18.5, Colors.blue,
      '建議均衡攝取蛋白質與熱量，搭配適度肌力訓練，慢慢增加健康體重。'),
  BmiCategory('健康體位', 18.5, 24, Colors.green,
      '很棒！請維持均衡飲食與規律運動，每週至少 150 分鐘中等強度活動。'),
  BmiCategory('過重', 24, 27, Colors.orange,
      '建議減少含糖飲料與油炸食物，每天多走路或騎車 30 分鐘。'),
  BmiCategory('輕度肥胖', 27, 30, Colors.deepOrange,
      '建議調整飲食份量並增加運動量，必要時可以諮詢營養師。'),
  BmiCategory('中度肥胖', 30, 35, Colors.red,
      '建議諮詢醫師或營養師，擬定個人化的體重管理計畫。'),
  BmiCategory('重度肥胖', 35, 999, Colors.purple,
      '請盡快諮詢醫師，評估相關健康風險與適合的處理方式。'),
];

const List<(String, double)> kActivities = [
  ('久坐（幾乎不運動）', 1.2),
  ('輕度（每週運動 1–3 天）', 1.375),
  ('中度（每週運動 3–5 天）', 1.55),
  ('高度（每週運動 6–7 天）', 1.725),
  ('非常高（體力勞動／運動員）', 1.9),
];

double calcBmi(double heightCm, double weightKg) {
  final m = heightCm / 100;
  return weightKg / (m * m);
}

BmiCategory categoryOf(double bmi) =>
    kCategories.firstWhere((c) => bmi < c.max, orElse: () => kCategories.last);

String two(int n) => n.toString().padLeft(2, '0');

String fmtTime(DateTime t) =>
    '${t.year}/${two(t.month)}/${two(t.day)} ${two(t.hour)}:${two(t.minute)}';

String fmtNum(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toString();

List<BmiRecord> demoRecords() {
  final now = DateTime.now();
  const weights = [71.0, 70.2, 69.5, 69.8, 68.4, 67.6, 66.9, 66.0];
  return [
    for (var i = 0; i < weights.length; i++)
      BmiRecord(
        time: now.subtract(Duration(days: (weights.length - 1 - i) * 7)),
        height: 170,
        weight: weights[i],
        age: 21,
        gender: Gender.female,
      ),
  ];
}

// =====================================================
// App 主體
// =====================================================

class BmiApp extends StatefulWidget {
  const BmiApp({super.key});

  @override
  State<BmiApp> createState() => _BmiAppState();
}

class _BmiAppState extends State<BmiApp> {
  bool _dark = false;
  final List<BmiRecord> _history = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI 健康管理',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: HomeShell(
        dark: _dark,
        history: _history,
        onToggleTheme: () => setState(() => _dark = !_dark),
        onAdd: (r) => setState(() => _history.add(r)),
        onRemove: (r) => setState(() => _history.remove(r)),
        onClear: () => setState(() => _history.clear()),
        onLoadDemo: () => setState(() {
          _history
            ..clear()
            ..addAll(demoRecords());
        }),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.dark,
    required this.history,
    required this.onToggleTheme,
    required this.onAdd,
    required this.onRemove,
    required this.onClear,
    required this.onLoadDemo,
  });

  final bool dark;
  final List<BmiRecord> history;
  final VoidCallback onToggleTheme;
  final ValueChanged<BmiRecord> onAdd;
  final ValueChanged<BmiRecord> onRemove;
  final VoidCallback onClear;
  final VoidCallback onLoadDemo;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  static const _titles = ['BMI 健康計算', '歷史紀錄', '健康知識'];

  void _save(BmiRecord r) {
    widget.onAdd(r);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
              '已儲存：BMI ${r.bmi.toStringAsFixed(1)}（${categoryOf(r.bmi).name}）'),
          action: SnackBarAction(
            label: '查看',
            onPressed: () => setState(() => _tab = 1),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab]),
        actions: [
          IconButton(
            tooltip: widget.dark ? '切換淺色模式' : '切換深色模式',
            icon: Icon(widget.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          CalculatorPage(onSave: _save),
          HistoryPage(
            history: widget.history,
            onRemove: widget.onRemove,
            onClear: widget.onClear,
            onLoadDemo: widget.onLoadDemo,
          ),
          const InfoPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: '計算',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: widget.history.isNotEmpty,
              label: Text('${widget.history.length}'),
              child: const Icon(Icons.history),
            ),
            label: '紀錄',
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '知識',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// 計算頁
// =====================================================

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key, required this.onSave});

  final ValueChanged<BmiRecord> onSave;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  Gender _gender = Gender.female;
  double _height = 165;
  double _weight = 55;
  int _age = 20;
  int _activity = 1;
  final _waist = TextEditingController();

  @override
  void dispose() {
    _waist.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _gender = Gender.female;
      _height = 165;
      _weight = 55;
      _age = 20;
      _activity = 1;
      _waist.clear();
    });
  }

  void _save() {
    widget.onSave(BmiRecord(
      time: DateTime.now(),
      height: _height,
      weight: _weight,
      age: _age,
      gender: _gender,
    ));
  }

  String _feetInches(double cm) {
    final totalIn = cm / 2.54;
    var ft = totalIn ~/ 12;
    var inch = (totalIn - ft * 12).round();
    if (inch == 12) {
      ft += 1;
      inch = 0;
    }
    return "$ft' $inch\"";
  }

  // ---------- 共用小元件 ----------

  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
                const Spacer(),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _bigValue(String value, String unit) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(value,
            style: t.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(unit, style: t.titleMedium),
      ],
    );
  }

  Widget _stepper({required VoidCallback onMinus, required VoidCallback onPlus}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
            onPressed: onMinus, icon: const Icon(Icons.remove)),
        const SizedBox(width: 24),
        IconButton.filledTonal(onPressed: onPlus, icon: const Icon(Icons.add)),
      ],
    );
  }

  Widget _tile(IconData icon, String label, String value, Color color) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(label, style: t.bodySmall),
          const SizedBox(height: 2),
          Text(value,
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ---------- 輸入區 ----------

  Widget _inputs() {
    final muted = Theme.of(context).textTheme.bodySmall;
    final waist = double.tryParse(_waist.text);
    final waistLimit = _gender == Gender.male ? 90 : 80;

    return Column(
      children: [
        _section(
          icon: Icons.wc,
          title: '性別',
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<Gender>(
              segments: const [
                ButtonSegment(
                    value: Gender.male,
                    icon: Icon(Icons.male),
                    label: Text('男生')),
                ButtonSegment(
                    value: Gender.female,
                    icon: Icon(Icons.female),
                    label: Text('女生')),
              ],
              selected: {_gender},
              onSelectionChanged: (s) => setState(() => _gender = s.first),
            ),
          ),
        ),
        _section(
          icon: Icons.height,
          title: '身高',
          trailing: Text('≈ ${_feetInches(_height)}', style: muted),
          child: Column(
            children: [
              _bigValue(_height.toStringAsFixed(0), 'cm'),
              Slider(
                value: _height,
                min: 100,
                max: 220,
                divisions: 120,
                label: '${_height.round()} cm',
                onChanged: (v) => setState(() => _height = v),
              ),
              _stepper(
                onMinus: () =>
                    setState(() => _height = (_height - 1).clamp(100, 220)),
                onPlus: () =>
                    setState(() => _height = (_height + 1).clamp(100, 220)),
              ),
            ],
          ),
        ),
        _section(
          icon: Icons.monitor_weight_outlined,
          title: '體重',
          trailing: Text('≈ ${(_weight * 2.20462).toStringAsFixed(1)} lb',
              style: muted),
          child: Column(
            children: [
              _bigValue(_weight.toStringAsFixed(1), 'kg'),
              Slider(
                value: _weight,
                min: 30,
                max: 150,
                divisions: 240,
                label: '${_weight.toStringAsFixed(1)} kg',
                onChanged: (v) => setState(() => _weight = v),
              ),
              _stepper(
                onMinus: () =>
                    setState(() => _weight = (_weight - 0.5).clamp(30, 150)),
                onPlus: () =>
                    setState(() => _weight = (_weight + 0.5).clamp(30, 150)),
              ),
            ],
          ),
        ),
        _section(
          icon: Icons.cake_outlined,
          title: '年齡',
          child: Column(
            children: [
              _bigValue('$_age', '歲'),
              const SizedBox(height: 8),
              _stepper(
                onMinus: () => setState(() => _age = math.max(10, _age - 1)),
                onPlus: () => setState(() => _age = math.min(100, _age + 1)),
              ),
            ],
          ),
        ),
        _section(
          icon: Icons.directions_run,
          title: '活動量',
          child: DropdownButton<int>(
            isExpanded: true,
            value: _activity,
            items: [
              for (var i = 0; i < kActivities.length; i++)
                DropdownMenuItem(value: i, child: Text(kActivities[i].$1)),
            ],
            onChanged: (v) => setState(() => _activity = v ?? _activity),
          ),
        ),
        _section(
          icon: Icons.straighten,
          title: '腰圍（選填）',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _waist,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '腰圍 (cm)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (waist != null) ...[
                const SizedBox(height: 8),
                Text(
                  waist >= waistLimit
                      ? '⚠️ 腰圍 ≥ $waistLimit cm，屬於腹部肥胖，要多注意'
                      : '✅ 腰圍在標準範圍內（< $waistLimit cm）',
                  style: TextStyle(
                    color: waist >= waistLimit ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---------- 結果區 ----------

  Widget _results(double bmi) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final cat = categoryOf(bmi);
    final m2 = math.pow(_height / 100, 2).toDouble();
    final lowW = 18.5 * m2;
    final highW = 24 * m2;
    final isMale = _gender == Gender.male;

    String gap;
    if (bmi < 18.5) {
      gap = '再增加 ${(lowW - _weight).toStringAsFixed(1)} kg';
    } else if (bmi >= 24) {
      gap = '需減少 ${(_weight - highW).toStringAsFixed(1)} kg';
    } else {
      gap = '已在範圍內 👍';
    }

    // Deurenberg 體脂率估計
    final bodyFat =
        (1.2 * bmi + 0.23 * _age - 10.8 * (isMale ? 1 : 0) - 5.4).clamp(3, 60);
    // Mifflin-St Jeor 基礎代謝
    final bmr = 10 * _weight + 6.25 * _height - 5 * _age + (isMale ? 5 : -161);
    final tdee = bmr * kActivities[_activity].$2;
    final water = _weight * 30 / 1000;

    final tiles = [
      _tile(Icons.flag_outlined, '健康體重範圍',
          '${lowW.toStringAsFixed(1)}–${highW.toStringAsFixed(1)} kg',
          Colors.green),
      _tile(Icons.trending_flat, '距離健康體位', gap, cat.color),
      _tile(Icons.pie_chart_outline, '體脂率估計',
          '${bodyFat.toStringAsFixed(1)} %', Colors.pink),
      _tile(Icons.local_fire_department_outlined, '基礎代謝 BMR',
          '${bmr.toStringAsFixed(0)} kcal', Colors.orange),
      _tile(Icons.restaurant_outlined, '每日建議熱量',
          '${tdee.toStringAsFixed(0)} kcal', Colors.teal),
      _tile(Icons.water_drop_outlined, '建議飲水量',
          '${water.toStringAsFixed(1)} L', Colors.blue),
    ];

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('你的 BMI', style: t.titleMedium),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: bmi),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Column(
                    children: [
                      SizedBox(
                        height: 190,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: GaugePainter(v, theme.colorScheme.onSurface),
                        ),
                      ),
                      Text(
                        v.toStringAsFixed(1),
                        style: t.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: categoryOf(v).color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Chip(
                    key: ValueKey(cat.name),
                    avatar: Icon(Icons.circle, color: cat.color, size: 14),
                    label: Text(cat.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        for (var i = 0; i < tiles.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: tiles[i]),
                const SizedBox(width: 12),
                Expanded(child: tiles[i + 1]),
              ],
            ),
          ),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: cat.color.withValues(alpha: 0.12),
          child: ListTile(
            leading: Icon(Icons.lightbulb, color: cat.color),
            title: const Text('健康建議'),
            subtitle: Text(cat.tip),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('重設'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('儲存紀錄'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bmi = calcBmi(_height, _weight);
    return LayoutBuilder(
      builder: (context, c) {
        // 寬螢幕：左右兩欄；窄螢幕：上下排列
        if (c.maxWidth >= 900) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _inputs()),
                const SizedBox(width: 16),
                Expanded(child: _results(bmi)),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [_results(bmi), _inputs()],
        );
      },
    );
  }
}

// 半圓形儀表板
class GaugePainter extends CustomPainter {
  GaugePainter(this.bmi, this.textColor);

  final double bmi;
  final Color textColor;
  static const double minB = 15;
  static const double maxB = 40;

  double _angle(double b) =>
      math.pi + (b.clamp(minB, maxB).toDouble() - minB) / (maxB - minB) * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = math.min(size.width / 2 - 30, size.height - 50);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    for (final c in kCategories) {
      final start = _angle(math.max(c.min, minB));
      final end = _angle(math.min(c.max, maxB));
      arc.color = c.color;
      canvas.drawArc(rect, start, end - start, false, arc);
    }

    for (final t in [18.5, 24.0, 27.0, 30.0, 35.0]) {
      final a = _angle(t);
      final p = center + Offset(math.cos(a), math.sin(a)) * (radius + 20);
      final tp = TextPainter(
        text: TextSpan(
          text: fmtNum(t),
          style: TextStyle(fontSize: 11, color: textColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }

    final a = _angle(bmi);
    final tip = center + Offset(math.cos(a), math.sin(a)) * (radius - 18);
    final needle = Paint()
      ..color = textColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, tip, needle);
    canvas.drawCircle(center, 9, Paint()..color = textColor);
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) =>
      oldDelegate.bmi != bmi || oldDelegate.textColor != textColor;
}

// =====================================================
// 歷史紀錄頁
// =====================================================

class HistoryPage extends StatelessWidget {
  const HistoryPage({
    super.key,
    required this.history,
    required this.onRemove,
    required this.onClear,
    required this.onLoadDemo,
  });

  final List<BmiRecord> history;
  final ValueChanged<BmiRecord> onRemove;
  final VoidCallback onClear;
  final VoidCallback onLoadDemo;

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber),
        title: const Text('清除全部紀錄？'),
        content: const Text('這個動作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清除'),
          ),
        ],
      ),
    );
    if (ok == true) onClear();
  }

  Widget _summary(BuildContext context, String label, String value) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Text(value,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label, style: t.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;

    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insights,
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('還沒有任何紀錄', style: t.titleLarge),
              const SizedBox(height: 8),
              const Text('在「計算」頁按「儲存紀錄」，就會出現在這裡',
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: onLoadDemo,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('載入範例資料'),
              ),
            ],
          ),
        ),
      );
    }

    final sorted = [...history]..sort((a, b) => a.time.compareTo(b.time));
    final bmis = sorted.map((r) => r.bmi).toList();
    final avg = bmis.reduce((a, b) => a + b) / bmis.length;
    final hi = bmis.reduce(math.max);
    final lo = bmis.reduce(math.min);
    final change = sorted.last.weight - sorted.first.weight;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BMI 趨勢', style: t.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: TrendPainter(
                      bmis,
                      theme.colorScheme.primary,
                      theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.green.withValues(alpha: 0.25),
                    ),
                    const SizedBox(width: 6),
                    Text('綠色區域 = 健康體位 18.5–24', style: t.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _summary(context, '筆數', '${sorted.length}'),
            _summary(context, '平均', avg.toStringAsFixed(1)),
            _summary(context, '最高', hi.toStringAsFixed(1)),
            _summary(context, '最低', lo.toStringAsFixed(1)),
          ],
        ),
        Card(
          child: ListTile(
            leading: Icon(
              change <= 0 ? Icons.trending_down : Icons.trending_up,
              color: change <= 0 ? Colors.green : Colors.orange,
              size: 32,
            ),
            title: Text(
                '體重變化 ${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg'),
            subtitle: Text('從 ${fmtTime(sorted.first.time)} 到最新一筆'),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('全部紀錄', style: t.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep),
              label: const Text('全部清除'),
            ),
          ],
        ),
        for (final r in sorted.reversed)
          Dismissible(
            key: ObjectKey(r),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => onRemove(r),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: categoryOf(r.bmi).color,
                  foregroundColor: Colors.white,
                  child: Text(r.bmi.toStringAsFixed(0)),
                ),
                title: Text(
                    'BMI ${r.bmi.toStringAsFixed(1)}・${categoryOf(r.bmi).name}'),
                subtitle: Text(
                    '${r.height.toStringAsFixed(0)} cm / ${r.weight.toStringAsFixed(1)} kg・${fmtTime(r.time)}'),
                trailing:
                    Icon(r.gender == Gender.male ? Icons.male : Icons.female),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text('提示：紀錄往左滑可以刪除',
            textAlign: TextAlign.center, style: t.bodySmall),
      ],
    );
  }
}

// 折線趨勢圖
class TrendPainter extends CustomPainter {
  TrendPainter(this.values, this.lineColor, this.textColor);

  final List<double> values;
  final Color lineColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 32.0, right = 12.0, top = 8.0, bottom = 8.0;
    final lo = math.min(values.reduce(math.min), 17.0) - 1;
    final hi = math.max(values.reduce(math.max), 25.0) + 1;
    final w = size.width - left - right;
    final h = size.height - top - bottom;

    double y(double v) => top + (hi - v) / (hi - lo) * h;
    double x(int i) => values.length == 1
        ? left + w / 2
        : left + i / (values.length - 1) * w;

    // 健康體位區間
    canvas.drawRect(
      Rect.fromLTRB(left, y(24), left + w, y(18.5)),
      Paint()..color = Colors.green.withValues(alpha: 0.18),
    );

    // 格線與刻度
    final grid = Paint()
      ..color = textColor.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    for (var v = lo.ceilToDouble(); v <= hi; v += 2) {
      canvas.drawLine(Offset(left, y(v)), Offset(left + w, y(v)), grid);
      final tp = TextPainter(
        text: TextSpan(
          text: v.toStringAsFixed(0),
          style: TextStyle(
              fontSize: 10, color: textColor.withValues(alpha: 0.7)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y(v) - tp.height / 2));
    }

    // 折線
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final p = Offset(x(i), y(values[i]));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );

    // 資料點
    for (var i = 0; i < values.length; i++) {
      final p = Offset(x(i), y(values[i]));
      canvas.drawCircle(p, 6, Paint()..color = categoryOf(values[i]).color);
      canvas.drawCircle(
        p,
        6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(TrendPainter oldDelegate) => true;
}

// =====================================================
// 健康知識頁
// =====================================================

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  static String _range(BmiCategory c) {
    if (c.min == 0) return '< ${fmtNum(c.max)}';
    if (c.max >= 999) return '≥ ${fmtNum(c.min)}';
    return '${fmtNum(c.min)} – ${fmtNum(c.max)}';
  }

  Widget _infoCard(
      BuildContext context, IconData icon, String title, Widget child) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(title, style: theme.textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard(
          context,
          Icons.help_outline,
          '什麼是 BMI？',
          const Text(
            'BMI（身體質量指數）是用身高和體重估算體位的常用指標。\n\n'
            'BMI = 體重(kg) ÷ 身高(m)²\n\n'
            '例如身高 170 cm、體重 65 kg：65 ÷ (1.7 × 1.7) ≈ 22.5',
          ),
        ),
        _infoCard(
          context,
          Icons.table_chart_outlined,
          '成人體位分類（衛福部國健署）',
          Column(
            children: [
              for (final c in kCategories)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                            color: c.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(c.name)),
                      Text(_range(c),
                          style: t.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        _infoCard(
          context,
          Icons.straighten,
          '腰圍標準',
          const Text('男性腰圍 ≥ 90 cm、女性腰圍 ≥ 80 cm 屬於「腹部肥胖」，'
              '即使 BMI 正常也要注意。'),
        ),
        _infoCard(
          context,
          Icons.functions,
          '本 App 使用的公式',
          const Text(
            '• 體脂率估計：Deurenberg 公式\n'
            '• 基礎代謝 BMR：Mifflin-St Jeor 公式\n'
            '• 每日建議熱量：BMR × 活動係數\n'
            '• 建議飲水量：體重 × 30 ml',
          ),
        ),
        _infoCard(
          context,
          Icons.info_outline,
          '注意事項',
          const Text(
            'BMI 不適用於孕婦、哺乳婦女、兒童青少年，以及肌肉量特別高的運動員。'
            '本 App 的數值僅供參考，不能取代醫師或營養師的專業建議。',
          ),
        ),
      ],
    );
  }
}
