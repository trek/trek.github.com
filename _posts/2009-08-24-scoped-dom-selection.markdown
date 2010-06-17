--- 
layout: post
title: Scoped DOM Selection
excerpt: "<p>While Jesse operates on the next version of Red, his never-quite-ready Ruby runtime built on top of Javascript, I&#8217;ve been playing with RedShift, our Ruby DOM manipulation library by exploring Ruby idioms that would make common tasks more elegant.</p><p>We already have a <a href='http://red-js.rubyforge.org/red/rdoc/classes/Document.html#M000657'><code>ready?</code> method</a> on the <code>Document</code> class that is called when the DOM has been parsed and is ready.  It&#8217;s the equivalent of jQuery&#8217;s <code>$(document).ready(fn)</code>, Prototype&#8217;s <code>document.observe('dom:loaded', fn)</code>, and MooTools&#8217; <code>window.addEvent('domready', fn)</code> functions.</p>"

---
<p>While Jesse operates on the next version of Red, his never-quite-ready Ruby runtime built on top of Javascript, I&#8217;ve been playing with RedShift, our Ruby DOM manipulation library by exploring Ruby idioms that would make common tasks more elegant.</p>

<p>We already have a <a href="http://red-js.rubyforge.org/red/rdoc/classes/Document.html#M000657"><code>ready?</code> method</a> on the <code>Document</code> class that is called when the DOM has been parsed and is ready.  It&#8217;s the equivalent of jQuery&#8217;s <code>$(document).ready(fn)</code>, Prototype&#8217;s <code>document.observe("dom:loaded", fn)</code>, and MooTools&#8217; <code>window.addEvent('domready', fn)</code> functions.</p>

<p>I was playing with this concept of meta-events and had the idea of using them for scoping code based on selectors. When you combine all your javascript into a single file to <a href="http://developer.yahoo.com/performance/rules.html#minify">reduce the number of HTTP requests for a page</a>, you need a nice way of trigger certain behavior only for a subset of pages.  I usually have a few <code>class</code>es and <code>id</code>s attached to the <code>body</code> tag of any page:</p>

{% highlight html %}
<body id='show' class='people admin-viewing'>
{% endhighlight %}

<p>This presence of these identifiers will trigger a subset of all possible document behavior. To replacing many <code>if</code> statements I extended our <a href="http://red-js.rubyforge.org/red/rdoc/classes/Document.html#M000652">DOM-selection method</a> to encapsulate this behavior in an optional block.</p>

{% highlight ruby %}
Document['#show.people'] do
end
{% endhighlight %}

<p>Although succinct, this fails aesthetically because it doesn&#8217;t obviously announce what the hell the block is for. I moved the block behavior to a specific <code>found?</code> method to mirror the syntax of <code>Document.ready?</code> as a kind of meta-event:</p>

{% highlight ruby %}
Document['#show.people'].found? do
  # code here only takes place if the selector is found
  Document['#show.people']['a'].add_class('whatever')
end
{% endhighlight %}

<p>Missing from <em>this</em> example was the ability to do sub-selects from within the block (which gives a nice speed boost and reduces duplication). I updated it to take a block argument.</p>

{% highlight ruby %}
Document['div#navigation'].found? do |page_nav|
  # find all the links inside the navigation div
  page_nav['a'].add_class('whatever')
end
{% endhighlight %}

<p>I&#8217;m eager to try pattern on existing projects, so I <a href="http://gist.github.com/174395">extended jQuery</a> to accomplish the same goals:</p>

{% highlight javascript %}
$('div#navigation').found(function(){
  // only execute if the selector finds elements
  this; // is the jQuery object of $('div#navigation')
});
{% endhighlight %}
