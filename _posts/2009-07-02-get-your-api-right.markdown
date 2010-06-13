--- 
layout: post
title: Get Your API Right
---
<p>Every project I&#8217;ve worked on in the last two years has heavily involved the use of web APIs. <a href="http://www.libersy.com">Libersy</a> at the time (no idea about now) had an architecture that was extensively API based, even for communication between internal applications (an architecture I <em>strongly</em> argued against, bee tea dubs).  Since then I&#8217;ve futzed with web APIs almost exclusively. From very narrow focused uses like University of Michigan&#8217;s <a href="http://bluestream.dc.umich.edu/">Bluestream Service</a>, to more broad but still fairly local APIs like the <a href="http://www.aadl.org/">Ann Arbor District Library&#8217;s</a> soon-to-be-updated API, all the way to APIs of major web applications like Twitter and Flickr.</p>

<p>Constant exposure has turned me into a bit of a snob: I can&#8217;t stand working with a poorly designed API!  If you&#8217;re about to design or release an API for the web and want to avoid the ire of your developers, I&#8217;ve summed up the best (and worst) of what I&#8217;ve seen into 8 rules:</p>

<h2>1) Use HTTP</h2>

<p>I&#8217;ll grant that HTTP isn&#8217;t perfect but it&#8217;s at least well understood and nearly universal. Nobody is going to want to write against your custom application layer atop UDP. Nobody cares about the RPC system you built in 1997 that is &#8220;running just fine.&#8221;  Unless you have some major reasons HTTP cannot work and are willing to provide solid client libraries in a dozen or more languages, stick with HTTP.</p>

<h2>2) Use Your Verbs</h2>

<p>Every HTTP request comes with a verb. These verbs have <a href="http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html"><em>specific</em> meaning</a> and should be used correctly.  Use <code>GET</code> to retrieve items, <code>POST</code> to add new items to your service, <code>PUT</code> to update existing items, <code>DELETE</code> to remove items, and <code>HEAD</code> for uses similar to <code>GET</code> where the programmer doesn&#8217;t need body content (e.g. cache checking).</p>

<p>If you&#8217;re concerned that not all client libraries implement the HTTP verbs (web browsers, for example, can&#8217;t submit <code>PUT</code> and <code>DELETE</code> requests) allow for HTTP verb faking. The emerging convention is passing a <code>_method</code> parameter as part of the request body with the verb as a lowercase value (<code>put</code>,<code>delete</code>, and <code>head</code>).</p>

<p>If you don&#8217;t use all the verbs, you won&#8217;t be able to give your users access to all possible actions on your data without resorting to specialty urls.  It&#8217;s possible to create an API that uses <em>only</em> <code>POST</code> requests:</p>

<pre><code>POST /photos/create
POST /photos/show/decafbebad
POST /photos/update/decafbebad
POST /photos/delete/decafbebad
</code></pre>

<p>By doing this you&#8217;re encoding the intended action directly in the url; this is needlessly redundant. HTTP already gives to a slot for specifying action (the verb). Just use it:</p>

<pre><code>POST   /photos
GET    /photos/decafbebad
PUT    /photos/decafbebad
DELETE /photos/decafbebad
</code></pre>

<p>Twitter&#8217;s API tries to have it both ways with <a href="http://apiwiki.twitter.com/Twitter-REST-API-Method%3A-favorites%C2%A0destroy">destroying favorites</a>. You can use either <code>POST</code> or <code>DELETE</code> as your software allows. To support client libraries that can&#8217;t <code>DELETE</code>, the deletion is additionally referenced in the URI (http://twitter.com/favorites/destroy/<em>id</em>.format).</p>

<p><a href="http://www.flickr.com/services/api/request.rest.html">Flickr only uses <code>GET</code> and <code>POST</code></a> necessitating specialty urls.</p>

