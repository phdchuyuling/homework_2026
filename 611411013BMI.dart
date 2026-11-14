import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '精美 BMI 計算機',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
      ),
      home: const BMIScreen(),
    );
  }
}

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  String result = '';
  String bmiDescription = '';
  Color resultColor = Colors.grey;

  void calculateBMI() {
    final height = double.tryParse(heightController.text.trim()) ?? 0;
    final weight = double.tryParse(weightController.text.trim()) ?? 0;

    if (height <= 0 || weight <= 0) {
      setState(() {
        result = '--';
        bmiDescription = '請輸入正確的身高與體重';
        resultColor = Colors.grey;
      });
      return;
    }

    final bmi = weight / ((height / 100) * (height / 100));
    String description;
    Color color;
    if (bmi < 18.5) {
      description = '體重過輕';
      color = Colors.orange;
    } else if (bmi < 24) {
      description = '體重正常';
      color = Colors.green;
    } else if (bmi < 27) {
      description = '體重過重';
      color = Colors.deepOrange;
    } else {
      description = '輕度／重度肥胖';
      color = Colors.red;
    }

    setState(() {
      result = bmi.toStringAsFixed(2);
      bmiDescription = description;
      resultColor = color;
    });
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('BMI 計算機', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF6366F1),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('健康指數計算', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 8),
                    const Text('請輸入您的身高與體重數據', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: heightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: '身高 (cm)',
                        prefixIcon: const Icon(Icons.height, color: Color(0xFF6366F1)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onSubmitted: (_) => calculateBMI(),
                      decoration: InputDecoration(
                        labelText: '體重 (kg)',
                        prefixIcon: const Icon(Icons.fitness_center, color: Color(0xFF6366F1)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: calculateBMI,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
                      ),
                      child: const Text('立即計算', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                      child: Column(children: [
                        const Text('您的 BMI 結果', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(result.isEmpty ? '--' : result,
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: resultColor)),
                        const SizedBox(height: 4),
                        Text(bmiDescription.isEmpty ? '等待輸入...' : bmiDescription,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: resultColor)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
