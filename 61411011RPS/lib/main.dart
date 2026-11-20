import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const RockPaperScissorsApp());
}

class RockPaperScissorsApp extends StatelessWidget {
  const RockPaperScissorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '猜拳小遊戲',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<String> _choices = ['剪刀', '石頭', '布'];
  final Map<String, String> _emojis = {
    '剪刀': '✌️',
    '石頭': '✊',
    '布': '🖐️',
  };

  String _userChoice = '❓';
  String _compChoice = '❓';
  String _resultText = '請選擇下方按鈕出拳';
  Color _resultColor = Colors.black87;
  int _userScore = 0;
  int _compScore = 0;

  void _play(String userMove) {
    final compMove = _choices[Random().nextInt(_choices.length)];

    setState(() {
      _userChoice = _emojis[userMove]!;
      _compChoice = _emojis[compMove]!;

      if (userMove == compMove) {
        _resultText = '平手！';
        _resultColor = Colors.grey.shade700;
      } else if ((userMove == '剪刀' && compMove == '布') ||
          (userMove == '石頭' && compMove == '剪刀') ||
          (userMove == '布' && compMove == '石頭')) {
        _resultText = '你贏了！';
        _resultColor = Colors.green.shade700;
        _userScore++;
      } else {
        _resultText = '電腦贏了！';
        _resultColor = Colors.red.shade700;
        _compScore++;
      }
    });
  }

  void _resetGame() {
    setState(() {
      _userChoice = '❓';
      _compChoice = '❓';
      _resultText = '請選擇下方按鈕出拳';
      _resultColor = Colors.black87;
      _userScore = 0;
      _compScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('剪刀、石頭、布', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScoreColumn('玩家', _userScore, Colors.indigo),
                    const Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    _buildScoreColumn('電腦', _compScore, Colors.deepOrange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMoveDisplay('你出的是', _userChoice),
                const SizedBox(width: 60),
                _buildMoveDisplay('電腦出的是', _compChoice),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              _resultText,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _resultColor,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _choices.map((choice) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () => _play(choice),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: Text('${_emojis[choice]} $choice'),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _resetGame,
              icon: const Icon(Icons.refresh),
              label: const Text('重新計分'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreColumn(String label, int score, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildMoveDisplay(String label, String emoji) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 10),
        Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 48)),
        ),
      ],
    );
  }
}