<p>If you&#8217;re not allowing clients to create new data, or update/delete existing data on your system then <em>you do not have an API</em>. You have a feed. There&#8217;s nothing wrong providing read-only access to your data (it&#8217;s laudable, in fact), but I&#8217;m often disappointed to hear &#8220;Yeah! We have an API&#8221; only to find the person <em>really</em> meant they offered a number of customizable data feeds as <code>XML</code>.</p>

<p>The current <a href="http://www.blyberg.net/downloads/patrest_1.3_overview.pdf">Ann Arbor Library API</a> is really a data feed.</p>

<p><a href="http://api.shopify.com/">Shopify&#8217;s API</a> gets it right.</p>

<h2>3) Keep Your URL/URIs Consistent</h2>

<p>One of the most important principles of  <a href="http://en.wikipedia.org/wiki/Representational_State_Transfer">REST</a> (which is quickly becoming the preferred method of organizing web APIs) is &#8220;every resource is uniquely addressable using Uniform Resource Identifiers&#8221;.  In addition to making this URI unique, it&#8217;s important to make them patterned and consistent. </p>

<p>The Bluestream API, for example, uses the following four URIs to create a resource, retrieve a resource, find items related to that resource, and see the resource&#8217;s history of edits.</p>

<pre><code>POST /ams/upload
GET  /ams/rest/asset/A1001001A06B17B43948J49293
GET  /ams/rest/related/A1001001A06B17B43948J49293
GET  /ams/rest/history/A1001001A06B17B43948J49293
</code></pre>

<p>Two problems with the URIs above. First, the URI for creating new assets is wildly different than the other URIs. You&#8217;re better off sticking with a pattern: <code>POST /ams/rest/asset/</code>.  </p>

<p>Second, the collection of assets related to <code>A1001001A06B17B43948J49293</code> is conceptually a sub-asset.  Typically you&#8217;ll see the collection nested within the full URI of its conceptual parent: <code>/ams/rest/asset/A1001001A06B17B43948J49293/related</code>.  Same goes for the history of edits: <code>/ams/rest/asset/A1001001A06B17B43948J49293/history</code>.</p>

<p>Most data hierarchies will be fairly flat like <a href="http://apiwiki.twitter.com/Twitter-API-Documentation">Twitter&#8217;s</a> so you frequently won&#8217;t need to expose urls with deeply nested data relationships. But if you do, many client libraries are designed to interact with REST APIs that follow a patterned URI scheme.</p>

<p>The pattern of <a href="http://apidoc.digg.com/ListStories">Digg&#8217;s data feeds</a> is easy to understand. You barely need any more documentation than a sentence for the urls of each type. Sadly, you can&#8217;t get data <em>in</em> using these urls but &#8220;<a href="http://blog.digg.com/?p=817">endpoints for participating</a>&#8221; are coming soon.</p>

<h2>4) Use Your Status Codes</h2>

<p>Every HTTP response comes back with a status code. Like HTTP request verbs, these responses statuses <a href="http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html">have specific meaning</a>. Use them correctly!  Many API providers send back only two codes: <code>200</code> for requests that worked and <code>500</code> for requests that didn&#8217;t work.</p>

<p>I once snapped this shot while using the Ann Arbor District Library&#8217;s current API:</p>

<p><img src="http://img.skitch.com/20090702-np5p4utqx1w1w6199hfikegysm.jpg" alt="'no no'" width='647' height='547'></p>

<p>Sending back <code>200 OK</code> when you mean <code>404 Not Found</code> is decidedly <em>not OK.</em> </p>

<p>So, when someone <code>PUT</code>s to a URI that only accepts <code>GET</code> and <code>POST</code> send back a <code>405 Method Not Allowed</code>. When someone attempts to access data without authenticating, send back <code>401 Unauthorized</code>.  Most client libraries will convert these status into native errors/exceptions keeping the amount of body parsing required (I got back data with <code>200 OK</code>, but was it a &#8220;<code>200 OK</code> here&#8217;s what you wanted&#8221; or a &#8220;<code>200 OK</code> shit is <em>not ok</em>?&#8221;)</p>

<h2>5) Expose (And Accept) Multiple Data Formats</h2>

