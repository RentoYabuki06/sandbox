import 'package:flutter/material.dart';
// riverpodsを使用するためのパッケージ
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 時間表示を変更するためのpackage
import 'package:intl/intl.dart';

// Todoのデータモデル（変化なし）
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

// RiverpodのProviderを使ってTodoのリストを管理するProvider
// refパラメータを受け取り、todoリストの初期値を返す
final todoListProvider = StateProvider<List<Todo>>((ref) => []);

void main() {
  runApp(
    ProviderScope(
      child: const MaterialApp(
        home: TodoApp(),
      ),
    ),
  );
}

// StatelessWidgetでUIを作成
class TodoApp extends StatelessWidget {
  // スーパーコンストラクタに直接keyパラメータを追加
  const TodoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TodoApp_riverpods'),
      ),
      body: Column(
        children: [
          // 入力フィールドのUIウィジェット
          Expanded(
            child: TodoInputField(),
          ), // todolistを表示している部分のUIウィジェット
          Expanded(
            child: TodoList(),
          ), // todolistを表示している部分のUIウィジェット
        ],
      ),
    );
  }
}

// 入力フィールドのUI
class TodoInputField extends ConsumerWidget {
  // スーパーコンストラクタに直せkeyパラメータを追加
  const TodoInputField({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController textController = TextEditingController();
    final notifier = ref.read(todoListProvider.notifier);

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Enter new todo',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.clear),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                notifier.state.add(
                  Todo(
                    text: value,
                    addedDate: DateTime.now(),
                  ),
                );
                textController.clear();
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.state.add(
                Todo(
                  text: textController.text,
                  addedDate: DateTime.now(),
                ),
              );
              textController.clear();
            },
            child: const Text('Add todo'),
          ),
        ],
      ),
    );
  }
}

// todolisetのUI（変化する部分なのでConsumerWidgetで作成)
class TodoList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        String formattedDate =
            DateFormat('yyyy年MM月dd日 HH:mm').format(todos[index].addedDate);
        return Dismissible(
          key: ValueKey(todos[index]),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            final notifier = ref.read(todoListProvider.notifier);
            notifier.state.removeAt(index);
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
            title: Text(todos[index].text),
            subtitle: Text(formattedDate),
            value: todos[index].isCompleted,
            onChanged: (newValue) {
              ref.read(todoListProvider)[index].isCompleted = newValue!;
            },
            secondary: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                final notifier = ref.read(todoListProvider.notifier);
                notifier.state.removeAt(index);
              },
            ),
          ),
        );
      },
    );
  }
}
