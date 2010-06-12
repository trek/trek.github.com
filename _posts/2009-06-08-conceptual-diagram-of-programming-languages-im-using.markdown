--- 
layout: post
title: Conceptual Diagram of Programming Languages I&#039;m Using
---
There's a current discussion going on twitter between me, <a href='http://twitter.com/swolchok'>@swolchok</a>, and a few others about my inability (after 9 months of daily use) to really understand a central design aesthetic to the Python language. This has mostly to do with how action happens in the language.

Sometimes you have a method call on an object (<code>obj.method()</code>), sometimes it's a global function with an object an as an argument (<code>func(obj)</code>), sometimes it's a module function with an object as an argument (<code>module.func(obj)</code>), sometimes it's a constructor with objects as arguments (<code>MyClass(arg1, arg2)</code>), sometimes it's special syntax like list comprehension (<code>[3*x for [1,2,3] in vec if x &gt; 3]</code>).

That describes the <em>how</em>, which I'm fine with, but I've never gotten a clear picture of <em>why</em>. Constructors and comprehension have a special place in the language (although they <em>could</em> cover the same concept in a unified way), but between global functions, module function, and methods of objects I've never understood clearly when to use each and why.

I think, as a non-programmer, I just have a preference for symbolic reasoning syntaxes with smaller concept space: I prefer the combination of patterns to solve a problem over the creation of new patterns. I made a snarky little diagram to express this:
[caption id="" align="alignnone" width="467" caption="erlang, ruby, python"]<a href='http://img.skitch.com/20090608-nci16tkjsw9tr9bypgss4y4sce.jpg'><img alt="erlang, ruby, python" src="http://img.skitch.com/20090608-nci16tkjsw9tr9bypgss4y4sce.jpg" title="erlang, ruby, python" width="467" height="125" /></a>[/caption]

This doesn't mean I don't like Python (I do). I'd just like it more if I could understand it cohesively; and <a href='http://zedshaw.com/blog/2009-05-29.html'>I'm not the only one</a>.
