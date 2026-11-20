import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '打地鼠',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2f6f4e)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '打地鼠'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const roundSeconds = 30;
  final random = Random();
  Timer? gameTimer;
  Timer? moleTimer;
  int score = 0;
  int secondsLeft = roundSeconds;
  int moleIndex = -1;
  bool isPlaying = false;
  String status = '準備好了嗎？按下開始遊戲！';

  void startGame() {
    gameTimer?.cancel();
    moleTimer?.cancel();
    setState(() {
      score = 0;
      secondsLeft = roundSeconds;
      moleIndex = random.nextInt(6);
      isPlaying = true;
      status = '快！點擊冒出來的地鼠！';
    });
    moleTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (isPlaying) setState(() => moleIndex = random.nextInt(6));
    });
    gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsLeft <= 1) {
        endGame();
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  void endGame() {
    gameTimer?.cancel();
    moleTimer?.cancel();
    setState(() {
      secondsLeft = 0;
      moleIndex = -1;
      isPlaying = false;
      status = '時間到！你的分數是 $score 分';
    });
  }

  void hitMole(int index) {
    if (!isPlaying || index != moleIndex) return;
    setState(() {
      score++;
      moleIndex = -1;
      status = '命中！繼續保持！';
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    moleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4ead5),
      appBar: AppBar(
        backgroundColor: const Color(0xff2f6f4e),
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Center(child: Text('得分  $score', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
          const SizedBox(width: 20),
          Center(child: Text('時間  $secondsLeft', style: const TextStyle(fontSize: 17, color: Color(0xffffe0a6), fontWeight: FontWeight.bold))),
          const SizedBox(width: 20),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(child: _buildBoard()),
                const SizedBox(height: 16),
                Text(status, style: const TextStyle(fontSize: 16, color: Color(0xff4b4033))),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: startGame,
                  icon: const Icon(Icons.refresh),
                  label: Text(isPlaying ? '重新開始' : '開始遊戲'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xffb9d995),
        borderRadius: BorderRadius.circular(20),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 28,
        ),
        itemCount: 6,
        itemBuilder: (_, index) => GestureDetector(
          onTap: () => hitMole(index),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xff4a3428))),
              if (moleIndex == index) const Text('🐹', style: TextStyle(fontSize: 58)),
            ],
          ),
        ),
      ),
    );
  }
}
