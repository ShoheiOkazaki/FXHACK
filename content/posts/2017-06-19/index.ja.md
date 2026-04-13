---
title: "Kill Houdini"
date: 2017-06-19T11:00:53+09:00
tags: ["Houdini", "Linux", "Bash"]
draft: false
---


今回の話は、Linuxユーザのためだけですので、あしからず。

なにか間違った値を入れてしまったりして、メモリが右肩上がりに上昇し、メモリをフルに使いきり、パソコンが動かなくなるということは、時々あるでしょう。会社のマシンは128GBですが、まれになります。
そんなときは、 CUIモードで対処したり、同僚のマシンから操作してもらったり、泣く泣く電源を落としたりと、みなさんもこんな経験はたくさんあるでしょう。
残念ながら、いろいろセーブしてなくて、「ごめんなさい」を連呼しながらEscを連打しても、ダメなときはダメです。

そうなる前に、問題のプロセスを強制的に終了させましょう。
というわけで、今回はBashを調べてみました。基本Linuxで仕事してますが、Bashやコマンドは避けてきたので、何か間違ってる点や、もっといい方法がありましたら教えてください。

---

### プロセス一覧から探しだして、kill

まずは、ベーシック。
プロセスを表示するコマンドはps。
みなさんは、どういうオプション使っているかはわかりませんが、自分はいつもこれ

``` sh
ps aux
```

端末内外のプロセスを表示して、CPUとメモリの使用量も表示させる。

さらに、Houdiniのプロセスだけを表示させる

```Shell
ps aux | grep houdini-bin
```


表示された結果から、見つけた対象のプロセスIDを殺す。

```Shell
kill -SEGV 123456 
```


このSEGVは、ホント助かりますよね。Windowsにはないらしいですが、可哀想に。

これで、プロセスが死に、$houdini_tmpのなかに、シーンファイルが、保存される。まっ、たまに保存が失敗することがありますが。


さて、ここまでは普通の手順。もう少し、賢くやってみましょう。


## すべてのHoudiniプロセスを、kill

まずは、今あるHoudiniのプロセスすべてをKillします。

```Shell
kill -SEGV `ps aux | grep [h]oudini-bin | tr -s ' ' | cut -d ' ' -f 2`
```


houdini-binは、houdiniの立ち上げ方によって、名前変わるので、各自変えてください。ちなみにhoudini-bin はターミナルで、houdini_sourceをセットし、houdiniとタイプし起動したら、そうなります。
なので、それらを考慮するなら、複数指定しときましょう

```Shell
grep -e [h]oudini-bin -e [h]indie-bin
```
 []を使う理由は、プロセスにgrep自身が表示されないようにするためです。

```Shell
ps aux | grep [h]oudini-bin 
```

実行すると、こんな感じのものが返ってくると思います。
`shohei    9042  4.7  1.5 5985364 2067844 ?     Ssl  10:54  11:17 /opt/hfs16.0/bin/houdini-bin
shohei   24231  0.4  0.4 1385564 544956 ?      Ssl  Jun05  11:00 /opt/hfs16.0/bin/houdini-bin`
分かりづらいかもしれせんが、連続したスペースがあります。これだと不便です。

そこで、これ。
```Shell
tr -s ' '
```
 -sは、同じ連続した文字を1文字に置き換えるオプションです。

```Shell
ps aux | grep [h]oudini-bin | tr -s ' '
```

これを付け加えて実行すると、
`shohei 9042 4.7 1.5 5985364 2067844 ? Ssl 10:54 11:16 /opt/hfs16.0/bin/houdini-bin
shohei 24231 0.4 0.4 1385564 544956 ? Ssl Jun05 11:00 /opt/hfs16.0/bin/houdini-bin`
綺麗になりました。

さらに、左から2番めにあるのがプロセスIDですので、これだけを取り出します。

```Shell
cut -d ' ' -f2
```

-dが区切り文字の指定で-fが抽出する番号です。pythonでいう、split(' ')[2]ですね。

```Shell
grep [h]oudini-bin | tr -s ' ' | cut -d ' ' -f 2
```
9042
24231

この返ってきた番号すべてをkillします。



1番メモリくってるHoudiniを、kill
全部のHoudiniはkillしたくないけど、一番メモリを食ってるやつのみをkillしたい

```Shell
kill -SEGV `ps aux --sort -vsize | grep [h]oudini-bin | tr -s ' ' | cut -d ' ' -f 2| sed -n 1p`
```

まずメモリ使用量が大きい順に、ソートする。
```Shell
ps aux --sort -vsize
```


また、プロセスIDだけ取り出す。そしたら、一番最初のIDだけにする。
```Shell
sed -n 1p
```
あとは、まえのと一緒です。
ちなみに、1番目から3番目にメモリを食ってるのを対象にするには、この部分をこうします。
```Shell
sed -n 1,3p
```


コマンドとして登録
しかし、メモリを急激に食い始めたやつを止めるには、悠長にこんな長いコマンドを打ってる時間は、残されてません。
コマンドに登録して、さらにスマートにしてみましょう。

まず、全部をkillするコマンドを作ってみます。以下のコードをファイルとして
`/usr/local/bin`に保存します。名前はkillhoudiniallとしときます。

```Shell
#!/bin/sh
kill -SEGV `ps aux | grep [h]oudini-bin | tr -s ' ' | cut -d ' ' -f 2`
```

ファイルのパーミッションで、プログラムとして実行可能にしときましょう。


最後に、メモリを食ってる順番から消すようにするコマンドを作ります。コマンド名はkillhoudiniとします。
```Shell
#!/bin/sh
BASECOMMAND="ps aux --sort -vsize | grep [h]oudini-bin | tr -s ' ' | cut -d ' ' -f2 | sed -n"

if [ $# -ne 2 ]; then
 if  expr "$1" : '[0-9]*' > /dev/null
 then 
  kill -SEGV `eval ${BASECOMMAND} $1p`
  exit 1
 else
  echo "error: Not a number"
 fi

elif [ $# -ne 3 ]; then
 if  expr "$1" : '[0-9]*' > /dev/null && expr "$2" : '[0-9]*' > /dev/null
 then 
  kill -SEGV `eval ${BASECOMMAND} $1,$2p`
  exit 1
 else
  echo "error: Not a number"
 fi

else
 echo "error: Not support"
 exit 1
fi 
```

要点だけ説明すると、引数が2つの時のみ実行するために
```Shell
$# -ne 2
```
変数が整数か否かのチェック
```Shell
if  expr "$1" : '[0-9]*' > /dev/null
```

これで、”killhoudini 1”とやれば、1番メモリ食ってるのをkill。”killhoudini 2 4”とすれば、2番目から4番目にメモリを食ってるのをkillします。



余談ですけど、Autodesk系を抹殺するには
rm -rf /opt/Autodesk*
ですね。(*´ω｀*)


---
今の時代、勉強しなくてもネット見れば、誰でも簡単なコードはすぐかける。いい時代だけど、できないなんていう戯言は一切通用しない時代。