#Report: patch-panel
Submission: &nbsp; Oct./20/2016<br>
Branch: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; develop<br>






##提出者
<B>辻　健太</B><br>
33E16012<br>
長谷川研究室 所属<br>






##コマンドの追加方法
コマンドは
[bin/patch_panel](bin/patch_panel)
において下記ブロックを追記することで追加できる．<br>
```
desc 'コマンドの説明'
arg_name '引数の説明'
command :実際のコマンド do |c|
  c.desc 'Location to find socket files'
  c.flag [:S, :socket_dir], default_value: Trema::DEFAULT_SOCKET_DIR

  c.action do |_global_options, options, args|
     #引数を格納したリストargsから引数を取得する．
    Trema.trema_process('PatchPanel', options[:socket_dir]).controller.lib/patch-panel.rbにおけるメソッド
  end
end
```
このとき，
```
Trema.trema_process('PatchPanel', options[:socket_dir]).controller.lib/patch-panel.rbにおけるメソッド
```
によってコントローラのメソッドを呼び出すため，
[lib/patch_panel.rb](lib/patch_panel.rb)
における出力はコントローラを起動している端末において行われる．<br>
しかし，tremaのコマンドを入力する端末へ出力するために，
[bin/patch_panel](bin/patch_panel)
において出力命令を記述する必要がある．<br>
```
puts Trema.trema_process('PatchPanel', options[:socket_dir]).controller.lib/patch-panel.rbにおけるメソッド
```
そこで，下記のように出力命令を書き，
[lib/patch_panel.rb](lib/patch_panel.rb)
において出力情報を返すようにする．<br>








##追加したコマンド（ボーナス点対象）
<p>以下３つのコマンドを追加した．</p>

###① ポートのミラーリング
コネクションID（`dpid`）先にあるスイッチにおいて，`port_monitor`ポートから入ってくるパケットを`port_monitor`ポートへミラーリングする．<br>
コマンドは下記の通りである．<br>
```
./bin/patch_panel mirror dpid port_monitor port_mirror
```
このコマンドは
[lib/patch_panel.rb](lib/patch_panel.rb)
における`create_mirror`メソッドを呼び出し，下記の順で処理する．<br>
####１． `add_mirror_entry`メソッドを呼び出す．
フローテーブルにMirroringを実現するルールを追加する．<br>
具体的なルールは，port_monitorが所属するパッチ`port_out`を`@patches`から取得し，`port_monitor`からのPacketInに対しては`port_out`および`port_mirror`へフォワーディングする．<br>
####２．`@mirrors`へミラーリングを記録する．
[lib/patch_panel.rb](lib/patch_panel.rb)
の`start`メソッドにおいてインスタンス変数`@mirrors`（ハッシュ）を宣言し，`@patches`
と同様に，`add_mirror_entry`メソッドによって実現したミラーをリスト構造として記録する．<br>

###② パッチとポートミラーリングの一覧
コネクションID（`dpid`）先にあるスイッチにおけるパッチおよびミラーの一覧を表示する．<br>
コマンドは下記の通りである．<br>
```
./bin/patch_panel dump dpid
```
このコマンドは
[lib/patch_panel.rb](lib/patch_panel.rb)
における`dump`メソッドを呼び出し，下記の順で処理する．<br>
####１． パッチの一覧を出力する．
インスタンス変数`@patches`からパッチを構成するポート番号の組を取得し，下記の例の通りに出力する．
下記の例では，ポート1とポート2がパッチを構成していることを示す．<br>
```
Patches:
  1<->2
```
####２． ミラーの一覧を出力する．
インスタンス変数`@mirrors`からミラーを構成するポート番号の組を取得し，下記の例の通りに出力する．<br>
下記の例では，ポート1がポート3へミラーリングされていることを示す．<br>
```
Mirrors:
	1->3
```
###③ ミラーリングの削除（ボーナス点対象）
コネクションID（`dpid`）先にあるスイッチにおいて，`port_monitor`ポートから`port_monitor`ポートへのミラーリングを削除する．<br>
コマンドは下記の通りである．<br>
```
./bin/patch_panel delete_mirror dpid port_monitor port_mirror
```
このコマンドは
[lib/patch_panel.rb](lib/patch_panel.rb)
における`delete_mirror`メソッドを呼び出し，下記の順で処理する．<br>
####１． ミラーリングの存在を確認する．
生成済みのミラーリングはインスタンス変数`@mirrors`に記録してあるため，コマンド入力された`port_monitor`ポートから`port_monitor`ポートへのミラーリングが生成済みなのかを確認する．<br>
もしミラーリングが存在していれば次の処理２へ進み，そうでなければ下記の例のようなエラーメッセージを返す．<br>
下記の例は，ポート1からポート2へのミラーリングが存在していないことを示す．<br>
```
[1, 2] does NOT exist in Mirrors.
```
####２． `delete_mirror_entry`メソッドを呼び出す．
フローテーブルからMirroringを実現するルールを削除する．<br>
まず，フローテーブルにおいて，`port_monitor`からのパケット入力に対するルールを全て削除する
次に，port_monitorが所属するパッチ`port_out`を`@patches`から取得し，`port_monitor`からのPacketInに対しては`port_out`へフォワーディングするルールをフローテーブルに加える．<br>
<p>ここで，このコマンドを呼び出す前のフローテーブルを下に示す．
このとき，ポート1とポート2はパッチを構成しているとする．
そして，ポート1から入ってきたパケットに対してはポート3へミラーリングする設定がなされている．</p>
```
cookie=0x0, duration=20.942s, table=0, n_packets=0, n_bytes=0, idle_age=20, priority=0,in_port=1 actions=output:2,output:3
cookie=0x0, duration=31.907s, table=0, n_packets=0, n_bytes=0, idle_age=31, priority=0,in_port=2 actions=output:1
```
<p>さらに，このコマンドを呼び出した後のフローテーブルを下に示す．
先ほどのフローテーブルとは異なり，ポート1から入ってきたパケットに対してはポート2へのみフォワーディングする設定がなされており，ミラーリングが削除されたことがわかる．</p>
```
cookie=0x0, duration=79.282s, table=0, n_packets=0, n_bytes=0, idle_age=79, priority=0,in_port=1 actions=output:2
cookie=0x0, duration=244.282s, table=0, n_packets=0, n_bytes=0, idle_age=244, priority=0,in_port=2 actions=output:1
```
####３．`@mirrors`が保持するミラーリング記録を削除する．
生成済みのミラーリングはインスタンス変数`@mirrors`に記録してあるため，これを削除する．<br>
ここで，ポート1とポート2はパッチを構成しており，かつポート1からポート3へのミラーリングが生成されているとする．<br>
そして，このときの`dump`コマンドの実行結果を下に記す．
```
Patches:
	1<->2
Mirrors:
	1->3
```
さらに，`delete_mirror`コマンドを実行した後の`dump`コマンドの実行結果を下に記す．<br>
下記の例より，ポート1からポート3へのミラーリングの記録が`@mirrors`から削除されたことがわかる．<br>
```
Patches:
	1<->2
Mirrors:
```



##関連リンク
* [課題 (パッチパネルの機能拡張)](https://github.com/handai-trema/deck/blob/develop/week3/assignment_patch_panel.md)
* [bin/patch_panel](bin/patch_panel)
* [lib/patch_panel.rb](lib/patch_panel.rb)
