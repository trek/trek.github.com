--- 
layout: post
title: Javascript ousted from Rails views
---
I've been warning people for a time now that Rails' javascript helpers (you know, those helpers that write inline javascript directly into your view) wouldn't make the cut long beyond Rails 2.2.  The we less-than-three unobtrusive javascript folks have griping about them for years.

The topic just came up again on the Rails <a href='http://groups.google.com/group/rubyonrails-core/browse_thread/thread/955027d8b2a067a9#'>core mailing list</a>

<blockquote>"Rails should never really generate any JS for these helpers. Just
decorate them with the proper class names/attributes. Then every JS
library can write a driver that'll look for these Rails specific clues
and wire them up." - DHH</blockquote>

So, if you're using helpers like this, start working them out. I've talked before about <a href='http://wonderfullyflawed.com/2008/06/02/ditch-your-helpless-helpers/'>ditching trivial helpers</a> and <a href='http://wonderfullyflawed.com/2008/06/03/link_to-revisited/'>patterns to make helpers work sans inline javascript</a>
