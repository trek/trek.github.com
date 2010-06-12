--- 
layout: post
title: Javascript makes me see Red
---
<hr />


Update: Red is now a full Ruby runtime in the browser. <a href='http://wonderfullyflawed.com/2008/10/13/red-40-a-full-ruby-runtime-in-your-browser/'>Read all about it</a>


<hr />

I'm a major fan of Hampton Catlin's haml and sass ruby libraries.  Although their syntax isn't specifically ruby, I find it much more ruby-like in its sparseness. Moving from writing ruby in models, controllers, and libraries to a HTML/ruby mix in ERB always was a sufficient context change to frustrate me just slightly each time. With haml and sass I always feel like I'm humming along at full speed.

Then, it comes time to work in javascript.  The analogy we often use is running through a mud field in the middle of a marathon.  I never feel like I write javascript so much as a slog my way through it.  Now, don't get me wrong, I like javascript.  I like javascript even more now that the usage pattern has changed towards more unobtrusive enhancement of an application.  But moving from these elegant .rb, .sass, and .haml to a visually busy .js file is always a shock to the system; there's all these extra characters that just don't mean anything to me as a human.

Just to prove that Canadians don't have a monopoly on coolness, check out Jesse Sielaff's <a href="http://github.com/jessesielaff/red/wikis">Red library</a>.  Red is like sass for javascript files.  Rather than writing in pure javascript you write in equivalent ruby syntax and Red will convert your code to javascript either at request time (in development mode) or will cache the .js file (in production).

The simple example of
<code>
<pre>
  class Foo
   def initialize(foo)
     @foo = foo
   end
  end
</pre>
</code>

will compile to
<code>
<pre>
  var Foo = function(foo) { this.foo = foo; }
</pre>
</code>

That might not convince you to move to Red, but try comparing more complicated Red files in ruby syntax with their equivalent javascript files and, trust me, you'll be a convert in no time.

Like many newly released libraries, documentation is sparse but improving.  Of course, it will improve even faster when you switch over and start editing the projects wiki yourself. You can keep up with all the hotness in the various usual places: <a href="http://github.com/jessesielaff/red/">github code</a> and <a href="http://github.com/jessesielaff/red/wikis">wiki</a>, <a href="http://jessesielaff.lighthouseapp.com/projects/15182-red/">lighthouse</a>, and <a href="http://groups.google.com/group/ruby-red-js">google groups</a>.  Red's gone through several revisions privately (it's up to version 3.1) and Jesse's one of the smartest people I've ever run across so except Red to be pretty robust despite it's limited public exposure.
