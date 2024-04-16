import 'package:flutter/material.dart';
// StatefulWidgetを使用してカウンターアプリを作成

// StatelessWidget：一度描画されると変化しない。常に同じ表示をするテキストやアイコンなど。
// StatefullWidget：ユーザの操作などによって変化する。ボタンを押したりスクロールすることで表示が変化。

// StatefulWidgetクラスは外見や配置など静的な情報を保持
// Stateクラスはウィジェットの状態を保持。再描画される内容を定義。
// ボタンが押される度にcreateState()メソッドを呼び出し、新しいStateオブジェクトを作成
class CounterApp extends StatefulWidget {
  @override
  _CounterAppState createState() => _CounterAppState();
}

// 内部状態を管理するクラス(=プライベート)のため、アンダーバーから始める
class _CounterAppState extends State<CounterApp> {
  int _counter = 0; // カウンターの初期値

  // カウンターをインクリメントする関数
  // setState関数：ウィジェットの状態変化をフレームワークに通知
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // カウンターをデクリメントする関数
  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  // BuildContextはウィジェットツリー内の特定の位置を表す
  // ウィジェットは階層構造になっているので、そのナビゲートの手段。
  // BuildContext context : buildメソッド内で現在のウィジェットのビルドコンテキストへアクセスしている
  Widget build(BuildContext context) {
    return MaterialApp(
      // homeプロパティはウィジェットツリーのトップ
      // メイン画面、つまり初期画面が指定されることが多い
      home: Scaffold(
        // AppBarにアプリの名前を表示
        // appBarプロパティにはAppBarウィジェットが指定される
        appBar: AppBar(
          title: const Text('Counter App'),
        ),
        // アプリの要素（Centerで全て横方向の中央揃え）
        body: Center(
          child: Column(
            // 縦方向の中央揃え
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Counter:',
                style: TextStyle(fontSize: 20.0),
              ),
              Text(
                // "_counter"という変数の表示
                '$_counter',
                style: TextStyle(fontSize: 40.0),
              ),
              // 高さ20pxの余白生成
              SizedBox(height: 20.0),
              Row(
                // 横方向の中央揃え（これ書かないと左詰めになる）
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //インクリメント用のボタン
                  ElevatedButton(
                    onPressed: _incrementCounter,
                    child: Icon(Icons.add),
                  ),
                  SizedBox(width: 20.0),
                  // デクリメント用のボタン
                  ElevatedButton(
                    onPressed: _decrementCounter,
                    child: Icon(Icons.remove),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(CounterApp());
}

// // StatelessWidgetを継承した新しいクラスの作成
// class PrintHelloWorld extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('MyStatelessWidget'),
//         ),
//         body: const Center(
//           child: Text(
//             'Hello World!',
//             style: TextStyle(fontSize: 24.0),
//           ),
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(PrintHelloWorld());
// }

// //"Hello,worldの出力"
// void main() {
//   const print_helloworld = MaterialApp(
//     home: Scaffold(
//       body: Center(
//         child: Text('Hello, world'),
//       ),
//     ),
//   );
//   runApp(print_helloworld);
// }