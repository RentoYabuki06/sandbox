import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // intlパッケージをインポート

// メモのデータモデル
class Memo {
  final String text;
  bool isCompleted; // 完了状態を追加
  final DateTime createdTime; // 作成日時フィールドを追加

  // Memoクラスのコンストラクタの定義
  // this.textだけ必須、isCompletedはデフォルトでfalse, createdTimeはnull. ?はnullable
  // ??演算子はnullチェック、左側がnullの場合は右側の値が代入される
  // コンストラクタの後に":"をつけることでフィールドの初期化処理を記述できる
  // createdTimeがnullでない時には現在の日時で初期化
  Memo(this.text, {this.isCompleted = false, DateTime? createdTime})
      : createdTime = createdTime ?? DateTime.now();
}

// 状態管理
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
              //expandedは利用可能な余白を全て占有し、画面上で可能な限り表示
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
  // consumerwidgetで監視するならwidgetref refを引数に追加
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController textController = TextEditingController();

    return Padding(
      padding: EdgeInsets.all(8.0), // 4方向全ての側面に8.0の余白
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: '新しいメモを追加しましょう',
                hintText: 'Enter new memo', // 薄く表示されているコメント
                border: OutlineInputBorder(), // 境界線をアウトラインで描画
              ),
              onSubmitted: (value) {
                final currentList = ref.read(memoListProvider);
                ref.read(memoListProvider.notifier).state = [
                  ...currentList, // 現状のリストを展開し
                  Memo(value) // 新しい要素を追加
                ];
                textController.clear(); //　入力フィールドを初期化
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
            DateFormat('yyyy年MM月dd日 HH:mm').format(memo.createdTime);

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
          // Card : 周りから浮き出ている表示
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
      // 順番入れ替え
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
