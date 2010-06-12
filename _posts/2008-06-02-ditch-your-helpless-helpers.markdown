--- 
layout: post
title: Ditch Your Helpless Helpers
---
Going through my last few projects I&#x27;ve noticed a personal trend of avoiding certain built-in helpers.  Some were conscious decisions (I prefer writing javascript in javascript, not in ruby) other just fell into place based on how I architect my applications, certain libraries I use (especially haml), and a desire to have the code I stare at all day be beautiful and evidently clear.

Helpers are supposed to be little balls of view code that help (ha!) keep your views nice and clean and mostly logic free.  Model objects, created in the controller, should flow into your views with very few twists or turns and those parts of the view that require logic should live in a helper.

Helpers that aren&#x27;t abstracting reusable logic aren&#x27;t really helping your views at all. One helper I &lt;em&gt;never&lt;/em&gt; use anymore is link_to. Before Rails became so heavily tied to the REST pattern link_to used to be more valuable to me because it combined provided :controller, :action, and :id arguments into a url.
<code>
  &lt;%= link_to @post.title, :controller =&gt; &#x27;posts&#x27;, :action =&gt; &#x27;show&#x27;, :id =&gt; @post, :class =&gt; &#x27;recent&#x27; %&gt;
</code>
would compile to
<code>
  &lt;a href=&#x27;http://mycoolapp.com/posts/show/251&#x27; class=&#x27;recent&#x27;&gt;My awesome lolcat&lt;/a&gt;
</code>
and was clearly preferable to rolling the same anchor pattern again and again using ERB
<code>
  &lt;a href=&#x27;http://mycoolapp.com/posts/show/&lt;%= @post.id %&gt;&#x27; class=&#x27;recent&#x27;&gt;&lt;%= @post.title %&gt;&lt;/a&gt;
</code>
with all the nested angle brackets it&#x27;s bit hard to read, doesn&#x27;t take advantages of routes, and would be a nightmare to maintain properly.

But now I use a combination of the REST pattern and named routes to compartmentalize url generation logic making my link_tos look like this
<code>
  &lt;%= link_to @post.title, post_url(@post), :class =&gt; &#x27;recent&#x27; %&gt;
</code>
instead of a long hand version
<code>
  &lt;a href=&#x27;&lt;%= post_url(@post) %&gt;&#x27; class=&#x27;recent&#x27;&gt;&lt;%= @post.title %&gt;&lt;/a&gt;
</code>
The link_to helper is still better than two erb evaluation tags but if you happen to use haml (and I do) compare the link_to and pure haml versions below
<code>
  = link_to @post.title, post_url(@post), :class =&gt; &#x27;recent&#x27;
</code>
compared to
<code>
  %a{:href =&gt; post_url(@post), :class=&gt; &#x27;recent&#x27;}= @post.title
</code>

They&#x27;re pretty similar in length and complexity. Since link_to only generates a single HTML element, which is really a job for haml, I tend to prefer the pure haml version.

<h4>Javascript</h4>
Another set of helpers I haven&#x27;t used in about a year ar the prototype, script.aculo.us, and rjs related helpers.  I used to love these little guys for bringing quick and easy ajax and effects to Rails applications.  I still think they&#x27;re perfect if you need the tiniest bit of javascript, don&#x27;t have the time or inclination to learn prototype directly, and don&#x27;t mind just sticking to the functionality they provide out of the box.

Previous projects led me down the path of learning javascript better (through prototype) and I&#x27;ve been heavily influenced by the unobtrusive javascript folks to strongly dislike inline javascript. These two events have contributed to my js-related helper usage dropping to nil.

I&#x27;ve come to appreciate that flexibility this really adds to a project.  When we need some more javascript expertise we can bring a js pro doesn&#x27;t need to know Rails at all.  If we decide to switch out prototype for dojo or mootools very easily. When the javascript goes awry you know how the problem is in a .js file and not secreted away in some controller or view. When we send our HTML off to a designer he doesn&#x27;t need to slog through dozens of lines of weird looking code just pretty (and if you&#x27;re using haml, wonderfully indented) HTML.

So, if you&#x27;re wondering what to put as a goal for your next performance evaluation try beefing up your skills with prototype (or dojo, mootools, YUI, et al) directly.  For those thinking prototype, I highly recommend the <a href='http://www.pragprog.com/titles/cppsu/prototype-and-script-aculo-us'>Pragmatic Programmers&#x27; Prototype and Scriptaculous book</a>.

A final note: I&#x27;m not advocating removing these helpers from Rails. If you&#x27;re looking for super-light, only-does-what-I-want framework check our <a href='http://merbivore.com/'>Merb</a>. I&#x27;m sure that different people&#x27;s style of organizing an application will use different parts of Rails more heavily than others. If there are helpers you&#x27;ve never used (or have stopped using), let me know. I&#x27;d be interested to see what other people do.
