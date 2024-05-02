import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // intlパッケージをインポート
// firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app_firestore/date_time_timestamp_converter.dart';
import 'firebase_options.dart';

// freezed
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main.freezed.dart';
part 'main.g.dart';

// FirebaseFirestoreインスタンスの取得
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  // // インスタンスを正しく取得できているかの検証用
  // final instance = FirebaseFirestore.instance;
  // print('Firestore instance: $instance'); // インスタンスを出力
  return FirebaseFirestore.instance;
});

// メモのデータモデル
@freezed
class Memo with _$Memo {
  const factory Memo({
    String? id,
    required String text,
    @Default(false) bool isCompleted,
    @DateTimeTimestampConverter() required DateTime createdTime,
  }) = _Memo;

  factory Memo.fromJson(Map<String, dynamic> json) => _$MemoFromJson(json);
}

// // 状態管理
// // メモのリストを管理するProvider
final memoListProvider = StateProvider<List<Memo>>((ref) => []);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Firestore Todo App'),
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
              // データベースの読み書き操作など時間のかかる可能性のある処理は非同期で行われる
              onSubmitted: (value) async {
                final firestore = ref.read(firestoreProvider);
                await firestore.collection('memos').add({
                  'text': value,
                  'isCompleted': false,
                  'createdTime': DateTime.now(),
                });
                textController.clear(); //　入力フィールドを初期化
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final firestore = ref.read(firestoreProvider);
              await firestore.collection('memos').add({
                'text': textController.text,
                'isCompleted': false,
                'createdTime': DateTime.now(),
              });
              textController.clear();
            },
          ),
        ],
      ),
    );
  }
}

Stream<List<Memo>> getMemoListStream() {
  return FirebaseFirestore.instance.collection('memos').snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map(
              (doc) => Memo.fromJson(doc.data() as Map<String, dynamic>)
                  .copyWith(id: doc.id),
            )
            .toList(),
      );
}

// メモのリストを表示するウィジェット
class MemoList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore =
        ref.watch(firestoreProvider); // firestoreProvider をウォッチして、firestore を取得
    return StreamBuilder<List<Memo>>(
        stream: getMemoListStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final memos = snapshot.data!;
            return ReorderableListView.builder(
              itemCount: memos.length,
              itemBuilder: (context, index) {
                final memo = memos[index];
                // 日時をフォーマットする
                final formattedTime =
                    DateFormat('yyyy年MM月dd日 HH:mm').format(memo.createdTime);

                return Dismissible(
                  key: Key(memo.id ?? 'dummy'), // 一意のキーを確保
                  direction: DismissDirection.startToEnd, // 右から左へのスワイプのみ許可
                  onDismissed: (direction) async {
                    await firestore.collection('memos').doc(memo.id).delete();
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
                    margin:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: ListTile(
                      title: Text(memo.text),
                      subtitle: Text(formattedTime), // 作成日時を表示
                      trailing: Checkbox(
                        value: memo.isCompleted,
                        onChanged: (bool? newValue) async {
                          // firebaseに保存する処理を追加
                          await firestore
                              .collection('memos')
                              .doc(memo.id)
                              .update({
                            'isCompleted': newValue,
                          });
                          // ローカルのメモリストを更新
                          // map関数でmemosリスト内の要素を捜査
                          final updatedMemos = memos.map((m) {
                            // 一致しているidを見つけたら変更
                            if (m.id == memo.id) {
                              // newValueがnullの場合はfalse
                              return m.copyWith(isCompleted: newValue ?? false);
                            }
                            return m;
                          }).toList();
                          // memoListProviderの状態を更新してUIに変更を通知
                          ref.read(memoListProvider.notifier).state =
                              updatedMemos;
                          // SnackBarの表示
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(newValue != null
                                  ? (newValue ? "finish!" : "Retry!")
                                  : "Retry"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ); // dismissible
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
            ); // ReorderableListView.builder
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
