--- 
layout: post
title: Clearfix as mixin
---
Clearfixing (<a href="http://www.positioniseverything.net/easyclearing.html">some</a> <a href="http://www.sitepoint.com/blogs/2005/02/26/simple-clearing-of-floats/">additional</a> <a href='http://perishablepress.com/press/2008/02/05/lessons-learned-concerning-the-clearfix-css-hack/'>info</a>) has become a pretty standard tool in the CSS toolbox web developers use to get happy semantic webpages out to the world.  What's always bothered me about this strategy are the two ways that you implement it.

The first method is to go around adding classes to HTML elements that need the clearing ability added; everywhere you find that the height of a containing element isn't what you'd expect because of floating dab a little `class='clearfix'` (or `.clearfix` for us haml lovers) and voila, problem solved. Semantic purists will be vomiting into their mouthes a bit right now, but this isn't such a bad strategy.  Its one drawback is keeping track of everywhere you put the class looks suspiciously like work (and work is something I try to avoid if possible).

The second method is to keep updating the css declaration to include the new elements you'd like the fix applied to.  So, if you started out with

{% highlight css %}
.clearfix:after {
content: ".";
display: block;
height: 0;
clear: both;
visibility: hidden;
}
.clearfix {display: inline-block;}
{% endhighlight %}

and need to make the div #my-cool-contents also properly contain its floated elements you'd alter your css to
{% highlight css %}
.clearfix:after, #my-cool-contents:after {
content: ".";
display: block;
height: 0;
clear: both;
visibility: hidden;
}
.clearfix, #my-cool-contents {display: inline-block;}
{% endhighlight %}

and now anything with the class `.clearfix` <em>or</em> the id of my-cool-contents will clearfix itself.  Before the semantic purists rejoice I have to mention: this can be a headache to maintain.  Imagine a situation where three or four developers are all adding elements that need clearing and you can quickly end up with css declarations with dozens of rules kept in a separate location from the other rules for those elements.  I've found this strategy to be even more work than the first.

It's just not pragmatic to trade semantic purism for more difficulty maintaining your css files.

<h3>Enter the sass mixin</h3>
A recent edge version of haml/sass includes the oft-requested ability to keep what are being called 'mixins' available for use in many places.  If you're not familiar with haml or sass do yourself a favor and <a href='http://haml.hamptoncatlin.com/tutorial'>read the tutorial</a>, <a href="http://lab.hamptoncatlin.com/">play with them online</a>, and then <a href='http://haml.hamptoncatlin.com/download/'>install them on your development box</a>.

Mixins (in sass) are freestanding css rules <em>not</em> attached to any particular declaration.  Sass normally looks like this:
<pre><code>
#my-div
  :border   1px solid black
  :width     300px
  :margin   10px
</code></pre>

where css directives are specifically attached to an element with the id of my-div and complies into this:
{% highlight css%}
#my-div {
  border: 1px solid black;
  width: 300px;
  margin: 10px;
}
{% endhighlight %}


But, edge versions of sass will let you have bits free standing bit of css that an not attached to any declaration (and don't print until they are attached).  You create them with the '=' character:


<pre><code>
=message-box
  :padding 15px
  :border=  3px solid !layout_highlight_color
</code></pre>

This snippet of sass can be attached to any sass declaration with the '+' character.

<pre><code>
.warning
  :width 100%
  +message-box

</code></pre>

will compile to
<pre><code>
.warning {
  width: 100%
  padding: 15px;
  border: 3px solid #fafafa
}
</code></pre>

<h3>Putting it all together</h3>
You can combine the sass mixin with repeatable css strategies (like clearfix) to get some pretty clean, semantic, and maintainable html and css.

Here is clearfix rendered as a sass mixin (note: you'll need a recent version of haml checked out from git and <code>rake install</code>ed)

<pre>
<code>
=clearfix
  *display:                 inline-block
  &amp;:after
    content:                " "
    display:                block
    height:                 0
    clear:                  both
    visibility:             hidden
</code>
</pre>

You can apply it anywhere in your sass that needs some clearfixing:

<pre>
<code>
.images
  :width 44%
  +clearfix

#main-article
  :width 25%
  :float left
  +clearfix
</code>
</pre>

<h3>Snag it</h3>
I keep clearfix (as both a class and mixin) sass file up in my git repo.  Feel free to use and abuse it
<a href="http://github.com/trek/thoughtbox/tree/master/clearfix_sass/clearfix.sass">clearfix.sass</a>
