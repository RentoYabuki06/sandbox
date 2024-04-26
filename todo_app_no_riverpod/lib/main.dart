import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Todo {
  final String text;
  bool isCompleted;
  final DateTime createdTime;
  // コンストラクタ
  Todo(this.text, {this.isCompleted = false, DateTime? createdTime})
      : createdTime = createdTime ?? DateTime.now();
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('todo app no riverpod'),
        ),
        body: Todolist(),
      ),
    ),
  );
}

class Todolist extends StatefulWidget {
  const Todolist({super.key});

  @override
  State<Todolist> createState() => _TodolistState();
}

class _TodolistState extends State<Todolist> {
  List<Todo> _memos = []; // memoのリストを初期化
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: '新しいメモを追加しましょう',
                  hintText: 'Enter new memo',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  _addMemo(value); // テキストが提出されたときにメソッドを呼び出す
                },
              ),
            ),
            IconButton(
                icon: Icon(Icons.add_a_photo_rounded),
                onPressed: () {
                  _addMemo(_textController.text);
                }),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _memos.length,
            itemBuilder: (context, index) {
              final memo = _memos[index];
              final formattedDate =
                  DateFormat('HH:MM DD.MM.YYYY').format(memo.createdTime);

              return Dismissible(
                key: Key(memo.text + index.toString()),
                direction: DismissDirection.horizontal,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.green,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    setState(() {
                      _memos.removeAt(index); // チェックボックスをオンにする
                    });
                  } else if (direction == DismissDirection.startToEnd) {
                    setState(() {
                      _memos.removeAt(index);
                    });
                  }
                },
                child: ListTile(
                  title: Text(memo.text),
                  subtitle: Text(formattedDate),
                  // trailing 右側に配置されるウィジェット
                  trailing: Checkbox(
                    value: memo.isCompleted,
                    onChanged: (bool? newValue) {
                      setState(() {
                        memo.isCompleted = newValue!; // コンパイラにnullでないことを明示
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // テキストフィールドが提出されたら
  void _addMemo(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _memos.add(Todo(text));
      });
      _textController.clear();
    }
  }
}
