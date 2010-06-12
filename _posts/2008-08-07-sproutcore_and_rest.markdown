--- 
layout: post
title: SprouteCore &amp; REST
---
SproutCore, the javascript-based user interaction library, got a few important updates last week.  These changes were prompted by some good discussion about a better use of REST for server interaction. SproutCore is pretty server-agnostic: you can use an server-side technology as a data persistence layer - as long as it can send and receive json and conforms to some basic url formatting.  Unfortunately, the urls it used relied heavily on extra slugs to tell your application where to send requests.

Charles, the lead on the project readily admitted that the server interaction bits of SproutCore were written before he understood REST very well and before the REST revolution that happened in frameworks like Rails a year or so ago.

A recent commit changes all of that and, thanks to changes informed by various folks on the SproutCore google group but coded mostly by Lawrence Pit, SproutCore fits uses REST quite nicely.

The two big changes are

1) server.js has been subclassed with rest_server.js so you can now choose the original style of server interaction, or one that relies more on HTTP verbs and less on url format

in your project's core.js

old style
server: SC.Server.create({ prefix: ['Contacts'] })
new style
server: SC.RestServer.create({ prefix: ['Contacts'] })

tons of comments (by Lawrence) are included in the class as well:
http://github.com/sproutit/sproutcore/tree/1c9e13792c8f4097866eee4b661e2fe3a739346d/foundation/rest_server.js

these two classes have also been placed in their own directory.

2) A contribution by me has SproutCore sending custom HTTP header data of 'X-SproutCore-Version' : '1.0' identifying itself.  You can now have your backend application check for the presence of that header and respond specifically to SC requests (i.e. a special response if your general json responses are not formatted for properly SproutCore)

SproutCore still does a few things with server interaction that vary slightly from Rails.  I'll be wrapping these in a plugin extracted from a current application soon.
