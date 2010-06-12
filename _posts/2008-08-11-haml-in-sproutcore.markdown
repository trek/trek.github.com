--- 
layout: post
title: Haml in SproutCore
---
Nerds never rest. Over the weekend I submitted a patch to add haml support to SproutCore with a few caveats. Almost immediately my new favorite aussie <a href='http://blog.lawrencepit.com/'>Lawrence Pit</a> addressed those caveats and the patch was rolled into SproutCore 0.9.15. (A patch for sass was also submitted... is the addition of <a href='http://github.com/jessesielaff/red/tree/master'>Red</a> far behind?)

If you're not coming from a Rails/Merb world haml likely slipped under your radar last year.  <a href="http://haml.hamptoncatlin.com/">Haml</a> is a template language that aims to simplify the markup in your views by removing the need to type a bunch of meaningless extra characters, exporting very pretty, nicely indented output, and make it much easier to mix code and markup (which is the whole point of templates of course).

In haml (X)HTML tags are created with the % literal followed by the tag name. So <code>%p</code> and <code>&lt;p&gt;&lt;/p&gt;</code> are equivalent when run through haml's parsing engine.  That may not seem like much, but beyond trivial examples haml can be much nicer to look at. Compare the rhtml and haml versions of the imaginary code below:

<code>
<pre>
  &lt;strong class=&#x27;&lt;%= object.some_method%&gt;&#x27; id=&#x27;&lt;%= object.class_name %&gt;&#x27;&gt;&lt;%= &#x27;Hello, World!&#x27;.translate %&gt;&lt;/strong&gt;
</pre>
</code>

<code>
<pre>
  %strong{:class =&gt; object.some_method, :id=&gt; object.class_name }= &#x27;Hello, World!&#x27;.translate
</pre>
</code>

With rhtml you can end up with some massive visual clutter (%&gt;&#x27;&gt;&lt;%=&#x27; - which I believe is also ironically the japanese emoticon for "my cross eyed mutant monster from chibi vampire HATES ugly markup") that Haml purposely avoids.

Haml is also highly intelligent and operates, like ruby, on the principle of least surprise.  What happens, for example, if <code>object.some_method</code> returns <code>nil</code>?  With rhtml you'll end up with markup like:

<code>
<pre>
  &lt;strong class=&#x27;&#x27; id=&#x27;message&#x27;&gt;Saluton al la tuta mondo!&lt;/strong&gt;
</pre>
</code>

An empty class isn't the end of the world, but it sure is pointless.  Haml will just ignore the entire class attribute when printing if it's value in <code>nil</code>

<code>
<pre>
  &lt;strong id=&#x27;message&#x27;&gt;Saluton al la tuta mondo!&lt;/strong&gt;
</pre>
</code>

Many libraries will create helpers to deal with interweaving a lot of markup and code.  SproutCore has it's TagHelper module (which appears to be nabbed from Rails) that solves the problem like this:
<code>
<pre>
  content_tag(:div, content_tag(:p, &quot;Hello world!&quot;), :class =&gt; &quot;strong&quot;)
</pre>
</code>

Using TagHelper your views end up as a mix of regular markup, markup interspersed with bits of &lt;%= code %&gt;, and areas where code is totally generating markup for you.  The fact that we need additional code sitting on top of our template language to make it easier to use is a signal that our template language doesn't <em>really</em> meet all our needs properly.

<h3>Other Niceties</h3>
In addition to making code betwixt markup less hideous, Haml also has some syntactic shortcuts for very common markup.  If your classes and ids aren't dynamic you don't need to use a hash to set them. Haml borrows syntax from CSS and lets you use . (dot) and # (hash) to represent the two most common element attributes you're likely to use.

<code>
<pre>
  %strong#message_22.trasnlated.message= 'Hello, World!'.translate
</pre>
</code>

<code>
<pre>
  &lt;strong id=&#x27;message_22&#x27; class=&#x27;trasnlated message&#x27;&gt;Saluton al la tuta mondo!&lt;/strong&gt;
</pre>
</code>

If you're using &lt;div&gt; for structural markup you can even leave off the %div part.  Here's <a href='http://microformats.org/wiki/adr'>adr</a>-ish example:

<code>
<pre>
  .adr
    .street-address= address.street
    .locality=       address.city
    .region=         address.state
    .postal-code=    address.zip
</pre>
</code>

<h3>A SproutCore example</h3>
For a fully fleshed out example I converted the picker view from the SproutCore photos sample app to haml.
Drum roll please:
<a href='http://github.com/sproutit/sproutcore-samples/tree/b48e7c99bb2b8170ef818653c31d0a8dc0478135%2Fclients%2Fphotos%2Fenglish.lproj%2Fpicker.rhtml?raw=true'>rhtml</a> vs <a href='http://github.com/trek/thoughtbox/tree/master%2Fhaml_in_sproutcore%2Fpicker.haml?raw=true'>haml</a>

<h3>Great! How do I use it?</h3>
Haml support is <del>isn't</del> in the SproutCore gem <del>just yet</del> so if you'd like to experiment with Haml there's a few things you'll need to do. First, you'll want to bone up on Haml a bit by going through the <a href='http://haml.hamptoncatlin.com/tutorial'>tutorial</a>. When you're feeling ready you can put the latest version of SproutCore in your application by updating to the latest gem with <code>gem install sproutcore</code> <del>placing it in your applications <code>/frameworks/sproutcore</code> folder:

<code>
  <pre>
    cd /path/to/your/application
    cd frameworks
    git clone git://github.com/sproutit/sproutcore.git
  </pre>
</code>

Restart your SproutCore application and it should be using the local version of SproutCore in <code>frameworks</code> instead of the version included in the gem.</del>

Inside your project's lproj folder either convert an existing .rhtml file to haml format and change its extension to .haml  or create a new .haml file.  You won't need to choose between rhtml and haml for a project; SproutCore will happily convert both appropriately to html and place them in your project.
