---
title: Format Parsing in Javascript
byline: Trek
layout: post
excerpt: '<p><a href="http://github.com/jessesielaff/Riff">Riff</a> is a a recent spin-off project from <a href="http://github.com/jessesielaff/">Jesse Sielaff</a>&#8217;s work to bring a Ruby-like language interpreter to the browser.  Riff is a plugin for <a href="http://i.loveruby.net/en/projects/racc/">Racc</a> (a <a href="http://en.wikipedia.org/wiki/LALR_parser">LARL(1) parser generator</a> for Ruby).  Riff extends the output generation portions of Racc and writes javascript instead of Ruby.  If you&#8217;re familiar with LALR grammars this should add a handy tool to your javascript arsenal...</p>'

---
<p><a href="http://github.com/jessesielaff/Riff">Riff</a> is a a recent spin-off project from <a href="http://github.com/jessesielaff/">Jesse Sielaff</a>&#8217;s work to bring a Ruby-like language interpreter to the browser.  Riff is a plugin for <a href="http://i.loveruby.net/en/projects/racc/">Racc</a> (a <a href="http://en.wikipedia.org/wiki/LALR_parser">LARL(1) parser generator</a> for Ruby).  Riff extends the output generation portions of Racc and writes javascript instead of Ruby.  If you&#8217;re familiar with LALR grammars this should add a handy tool to your javascript arsenal.</p>

<p>Jesse&#8217;s been using Riff in his latest stab at Red, but we were eager to throw it at a smaller text format and see how it compared to a solid hand-written parser.  We took a weekend and paired on rewriting <a href="http://github.com/janl">Jan Lehnardt</a>&#8217;s <a href="http://github.com/janl/mustache.js">javascript implementation</a> of <a href="http://github.com/defunkt">Chris Wanstrath</a>&#8217;s <a href="http://mustache.github.com/">mustache template language</a>.</p>

<p>Our <code>mustache.js</code> has three little differences from Jan&#8217;s (we wanted to keep as close to Chris&#8217; Ruby/Python mustache implementations as possible):</p>

<ul>
<li>no explicit iterator <code>{{ '{{' | escape }}.}}</code> (use <code>{{ '{{' | escape }} toString }}</code>)</li>
<li>partial context is stored in Mustache.partials instead of passed as an argument. You can switch this context to a different object when you need to.</li>
<li>we have <code>Mustache.render(template, object)</code> instead of <code>Mustache.to_html(template, object, partials, callback)</code></li>
</ul>

<p>Other than those, the two parsers are roughly identical in functionality but quite distinct in implementation. Jan&#8217;s <code>mustache.js</code> is a handwritten parser, our&#8217;s is generated from <code>Riff</code> and <code>Racc</code>.</p>

<p>A generated parser is broken up into two main parts: grammar definition and semantic action.  Take a look at <a href="http://github.com/jessesielaff/mustache.js/blob/b8977508546067e97a9be2d13033332da902f032/compile/mustache.grammar">Mustache&#8217;s grammar</a>.  The first part defines the grammar of the language (it&#8217;s pretty small), from which a finite state machine is generated.  The part of the grammar enclosed in <code>{</code> and <code>}</code> defines the semantic rule conversion (e.g. what to do when a token is found).</p>

<p>For example, <a href="http://github.com/jessesielaff/mustache.js/blob/b8977508546067e97a9be2d13033332da902f032/compile/mustache.grammar#L13">line 13</a> of our grammar looks like this:</p>

<pre><code>"{{ '{{' | escape }}{" "text" "}}}"  { $$ = Array(4, $2); }
</code></pre>

