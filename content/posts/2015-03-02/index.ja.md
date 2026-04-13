---
title: "Wrangleを使おう 2.5"
date: 2015-03-02T02:53:32+09:00
tags: ["Houdini", "Wrangle", "SOP", "101"]
draft: false
---

一個書き忘れてたことがあったので、さらっと。

[数学定数](http://ja.wikipedia.org/wiki/%E6%95%B0%E5%AD%A6%E5%AE%9A%E6%95%B0)、円周率(π)・自然対数の底(e)・黄金比(φ/τ)とか、時々使うけど漠然としか値を覚えていない奴らがいます。正確な値を知るために毎回、調べるのは億劫です。

例えば、Wrangleで初めに#include <math.h>と書けば、以降このノード内ではM_PIが3.1415926の値を持っていることになります。

```c {linenos=false}	
#include <math.h>

f@_check = M_PI;
```

なにが起こっているかというと、$HH/vex/includeにmath.hというファイルがあります。そのファイルの中で、定義されたものを読み込んでいます。この他にもあるので中を見てみてください。

このファイルは自分で作ることもできます。例えば黄金比を呼び出したい場合。

```c {linenos=false}
#define PHI 1.61803
````
これを、HOUDINI_PATHに設定している場所のvex/includeに.h形式で保存するか、HOUDINI_VEX_PATHに登録しているところに保存すれば、これ以降、読み込むことができます。
```c {linenos=false}
#include <test.h>
f@_check = PHI;
```

決められたところに保存しなくても、test.hのところを/home/user/test.hとパスを入れても呼び出すこともできます。
