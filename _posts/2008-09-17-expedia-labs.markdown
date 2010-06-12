--- 
layout: post
title: Expedia Labs
---
I went to a presentation by Expedia with <a href='http://blog.chrishanrath.com/'>Chris Hanrath</a> today.  One of the topics covered was what Expedia is doing that is experimental. Expedia, like Google, now has a Labs division to play around with interesting ways of evolving their core business: <a href='http://labs.expedia.com/'>http://labs.expedia.com/</a>

Seeing their <a href='http://labs.expedia.com/flight/'>Flights app</a> I said to Chris - who interned at Yahoo this summer - "that is clearly YUI." Nerds that we are, we both viewed source simultaneously.  Sure enough, Expedia is using YUI for their labs.  Their static resources all have a timestamp parameter attached which is usually a good hint (though not proof) that the document was created in Rails. A little more searching turns up the HTML comment   &lt;!-- here is the Rails &#x27;default&#x27; block of JS --&gt;

Very cool!
