#Report: patch-panel
Submission: &nbsp; Oct./20/2016<br>
Branch: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; develop<br>






##提出者
<B>辻　健太</B><br>
33E16012<br>
長谷川研究室 所属<br>



##コマンドの追加方法



##追加したコマンド（ボーナス点あり）
以下２つのコマンドを追加した．

###１．ポートのミラーリング
<p>コントローラとスイッチ間のリンクID（dpid）先にあるスイッチにおいて，port_monitorから入ってくるパケットをport_monitorへミラーリングする．
コマンドは下記の通りである．</p>
```
./bin mirror dpid port_monitor port_mirror
```
<p></p>



##関連リンク
* [bin/patch_panel](bin/patch_panel)
* [lib/patch_panel.rb](lib/patch_panel.rb)