<p>You should both expose data and accept incoming data in at least <code>XML</code> and  <code>json/jsonp</code>.  These two data formats represent the standard data serializations of the web. The format of these should allow for nested, related data. There is some variance in how this data should be formatted, but there is an emerging pattern</p>

<p>For XML:</p>

<h3>Enclose a data type in an element of it&#8217;s name, not as bare data</h3>

<p>Do this</p>

<pre><code>&lt;?xml version="1.0"?&gt;
&lt;person&gt;
  &lt;name&gt;...&lt;/name&gt;
  &lt;age&gt;...&lt;/age&gt;
&lt;/person&gt;
</code></pre>

<p>not this</p>

<pre><code>&lt;?xml version="1.0"?&gt;
&lt;name&gt;...&lt;/name&gt;
&lt;age&gt;...&lt;/age&gt;
</code></pre>

<h3>Enclose a collection in a tag of its type, pluralized. Each item should be in an element of its type</h3>

<p>Do this</p>

<pre><code>&lt;?xml version="1.0"?&gt;
&lt;dogs&gt;
  &lt;dog&gt;
    &lt;name&gt;...&lt;/name&gt;
  &lt;/dog&gt;
  &lt;dog&gt;
    &lt;name&gt;...&lt;/name&gt;
  &lt;/dog&gt;
&lt;/dogs&gt;
</code></pre>

<p>not this</p>

<pre><code>&lt;?xml version="1.0"?&gt;
&lt;dog&gt;
  &lt;name&gt;...&lt;/name&gt;
&lt;/dog&gt;
&lt;dog&gt;
  &lt;name&gt;...&lt;/name&gt;
&lt;/dog&gt;
</code></pre>

<p>Although most client libraries will happily parse either, the first allows you to place additional useful data about the collection as an attribute of the collection itself:</p>

<pre><code>&lt;?xml version="1.0"?&gt;
&lt;count&gt;2&lt;/count&gt;
&lt;last-added&gt;...&lt;/last-added&gt;
&lt;dogs&gt;
  ...
&lt;/dogs&gt;
</code></pre>

<h3>Use elements for data, not attributes.</h3>

<p>Client library support for XML attributes is inconsistent and what distinguishes data in elements from data in attributes isn&#8217;t always clear.</p>

<p>Do this:</p>

<pre><code>&lt;asset&gt;
  &lt;id&gt;A1001001A06C13B45909C08771&lt;/id&gt;
  &lt;name&gt;AMS_TEST_ITEM&lt;/name&gt;
  &lt;display-name&gt;AMS_TEST_ITEM&lt;/display-name&gt;
  &lt;size&gt;80638&lt;/size&gt;
  &lt;thumbnail&gt;
    &lt;is-defult&gt;true&lt;/is-default&gt;
    &lt;url&gt;http://www.example.com/ams/icons/gif.gif&lt;/url&gt;
  &lt;/thumbnail&gt;
&lt;/asset&gt;
</code></pre>

<p>not this:</p>

<pre><code>&lt;asset ID="A1001001A06C13B45909C08771"&gt;
  &lt;entity name="AMS_TEST_ITEM" display-name="AMS_TEST_ITEM" /&gt;
  &lt;metadata name="AMS_SZ" display-name="Size" namespace="Info"&gt;80638&lt;/metadata&gt;
  &lt;thumbnail isDefault="true"&gt;http://www.example.com/ams/icons/gif.gif&lt;/thumbnail&gt;
&lt;/asset&gt;
</code></pre>

<p>One valid use of attributes is to provide metadata. A common example is including suggested type casting, since XML (unlike json) only sends string data:</p>

