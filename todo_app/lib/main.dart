import 'package:flutter/material.dart';
// 時間表示を変更するためのpackage
import 'package:intl/intl.dart';

class Todo {
  final String text;
  final DateTime addedDate;
  bool isCompleted;

  Todo({
    required this.text,
    required this.addedDate,
    this.isCompleted = false,
  });
}

class TodoApp extends StatefulWidget {
  @override
  _todoAppState createState() => _todoAppState();
}

class _todoAppState extends State<TodoApp> {
  // 入力フィールドの作成
  final TextEditingController _textController = TextEditingController();
  // todoを保持するリスト
  List<Todo> _todos = [];

  void _addTodo() {
    setState(() {
      // _textControllerという名前のTextEditingController オブジェクトの text プロパティにアクセス
      String newTodo = _textController.text;
      if (newTodo.isNotEmpty) {
        _todos.add(Todo(text: newTodo, addedDate: DateTime.now())); //リストに追加
        _textController.clear(); // 入力テキストフィールドをクリア
      }
    });
  }

  void _toggleTodoCompletion(int index, bool newValue) {
    setState(() {
      _todos[index].isCompleted = newValue;
    });
  }

  void _removeTodoAtIndex(int index) {
    setState(() {
      _todos.removeAt(index); // removeAt を使用して指定したインデックスの要素を削除します
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TodoApp'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _textController,
                // 入力フィールドのデコ
                decoration: InputDecoration(
                  hintText: 'Enter new todo',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.clear),
                  border: OutlineInputBorder(),
                ),
                // Enterが押されたら実行される関数
                // (_)は引数を使用しないことを示す慣習
                onSubmitted: (_) => _addTodo(),
              ),
              ElevatedButton(
                onPressed: _addTodo,
                child: Text('Add todo'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _todos.length,
                  itemBuilder: (context, index) {
                    String formattedDate = DateFormat('yyyy年MM月dd日 HH:mm')
                        .format(_todos[index].addedDate);
                    return Dismissible(
                      key: ValueKey(_todos[index]),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        _removeTodoAtIndex(index);
                      },
                      background: Container(
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: CheckboxListTile(
                        title: Text(_todos[index].text),
                        subtitle: Text(formattedDate),
                        value: _todos[index].isCompleted,
                        onChanged: (newValue) {
                          // null合体演算子, nullだとfalse,nullでない場合はnewValueを返す
                          _toggleTodoCompletion(index, newValue ?? false);
                        },
                        secondary: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeTodoAtIndex(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(TodoApp());
}
