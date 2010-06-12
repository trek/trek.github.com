--- 
layout: post
title: link_to revisited
---
Observant folks pointed out that in my <a href='http://wonderfullyflawed.com/2008/06/02/ditch-your-helpless-helpers/'>post about helpers I&#x27;ve stopped using</a> that I skipped one crucial feature of link_to: RESTful deleting. A REST patterned application uses four HTTP verbs (POST, PUT, GET, DELETE).  Only POST and GET can be used reliably through a browser (although libraries like curl or ActiveResource can use all four), so support for the others is added by including a hidden parameter named &#x27;_method&#x27; that is POSTed through a form.  You&#x27;ll notice it if you view the source of an /edit/ page (since edit&#x27;s evil twin update lurks in the controller gobbling up PUT requests).

This is a decent solution for updating a resource because you&#x27;ll already be using a form and sending one extra hidden parameter is a small price to pay for a solid architecture pattern.  Deleting, however, is typically done with a link, not a form.  To get the a delete link with the link_to you supply an argument of :method =&gt; :delete and Rails handles the magic of making your delete link work.

Needing delete links means you have to use two methods for creating a link (assuming you buy my argument of haml&#x27;s built-in tag building being preferable) leading to code like the example below:
{% highlight erb%}
  %a{:href =&gt; post_url(@post)} read more
  %a{:href =&gt; edit_post_url(@post)} edit
  = link_to &#x27;remove post&#x27;, post_url(@post), :method =&gt; :delete
{% endhighlight  %}

I&#x27;m not entirely happy with view code like that, but it&#x27;s workable.  Let&#x27;s take a look at what this will output

{% highlight html %}
<a href='/posts/251'>read more</a>
<a href='/posts/251/edit'>edit</a>
<a href='/posts/251/' onclick='if (confirm("Are you sure?")) { var f = document.createElement("form");f.style.display = "none"; this.parentNode.appendChild(f); f.method = "POST"; f.action = this.href; var m = document.createElement("input"); m.setAttribute("type", "hidden"); m.setAttribute("name", "_method"); m.setAttribute("value", "delete"); f.appendChild(m);f.submit(); };return false'>remove post</a>
{% endhighlight  %}

Ick! link_to&#x27;s behind the scenes magic involves writing some javascript to the page. The javascript waits for clicks on the link, stops the click event, creates a new form in the DOM, adds it to the page (with display set to &#x27;none&#x27; so the user won&#x27;t see it) and POSTs a request along with the hidden attribute of _method set to the value &#x27;delete&#x27;.  This is just standard, browser agnostic javascript so it will work in any browser but has two flaws: It writes javascript directly to the page and will not work with javascript turned off.

I can ignore my preference for unobtrusive javascript to make my views a little prettier but I often can&#x27;t have a link that fails if javascript is off.  One solution to this problem is to flip the logic being used: instead of a link that acts like a form when javascript is on (but fails entirely when it&#x27;s off) you use a form that acts like a link when javascript is on, but remains a form when javascript is off.  The railscasts folks did a whole screencast about <a href='http://railscasts.com/episodes/77'>deleting sans javascript</a>using this method.

A drawback is that folks without javascript will see a delete button (a submit-type input) but seeing a button is better than not being able to delete at all.  Using the form-that-becomes-a-link tactic will net us view code like this

<code>
<pre>
  %a{:href =&gt; post_url(@post)} read more
  %a{:href =&gt; edit_post_url(@post)} edit
  = link_to_destroy &#x27;remove post&#x27;, post_path(@post), confirm_destroy_post_path(@post)
</pre>
</code>

Unfortunately link_to_destroy demonstrated in the screencast is really just a wrapper for a specific kind of call to link_to_function and will place inline javascript into your view.  Everyone can delete, but we have uglier views and uglier output. I consider this a step backwards: the goal should be pretty views, unobtrusive javascript for clean output, and graceful fallbacks that don&#x27;t require much hoop jumping.

<h4>Making reliable delete links</h4>
To make resource deleting work consistently there is no escaping the need for a form element.  Let&#x27;s whip up a basic helper that will create a button for deleting
<code>
<pre>
def link_to_delete(options = {})
  haml_tag :form, {:action =&gt; options[:href], :method =&gt; &#x27;post&#x27;, :class =&gt; &#x27;delete-form&#x27;} do
    haml_tag :input, {:type =&gt; &#x27;hidden&#x27;, :name =&gt; &#x27;_method&#x27;, :value =&gt; (options[:method] || :delete)}
    haml_tag :input, {:type =&gt; &#x27;hidden&#x27;, :name =&gt; &#x27;authenticity_token&#x27;, :value =&gt; form_authenticity_token}
    haml_tag :input, {:type =&gt; &#x27;submit&#x27;, :value =&gt; options[:value], :class =&gt; &#x27;delete-button&#x27;}
  end
end
</pre>
</code>

Used in the view, it looks like this
<code>
<pre>
  %a{:href =&gt; post_url(@post)} read more
  %a{:href =&gt; edit_post_url(@post)} edit
  = link_to_destroy(:href=&gt; post_path(@post), :value =&gt; &#x27;remove post&#x27;)
</pre>
</code>

and will the following html
<code>
<pre>
  &lt;a href=&quot;/posts/251&quot;&gt;read more&lt;/a&gt;
  &lt;a href=&quot;/posts/251/edit&quot;&gt;edit&lt;/a&gt;
  &lt;form action=&quot;posts/251&quot; method=&#x27;post&#x27; class=&#x27;delete-form&#x27;&gt;
    &lt;input type=&#x27;hidden&#x27; name=&#x27;_method&#x27; value=&#x27;delete&#x27; /&gt;
    &lt;input type=&#x27;hidden&#x27; name=&#x27;authenticity_token&#x27; value=&#x27;1c75f5e944f90f38&#x27; /&gt;
    &lt;input type=&#x27;submit&#x27; name=&#x27;submit&#x27; value=&#x27;remove post&#x27; class=&#x27;delete-button&#x27; /&gt;
  &lt;/form&gt;
</pre>
</code>

The view code in this situation isn&#x27;t great, but the html output is clean, compliant, and easy to understand.

<h4>Making delete links pretty</h4>
At this point every user will see a delete submit input.  We can use some unobtrusive javascript to give users with javascript turned on a more desirable experience. A tiny prototype-based class will hide the form, show a link instead, and make the click event on the link submit the form properly.
<code>
<pre>
var DeleteLink = Class.create({
  initialize: function(form) {
    form.hide();
    var submitButton = form.down(&#x27;input.delete-button&#x27;);
    var anchor = new Element(&#x27;a&#x27;, { &#x27;class&#x27;: &#x27;link-to-delete&#x27;, href: form.action }).update(submitButton.value);
    form.insert({after : anchor});
    anchor.observe(&#x27;click&#x27;, this.commitDeletion.bindAsEventListener(form));
  },
  commitDeletion: function(event) {
    event.stop();
    this.submit();
  }
});
</pre>
</code>

You can apply this behavior unobtrusively with prototype&#x27;s dom:loaded event.  I stick all my behavior adding javascript in application.js
<code>
<pre>
document.observe(&quot;dom:loaded&quot;, function() {
  $$(&#x27;.delete-form&#x27;).each(function(link)   { new DeleteLink(link)    });
});
</pre>
</code>

This looks for all items with the class of &#x27;delete-form&#x27; and creates a new DeleteLink object.  Now users with javascript on will see a link (that can be styled just like any link), folks without javascript will see a button, and everyone will be able to properly delete.

<h4>Gussy up the views</h4>
So far we&#x27;ve added unobtrusive javascript for clean output with graceful fallbacks.  The last task is to make the views a little nicer to look at.  This requires just a dab of aesthetics and no additional code.  Recall that our views with deleting look like this right now.
<code>
<pre>
  %a{:href =&gt; post_url(@post)} read more
  %a{:href =&gt; edit_post_url(@post)} edit
  = link_to_destroy(:href =&gt; post_path(@post), :value =&gt; &#x27;remove post&#x27;)
</pre>
</code>

The link_to_destroy method stands our just like link_to did, but since we needed to write our own helper anyway (to get the unobtrusive and reliable functionality) we can go ahead and name this helper method something that fits in more pleasantly. Ideally we&#x27;d be able to have a view like this:

<code>
<pre>
  %a{:href =&gt; post_url(@post)} read more
  %a{:href =&gt; edit_post_url(@post)} edit
  %a{:href =&gt;post_path(@post), :method =&gt; :delete} remove post
</pre>
</code>

but that will just write method=&#x27;delete&#x27; directly into the HTML anchor tag (which is meaningless). I decided to name the helper &#x27;a&#x27; and set the value of the button/link with an argument

<code>
<pre>
  %a{:href=&gt; post_url(@post)} read more
  %a{:href=&gt; edit_post_url(@post)} edit
  =a({:href=&gt;post_path(@post), :method =&gt; :delete, :value =&gt; &#x27;remove post&#x27;})
</pre>
</code>

Haml already uses some special characters to denote specific behavior in an HTML tag (compare %input and ~input) making the use of = fit into the the general structure of haml documents decently well. I wasn&#x27;t able to get it to work sans curly braces but I&#x27;m happy with how well it fits in surrounded by other &quot;regular&quot; anchor tags.
