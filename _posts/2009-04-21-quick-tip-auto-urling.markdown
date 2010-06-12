--- 
layout: post
title: "Quick Tip: Auto-urling"
---
<p>If you&#8217;d like to add auto urling (including links to <a href="http://www.twitter.com/trek">@trek</a>-style twitter accounts) to an html element try:</p>

{% highlight javascript %}
// status area
var status = $('.tweet .status');
// add hrefs to twitter accounts and links
if (status.length) {
  status.html(status.html().replace(/(https?:\/\/[\w\d\.\/]+\b)/g, "<a href='$1'><a>"));
  status.html(status.html().replace(/@(\b[\w\d]+\b)/g, "<a href='http://www.twitter.com/$1'>@$1</a>"));
}
{% endhighlight %}
