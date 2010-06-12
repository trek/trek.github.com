--- 
layout: post
title: Red 4.0 - A Full Ruby Runtime in Your Browser
---
A few months ago <a href="http://wonderfullyflawed.com/2008/08/07/javascript-makes-me-see-red/">I wrote</a> about <a href="http://github.com/jessesielaff/">Jesse Sielaff’s</a> Red Library. <a href="http://github.com/jessesielaff/red">Red</a> started life as a simple Ruby to Javascript transliterator. Ruby syntax in, Javascript syntax out.  <a href="http://ajaxian.com/archives/prefer-ruby-syntax-see-red-and-your-ruby-will-convert-to-js">Ajaxian picked it up</a> (taking me from 20 daily readers to 2000 daily readers - thanks Ajaxian!) and garnered Red a lot of attention and feedback.  Feedback, as anyone who has released something publicly will know, is a vicious, doubled-edged sword. Positive feedback is great, because it bolsters the spirit. Critical feedback is better because it points out all the things you missed or ignored and drives you to improve. Negative feedback is a courage sapping demon.
<h3>Positive Feedback</h3>
Positive feedback about Red came from folks having the same problems we were: switching context to Javascript from Ruby was costing us development time.  It’s not that we’re not as capable in Javascript as we are in Ruby, but it was like having a conversation in French and Spanish at once.  There’s a reason a group of multinationals will converse in a common language: you get into a groove, old words and patterns come back to you. You <em>flow</em>.  Moving between Ruby to Javascript, we missed that flow.
<h3>Negative Feedback</h3>
Negative feedback about Red came from people who really like Javascript and fell into one of three categories:
<ul>
	<li>Javascript is an amazing language and will one day be the end-to-end web solution (<a href="http://incubator.apache.org/couchdb/">CouchBD</a>, <a href="http://www.aptana.com/blog/khakman/jaxer10rc">server-side js</a>, and client js)</li>
	<li>Javascript is an amazing language and anyone who doesn’t want to learn javascript should just stay away from it</li>
	<li>Yuck! Ruby. If I have to use Ruby, I’d just as soon use Javascript! Why not do this in language X, which is better suited because…</li>
</ul>
To the first, I say: you might be right. Javascript has a major advantage of being (likely) the most installed programming language in history.  It’s experiencing a renaissance lately where people actually learning it, not just copying code found on someone’s website. ECMAScript Harmony will bring some much needed fixes to the language (although I think ECMAScript 4 would have been a true game-changer for the web).  Regardless, until we have more mature tools for sever- and DB-side javascript, Javascript is really a browser language (and faces an army of entrenched programmers who’d rather use some other language).

To the second argument, I say: Javascript <em>is</em> an amazing language, but you can’t declare it off limits to people who prefer other languages.  Programming is about choice.  On the server we get to use whatever combinations of web server, database, programming language, and development environment we like. Not so for the browser. We’re stuck with Javascript whether we like it or not. We can’t stay away from it, we can’t use something else.  Everyone who dislikes working in Javascript is perfectly justified because he has no other avenue. When all browsers support and are prepackaged with VMs for many languages, I’ll be the first to sound the clarion: if you don’t like JS, get the hell away from it. Until then, you’re stuck with us and we’re stuck with you.

To the third: again, it’s <em>really</em> all about to choice. If you prefer Javascript keep using it, make it better, steal ideas from other languages, and seed the community with new ideas of your own. Nobody will complain about a better overall development community. If you’d like to see Red in Python, PHP, C#, or language X then steal Jesse’s code.  Red was a herculean effort on Jesse’s part. I know he’s worked on nothing else for two months and future ports of Red to other languages will benefit from this effort.
<h3>Critical Feedback</h3>
There was one main vein of critical feedback about Red: it was a fucking tease.  You use Red and you <em>almost</em> feel like you’re programming Ruby.  Look, blocks! No semicolons or curly braces! The class keyword!  Below the surface, though, it was the same old Javascript.  There were gaping holes where expected, much-loved methods used to be. Existing methods returned different values than in ruby. Heck, even a concept as simple as Truth behaved differently.

The newly announced <a href="http://groups.google.com/group/ruby-red-js/browse_thread/thread/e955a46716803d0f">Red 4.0</a> addresses these issues.  Red is now a full Ruby runtime<sup><a name="back_one" href="#one">1</a></sup> in the browser with access to all the expected language features and idiomatic expressions. I started typing some examples, but, really, it was just Ruby code.

Here’s the Rdoc for it <a href="http://red-js.rubyforge.org/red/rdoc/">http://red-js.rubyforge.org/red/rdoc/</a>. You’ll fine pretty much all of Ruby there.  Really. No, really.

Much of Red 4.0 is written in native javascript (so you don’t have to!) and Jesse’s avoided using Red’s Ruby methods inside other methods so the new built-in optimizer can aggressively remove methods you aren’t using. The result is fast and potentially small library to support your own Ruby code.

There <em>are</em> some items missing: browser-related classes.  Because Ruby hasn’t run in the browser environment before there were no classes like <code>Browser</code>, <code>Element</code>, <code>Document</code>, <code>Style</code>, <code>Request::Ajax</code>, or <code>Cookie</code>, to port.  While Jesse’s been working on Red, I’ve been evaluating existing cross-browser Javascript libraries to <del>port</del>steal.

Currently we’re leaning towards <a href="http://mootools.net/">MooTools</a> because it’s organized in a way I’d expect a Ruby port to be and includes the feature we want in a single core library.  We’d appreciate feedback on other libraries (and not just ‘use X because it’s the one <em>I</em> like’. <em>Why</em> do you think it would be a better library to copy).  We’re naming this library <em>Redbull</em> (especially if we borrow from MooTools. Ha! get it? Cows.) or <em>Redact</em> (look it up, it’s pretty much a perfect name).

How fast can we port browser classes? Well, pretty fast. As a test I ported most of a library in three days. We’re talking about copying code and wrapping it in a Ruby interface for use - there’s not a ton of problem solving thanks to the open source community.

There are other places that Red could be useful for replacing Javascript; <a href="http://github.com/paulcarey/relaxdb/tree/master">RelaxDB</a> and <a href="http://github.com/jchris/couchrest/tree/master">CouchRest</a> come to mind. I don’t use these in active development so I’ll leave it for more involved folks to start those gears if desired. (I’m highly intrigued by CouchDB and recommend the <a href="http://peepcode.com/products/couchdb-with-rails">Peepcode on it</a>, even if you don't use Ruby. It will answer many lingering questions.)

<a name="one" href="#back_one">1.</a> there are a few esoteric parts of ruby that behave differently or are not included. They happen to be parts of the language we absolutely have not used or seen in the wild. If you need them, please file a bug report. Red also lacks some core Ruby classes that don’t make sense in the browser because of browser limitations. For example, classes like Dir and File don’t won't work in an environment that can’t access file systems.

<h3>Update</h3>
We've ended up on <a href='http://digg.com/programming/Red_A_Full_Javascript_powered_Ruby_Runtime_for_the_Browser'>digg</a> and <a href='http://www.reddit.com/r/ruby/comments/76wif/red_40_a_full_ruby_runtime_in_your_browser/'>reddit</a>. Go vote!
