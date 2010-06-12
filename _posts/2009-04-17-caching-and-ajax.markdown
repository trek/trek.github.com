--- 
layout: post
title: Caching and AJAX
---
<p>I recently launched <a href="http://rqst.me">rqst.me</a>, a url shortener service as an excuse to play with <a href="http://heroku.com">Heroku</a>, <a href="http://apiwiki.twitter.com/">Twitter&#8217;s API</a>, and <a href="http://oauth.net/">OAuth</a>.  Three cheers all around for a great afternoon and some amazing products!  Taking a break from my current project, I&#8217;m adding some <a href="http://guides.rubyonrails.org/caching_with_rails.html">caching</a> to be a kind Heroku citizen and need to work around the fact that <a href="http://code.google.com/p/twitter-api/issues/detail?id=242&amp;colspec=ID%20Stars%20Type%20Status%20Priority%20Owner%20Summary%20Opened%20Milestone">twitter avatars don&#8217;t have a static url</a>.  If I cache a page with some HTML in it like this: </p>

<pre><code>&lt;img src='http://s3.amazonaws.com/twitter_production/profile_images/60358524/n2203865_44697472_3398_normal.jpg'&gt;
</code></pre>

<p>That image will <code>404</code> as soon as the user changes their avatar.  Twitter wants you to make a public API request each time to get the current image. Obviously, if this happens at the server level I can&#8217;t use page caching.  I&#8217;m getting around this limitation it by delivering the following html to the page instead</p>

<pre><code>&lt;img alt="twitter user:1291711" class="tw-avatar" height="48" src="/images/default_profile_bigger.png" width="48"&gt;
</code></pre>

<p>where <code>default_profile_bigger.png</code> is a local copy of twitter&#8217;s default avatar.  I&#8217;m then using a little jquery to make an API request (using JSONP) and replacing the <code>src</code> attribute with the current image</p>

<pre><code>$(document).ready(function(){
  var avatar = $('.tw-avatar');
  var twitterId = avatar.attr('alt').split(':')[1]
  $.getJSON('http://www.twitter.com/users/show/'+ twitterId + '.json?callback=?', {},
        function(data){
          avatar.attr('src', data.profile_image_url)
        }
  )
});
</code></pre>