<pre><code>&lt;asset&gt;
  &lt;id type='integer'&gt;A1001001A06C13B45909C08771&lt;/id&gt;
  &lt;name&gt;AMS_TEST_ITEM&lt;/name&gt;
  &lt;display-name&gt;AMS_TEST_ITEM&lt;/display-name&gt;
  &lt;size type='integer'&gt;80638&lt;/size&gt;
  &lt;thumbnail&gt;
    &lt;is-defult type='boolean'&gt;true&lt;/is-default&gt;
    &lt;url&gt;http://www.example.com/ams/icons/gif.gif&lt;/url&gt;
  &lt;/thumbnail&gt;
&lt;/asset&gt;
</code></pre>

<p>Support for this in client libraries is spotty, however.</p>

<p>For <code>json</code> the structure is more formalized since json parses into native javascript date types.  There are no attributes, only slots; strings, integers, booleans, nested object literals, nested arrays, and other formats can be sent as data in these slots.  There&#8217;s really only one decision needed for json:</p>

<h3>Have the outer object contained in a slot named for its type, or don&#8217;t</h3>

<p>This one varies from API to API, both formats work well:</p>

<pre><code>{
  'name' : '...',
  'age'  : 22,
  'dogs' : [
    {'name' : 'fido', 'breed' : 'mutt', 'is_spayed' : true},
    {'name' : 'killer', 'breed' : 'poodle', 'is_spayed' : false}
  ]
}
</code></pre>

<p>or</p>

<pre><code>{
  'person' : {
    'name': '...',
    'age' : 22,
    'dogs' : [...]
  }
}
</code></pre>

<p>The latter will allow you to send back additional data about the response</p>

<pre><code>{
  'access' : 'read-only',
  'person' : {
    'name': '...',
    'age' : 22
  }
}
</code></pre>

<p>But either format is acceptable. </p>

<h3>For both XML and JSON, accept images as either multipart/post or a url</h3>

<p>Images are tricky to manage via an API over the web (check out all the trouble that <a href="http://code.google.com/p/twitter-api/issues/list?can=1&amp;q=image&amp;colspec=ID+Stars+Type+Status+Priority+Owner+Summary+Opened+Modified+Component&amp;cells=tiles">Twitter has had</a>).  Sending a multipart/post with the image data as content is probably the correct answer, but some http libraries (notably Ruby&#8217;s) have buggy or incomplete multipart/post implementations. Do your developers a favor and accept urls referencing images in addition to data <code>POST</code>ed as multipart body content. </p>

<h2>6) Protect Your Users with OAuth</h2>

<p>One thorny issue of user-specific API data is how you allow third party access.  Twitter, until recently, required users to give their twitter username and password to third parties.  You don&#8217;t ever want your users handing out their passwords! Instead, like Twitter, MySpace, Google Data, Get Satisfaction, Tripit, and many others, control access to your users&#8217; data with <a href="http://oauth.net/">OAuth</a>.  OAuth (not be mistaken with the very different <a href="http://openid.net/">OpenID</a>) lets your users give access to a third party without giving away their credentials.</p>

<p>Libraries for adding OAuth to your API and for third-parties to consume data are available in all major languages.</p>

<h2>7) Don&#8217;t Shut Off HTTP Authentication Entirely</h2>

<p>OAuth isn&#8217;t always the answer.  For cases where the end user isn&#8217;t involving a third party directly (e.g. a desktop or iPhone application that only communicates with <em>your</em> servers), allowing the user to simply enter their user name and password provides a more desirable user experience.  At the very least, allow HTTP Authentication to obtain a token for these kinds of applications and then use that token for all other requests.</p>

<h2>8) Document, Document, Document</h2>

<p>Finally, fully document your API.  You&#8217;ll want to demonstrate the following: valid URIs, required and optional data, HTTP status codes and what causes them, sample requests, and sample responses.</p>

<p>Having your documentation on the web in a structured format is best. <a href="https://plans.pbworks.com/index.php">PBWorks</a> (formerly PBWiki) is very popular for API documenting: <a href="http://apiwiki.twitter.com/">Twitter</a>, <a href="http://apidoc.digg.com/">Digg</a>, and a few others are using it.</p>
