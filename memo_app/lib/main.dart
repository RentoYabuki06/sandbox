import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // intlパッケージをインポート

// メモのデータモデル
class Memo {
  final String text;
  bool isCompleted; // 完了状態を追加
  final DateTime createdTime; // 作成日時フィールドを追加

  Memo(this.text, {this.isCompleted = false, DateTime? createdTime})
      : this.createdTime = createdTime ?? DateTime.now(); // 現在の日時で初期化
}

// メモのリストを管理するProvider
final memoListProvider = StateProvider<List<Memo>>((ref) => []);

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Memo App'),
          ),
          body: Column(
            children: [
              MemoInputField(),
              Expanded(
                child: MemoList(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// メモの入力フィールド
class MemoInputField extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController textController = TextEditingController();

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Enter new memo',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final currentList = ref.read(memoListProvider);
                ref.read(memoListProvider.notifier).state = [
                  ...currentList,
                  Memo(value)
                ];
                textController.clear();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              final currentList = ref.read(memoListProvider);
              ref.read(memoListProvider.notifier).state = [
                ...currentList,
                Memo(textController.text)
              ];
              textController.clear();
            },
          ),
        ],
      ),
    );
  }
}

// メモのリストを表示するウィジェット
class MemoList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memos = ref.watch(memoListProvider);

    return ReorderableListView.builder(
      itemCount: memos.length,
      itemBuilder: (context, index) {
        final memo = memos[index];
        // 日時をフォーマットする
        final formattedTime =
            DateFormat('yyyy年MM月dd日HH:mm').format(memo.createdTime);

        return Dismissible(
          key: Key(memo.text + index.toString()), // 一意のキーを確保
          direction: DismissDirection.endToStart, // 右から左へのスワイプのみ許可
          onDismissed: (direction) {
            // スワイプで削除されたときの処理
            final updatedList = List<Memo>.from(memos)..removeAt(index);
            ref.read(memoListProvider.notifier).state = updatedList;
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            key: ValueKey(memo), // ReorderableListViewのために追加
            elevation: 4.0, // カードの影の大きさ
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // カードの角の丸み
            ),
            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: ListTile(
              title: Text(memo.text),
              subtitle: Text(formattedTime), // 作成日時を表示
              trailing: Checkbox(
                value: memo.isCompleted,
                onChanged: (bool? newValue) {
                  memo.isCompleted = newValue!;
                  ref.read(memoListProvider.notifier).state = List.from(memos);
                  // SnackBarの表示
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(newValue ? "finish!" : "Retry!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final Memo item = memos.removeAt(oldIndex);
        memos.insert(newIndex, item);
        ref.read(memoListProvider.notifier).state = List.from(memos);
      },
    );
  }
}