<p>This means when you find <code>{{{</code> followed by a &#8220;text&#8221; token, followed by <code>}}}</code>, create a new <code>Array</code> object with <code>4</code> (which is the arbitrary code number we gave to &#8220;escaped text&#8221; nodes) as the first element and the string value of the &#8220;text&#8221; node as the second element.  What you choose to do in your parser depends how you&#8217;d like to handle evaluation. You might create javascript literals, use a jquery class, etc. We&#8217;ve opted to create a tree of nodes using <code>Array</code> objects in javascript, but a different solution might have been:</p>

<pre><code>"{{ '{{' | escape }}{" "text" "}}}"  { $$ = { node_type:'unescaped-text', content: $2 } }
</code></pre>

<p>The grammar file is run through <code>Riff</code> and <a href="http://github.com/jessesielaff/mustache.js/blob/b8977508546067e97a9be2d13033332da902f032/mustache.js">converted to generated parser</a>. Everything up to <a href="/blob/b8977508546067e97a9be2d13033332da902f032/">line 214</a> is generated, the remainder is copied over from the <code>---- footer</code> section of the grammar file.</p>

<p>Initially the footer for <code>Mustache</code> contained every function necessary to parse, evaluate, and render a mustache formatted file.  Jesse later separated this into two separate sections – a parser and an evaluator – and the end results are pretty awesome (big reveal later, I promise).</p>

<p>Starting on line 214, we have two major functions of <code>Mustache</code>: <code>compile</code> and <code>next_token</code>. <code>compile</code> sets up a state for parsing and calls <code>do_parse</code> (which is generated by <code>Riff</code> from the grammar, not written by the programmer). <code>next_token</code> is called from inside <code>do_parse</code> and walks through the input string character by character, searching for semantically meaningful elements (e.g. <code>{{ '{{' | escape }}#something}}</code>).</p>

<p>This part can be a little dense if you&#8217;re unfamiliar with look-ahead parsing. If you can&#8217;t visualize the pointer moving through a string, see the <a href="http://github.com/jessesielaff/mustache.js/blob/StringScanner/mustache.js#L256">StringScanner branch</a>, where Jesse uses <a href="http://github.com/jessesielaff/StringScanner.js">his javascript port of Ruby&#8217;s string scanner class</a> and regular expressions to manipulate the string pointer.</p>

<p>So, this code gets you a tree of Array objects. The <a href="http://github.com/jessesielaff/mustache.js/blob/b8977508546067e97a9be2d13033332da902f032/mustache.evaluator.js">evaluator part</a> of the library takes this tree and renders it into a string with the appropriate values inserted.  The main mojo in the evaluator is the <code>render</code> function. This is the only function you&#8217;ll call in <em>your</em> code with <code>Mustache.render(template, object)</code>.  The evaluator is organized into one function for semantic type (e.g. <code>evaluate_inverse_block_node</code> for <code>{{ '{{' | escape }}^foo}}</code> inverse blocks)</p>

<p>Internally, <code>render</code> checks the type of template object you passed in. Up until now, we&#8217;ve talked about templates only as strings in mustache format. If you pass in a <code>String</code> template, it runs through <code>Mustache.compile</code> and comes out the other end as the series of <code>Array</code>s mentioned above, is evaluated, and finally is converted back into a <code>String</code> with data inserted in appropriate locations.</p>

<p>Now, imagine we could <em>start</em> with a series of <code>Array</code>s and skip the parsing stage.  Obviously, nobody wants to develop their templates like this:</p>

<pre><code>[0,[0,[0,[0,[0,[0,[0,[0,'&lt;img src="',[3,'src']],'" width="'],[3,'width']],'" height="'],[3,'height']],'" alt="'],[3,'name']],'"&gt;']
</code></pre>

<p>we want to write templates like this:</p>

<pre><code>&lt;img src="{{ '{{' | escape }}src}}" width="{{ '{{' | escape }}width}}" height="{{ '{{' | escape }}height}}" alt="{{ '{{' | escape }}name}}"&gt;
</code></pre>

<p>In production, of course, the computer doesn&#8217;t care what your templates look like. If you&#8217;re working with javascript on the server, you can pre-compile your templates with <code>Mustache.compile</code>. Jesse also whipped up an <a href="http://github.com/jessesielaff/mustache.js/blob/b8977508546067e97a9be2d13033332da902f032/mustache">example pre-compiler</a> for mustache in Ruby in case you have different server needs.</p>

<p>This let&#8217;s us a use <code>mustache.js</code>, <code>mustache.evaluator.js</code>, and <code>String</code> templates while developing and move to <em>just</em> <code>mustache.evaluator.js</code> (which is a tiny, tiny file) and compiled templates when we&#8217;re ready to move into production and want a speed-boost.</p>

<h2 id="how8217d_riff_do">How&#8217;d Riff do?</h2>

<p>Not bad for a weekend pairing project. We went from nothing to a spec&#8217;ed, running format parser in two afternoons.  Adjusting for comments and code style (Jesse is more liberal with his white space around curly braces), there&#8217;s 20% fewer lines of code over the handwritten parser. Run through a javascript minifier (Dean Edward&#8217;s in this example), Jan&#8217;s parser is 8,747 bytes, Jesse&#8217;s 6,292 bytes, and in production, you can get by with just the evaluator at 2,244 bytes.</p>

<p>Organizationally, I prefer separating out language definition, parsing, and evaluation. I personally find it reads more easily than putting everything in a single structure. Plus, it gives us the benefit of using compiled templates.</p>

<p>Speedwise, Jan&#8217;s <code>Mustache</code> ranges from identical up to 5x faster (depending the example), averaging 1.5x faster than ours. But as <a href="http://twitter.com/janl/status/15443198351">Jan kindly noted</a> code size and simplicity are probably more important than incremental speed gains. Plus, if you&#8217;re desperate for cycles, using compiled templates is 5x faster (3x faster than Jan&#8217;s).</p>

<p>Here are the <a href="http://github.com/trek/mustache-speed-shootout">speed test</a> results (run in Firefox, on my last-gen Macbook):</p>

<p><table>
    <thead>
      <tr>
        <th>template</th>
        <th>janl</th>
        <th>jesse</th>
        <th>jesse compiled</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <th>basic</th>
        <td>476ms</td>
        <td>1326ms</td>
        <td>152ms</td>
      </tr>
      <tr>
        <th>complex</th>
        <td>1668ms</td>
        <td>1558ms</td>
        <td>510ms</td>
      </tr>
      <tr>
        <th>friend</th>
        <td>465ms</td>
        <td>830ms</td>
        <td>150ms</td>
      </tr>
      <tr>
        <th>long</th>
        <td>448ms</td>
        <td>1007ms</td>
        <td>188ms</td>
      </tr>
      <tr>
        <th>looping</th>
        <td>711ms</td>
        <td>741ms</td>
        <td>167ms</td>
      </tr>
      <tr>
        <th>partial</th>
        <td>1912ms</td>
        <td>3271ms</td>
        <td>577ms</td>
      </tr>
      <tr>
        <td></td>
        <td>5680</td>
        <td>8733</td>
        <td>1744</td>
      </tr>
    </tbody>
  </table></p>

<p>If you find yourself hand-parsing text in javascript, give Riff a try. We think you&#8217;ll like it.</p>
