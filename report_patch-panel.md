#Report: patch-panel
Submission: &nbsp; Oct./20/2016<br>
Branch: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; develop<br>






##提出者
<B>辻　健太</B><br>
33E16012<br>
長谷川研究室 所属<br>



##コマンドの追加方法



##追加したコマンド（ボーナス点対象）
以下３つのコマンドを追加した．

###① ポートのミラーリング
リンクID（`dpid`）先にあるスイッチにおいて，`port_monitor`ポートから入ってくるパケットを`port_monitor`ポートへミラーリングする．
コマンドは下記の通りである．<br>
```
./bin/patch_panel mirror dpid port_monitor port_mirror
```
このコマンドは
[lib/patch_panel.rb](lib/patch_panel.rb)
における`create_mirror`メソッドを呼び出し，下記の順で処理する．<br>
####１． `add_mirror_entry`メソッドを呼び出す．
フローテーブルにMirroringを実現するルールを追加する．
具体的なルールは，port_monitorが所属するパッチ`port_out`を`@patches`から取得し，`port_monitor`からのPacketInに対しては`port_out`および`port_mirror`へフォワーディングする．<br>
####２．`@mirrors`へミラーリングを記録する．
[lib/patch_panel.rb](lib/patch_panel.rb)
の`start`メソッドにおいてインスタンス変数`@mirrors`（ハッシュ）を宣言し，`@patches`
と同様に，`add_mirror_entry`メソッドによって実現したミラーをリスト構造として記録する．<br>

###② パッチとポートミラーリングの一覧
リンクID（`dpid`）先にあるスイッチにおけるパッチおよびミラーの一覧を表示する．
コマンドは下記の通りである．<br>
```
./bin/patch_panel dump dpid
```
このコマンドは
[lib/patch_panel.rb](lib/patch_panel.rb)
における`dump`メソッドを呼び出し，下記の順で処理する．<br>


##関連リンク
* [課題 (パッチパネルの機能拡張)](https://github.com/handai-trema/deck/blob/develop/week3/assignment_patch_panel.md)
* [bin/patch_panel](bin/patch_panel)
* [lib/patch_panel.rb](lib/patch_panel.rb)
