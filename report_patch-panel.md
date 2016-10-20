#Report: patch-panel
Submission: &nbsp; Oct./20/2016<br>
Branch: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; develop<br>






##提出者
<B>辻　健太</B><br>
33E16012<br>
長谷川研究室 所属<br>



##コマンドの追加方法



##追加したコマンド（ボーナス点対象）
以下３つのコマンドを追加した．

###１．ポートのミラーリング
<p>コントローラとスイッチ間のリンクID（dpid）先にあるスイッチにおいて，port_monitorから入ってくるパケットをport_monitorへミラーリングする．
コマンドは下記の通りである．</p>
```
./bin/patch_panel mirror dpid port_monitor port_mirror
```
このコマンドは
[lib/patch_panel.rb](lib/patch_panel.rb)
における`create_mirror`メソッドを呼び出し，下記の順で処理する．
1. `add_mirror_entry`メソッドを呼び出す．
<p>フローテーブルにMirroringを実現するルールを追加する．
このとき，</p>



##関連リンク
* [課題 (パッチパネルの機能拡張)](https://github.com/handai-trema/deck/blob/develop/week3/assignment_patch_panel.md)
* [bin/patch_panel](bin/patch_panel)
* [lib/patch_panel.rb](lib/patch_panel.rb)
