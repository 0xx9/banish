<p align="center">
  <a href="../../README.md"><img alt="English" src="https://img.shields.io/badge/English-3A3A3C?style=for-the-badge"></a>
  <a href="./ar.md"><img alt="Arabic" src="https://img.shields.io/badge/%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-3A3A3C?style=for-the-badge"></a>
  <a href="./es.md"><img alt="Spanish" src="https://img.shields.io/badge/Espa%C3%B1ol-3A3A3C?style=for-the-badge"></a>
  <a href="./fr.md"><img alt="French" src="https://img.shields.io/badge/Fran%C3%A7ais-3A3A3C?style=for-the-badge"></a>
  <a href="./de.md"><img alt="German" src="https://img.shields.io/badge/Deutsch-3A3A3C?style=for-the-badge"></a>
  <a href="./pt.md"><img alt="Portuguese" src="https://img.shields.io/badge/Portugu%C3%AAs-3A3A3C?style=for-the-badge"></a>
  <a href="./tr.md"><img alt="Turkish" src="https://img.shields.io/badge/T%C3%BCrk%C3%A7e-3A3A3C?style=for-the-badge"></a>
  <a href="./zh.md"><img alt="Chinese" src="https://img.shields.io/badge/%E4%B8%AD%E6%96%87-3A3A3C?style=for-the-badge"></a>
  <a href="./ja.md"><img alt="Japanese" src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-0A84FF?style=for-the-badge"></a>
  <a href="./ko.md"><img alt="Korean" src="https://img.shields.io/badge/%ED%95%9C%EA%B5%AD%EC%96%B4-3A3A3C?style=for-the-badge"></a>
</p>

# Banish

**アプリと、その後に残ったもの全部。**

アプリをゴミ箱へドラッグしても、消えるのはアイコンだけです。環境設定、キャッシュ、コンテナ、ログ、ログイン項目はライブラリに残ります。容量を使い続け、再インストールすると戻ってきます。

Banish はそれらのファイルを見つけ、何も動かす前に見せ、選んだものだけをゴミ箱へ送ります。どれも元に戻せます。完全には削除しません。

<p><img src="../images/library.png" alt="Banish に並ぶインストール済みアプリ" width="920"></p>

## 画面に出るもの

サイドバーには、バージョンとサイズ付きでインストール済みアプリが並びます。緑の点は起動中です。検索は名前か、`com.google.Chrome` のようなバンドル ID を受け付けます。

選ぶと三つの数字が出ます。アプリ本体のサイズ、関連ファイルのサイズ、そして実際に選択されてゴミ箱へ行くもののサイズです。

**関連ファイル**はバンドル ID で一致し、最初から選択されています。**名前の一致**は名前が同じだけなので、パスを確認するまで選択されません。

<p><img src="../images/detail.png" alt="Banish で開いた Chrome と関連ファイル" width="920"></p>

## 確認するまで何も動かない

**Move to Trash** は件数とサイズの確認シートを開きます。移動ボタンはデフォルトボタンではないので、Return で誤って確定しません。

`/Applications` のアプリは macOS のもので、普通の移動は拒否されます。シートには、パスワードが必要になる場合があると出ます。確認したあと macOS が一度だけ聞き、Banish が選択した項目をゴミ箱へ移します。

<p><img src="../images/confirm.png" alt="Chrome をゴミ箱へ移す前の確認" width="920"></p>

パスワードのダイアログを取り消すと、移動は止まります。動いていないものは元の場所に残ります。ゴミ箱に入ったものは戻せます。

## 探す場所

Banish はディスク全体を走査しません。既知のライブラリフォルダを、一つか二つの階層だけ見ます。環境設定、Application Support、キャッシュ、ログ、コンテナ、ID が一致するときの Web データ、ログイン項目、保存された状態です。

強い一致はバンドル ID を使います。`com.foo.app` は `com.foo.application` も `com.foo.app2` も集めません。`Google/Chrome` は Chrome のものになり得ます。`Google/Earth` は、単語が一つ同じというだけではなりません。

## 触らないもの

`/System`、`/usr`、`/bin`、`/private` などのシステムの場所。書類、デスクトップ、ダウンロード、写真、音楽。メール、メッセージ、写真、Safari、キーチェーン、カレンダー、メモ。`~/.ssh` と、削除元としてのゴミ箱そのもの。シンボリックリンク。そして実行中の Banish。アプリは自分自身を移動できません。

Finder、Safari、Mail のような中核の Apple アプリはロックされたままです。Keynote、Pages、Numbers のような任意の Apple アプリは、明確な警告つきで外せます。システムアプリは最初は隠れていて、表示メニューか設定から出せます。

## 権限

**管理者パスワード**が聞かれるのは、macOS がアプリケーションフォルダからアプリを出すのを拒んだときだけです。ダイアログはシステムのもので、名前は Banish です。

**フルディスクアクセス**は任意です。macOS が隠しているコンテナとキャッシュを読むためのものです。なくても一覧は動き、読めないフォルダがあるとバナーが出ます。

システム設定 → プライバシーとセキュリティ → フルディスクアクセス

## アプリ内の言語

ウィンドウは Mac の言語に従います。アラビア語は右から左です。設定でアラビア語か英語に固定できます。

<p><img src="../images/settings.png" alt="Banish の設定" width="540"></p>

## ビルド

macOS 14 以降と Swift 6。外部ライブラリはありません。

```bash
./Scripts/build-app.sh
open build/Banish.app
```

または `make app` のあと `make run`。テストは `make test` です。署名済みアプリは `build/Banish.app` にできます。
