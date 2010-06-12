--- 
layout: post
title: Javascript relative dates
---
I'm in the middle of working on a small Rails app (mostly as a playground for the google maps API) and  wanted to get those lovely relative dates that are so common these days. They're easy to do (<a href="http://api.rubyonrails.com/classes/ActionView/Helpers/DateHelper.html#M001006">distance_of_time_in_words</a>) and I think they provide a bit of polish over showing some strftime'd date stamp.  Additionally, relative times are timezone neutral (which happens to be important for what I'm working on).

One drawback to relative times is the added baggage when using Rails caching.  "1 minute ago" is only valid if you plan on expiring your caches every minute (yuck!).
<a title="Twitter by thetrek, on Flickr" href="http://www.flickr.com/photos/thetrek/2496921067/"><img src="http://farm3.static.flickr.com/2035/2496921067_677dbed9a9_o.jpg" alt="Twitter" width="540" height="58" /></a>

Well, I want to have my cake and eat it too!

Of the trifecta of web technologies (HTML, CSS, JS) HTML has already failed to provide the ability I need. My content needs to remain static for scaling reasons.  This isn't really a problem of style either and that leaves only one alternative: Javascript.

<h3>new Date()</h3>
At first I thought I'd need to do some expert regexp'ing on Time#to_s, turn that into a hash of some sort and pass that data as json into a Javascript to parse the date. It turns out that the constructor for Date in javascript can take a string and automatically parse it into a happy object.  Give it a shot in firebug:
<code>new Date('Fri May 16 14:29:24 UTC 2008');</code>

should snag you a fancy

<code>Fri May 16 2008 10:29:24 GMT-0400 (EDT)</code>
or something similar (since javascript automatically shows the output in your timezone).  That, in my opinion, is pretty nice.  Javascript will automatically create Date objects from the default time format in my views. Beautiful.

Now to turn them into relative dates.  I checked the code in the Rails API first to see if there was any fancy magic going on behind the scenes. Turns out like most time and date related code there is just a bunch of division by standard time units.  Ruby thinks of time in units of 'seconds', javascript uses milliseconds, but the math is pretty much same-same.

Shamelessly using the stolen math, I wrapped it all in a tiny Prototype-based class. You can see that class in <a href='http://github.com/trek/thoughtbox/tree/master/js_relative_dates/src/relative_date.js'>my github</a>.

In my application's main javascript file (where I stuff all my class loading)

<code>
document.observe("dom:loaded", function() {
  $$('.relative_date').each(function(date) { new RelativeDate(date) });
});
</code>

That will, once the dom is loaded on a page, find anything with the class of 'relative_date' (feel free to insert use whatever class name you prefer, obviously) and create a new RelativeDate object.

In my views I have
<code>%span.relative_date= @lodging.created_at</code>
Which outputs plain old html of
<code>&lt;span class=&quot;relative_dates&quot;&gt;Fri May 16 14:30:41 UTC 2008&lt;/span&gt;</code>
Which javascript remakes to
<code>&lt;span class=&quot;relative_date&quot;&gt;about 4 hours&lt;/span&gt;</code>
Now I can cache wherever it makes sense to and still maintain relative dates.
