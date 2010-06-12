--- 
layout: post
title: "Quick Tip: Centering Hover Divs"
---
Imagine you'd like to have a tool-tip style div hovering over an element:
<img class="aligncenter size-full wp-image-208" title="non-centered" src="http://localhost/~trek/wordpress/wp-content/uploads/2009/04/non-centered.gif" alt="non-centered" width="170" height="94" />

but you'd like the two divs to be aligned at the center like so:
<img class="aligncenter size-full wp-image-209" title="centered" src="http://wonderfullyflawed.files.wordpress.com/2009/04/centered.gif" alt="centered" width="170" height="94" />

You can determine the correct value of div #1's left position  with some math:

<code>
<pre>centerDivs = function(a,b) {
  var w1 = parseInt(a.outerWidth()), w2 = parseInt(b.outerWidth()), l1 = parseInt(a.position().left);
  return l1 - ((w1 - w2)/2);
}</pre>
</code>

then offset the top div

<code> </code>

<code>
<pre>hintDiv.css({
  'zIndex'   : 1,
  'position' : 'absolute',
  'top'      : infoDiv.position().top - 45,
  'left'     : centerDivs(infoDiv, hintDiv)
})
Add a callout triangle to taste.</pre>
</code>
