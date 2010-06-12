--- 
layout: post
title: Ye Gods, Another Rails Book
---
<p>You may have heard from such places as &#8220;instant message&#8221;, &#8220;t3h twitter&#8221; or &#8220;that one coffee shop Trek hangs out in all the time&#8221;, that I&#8217;m planning on finally putting together a book for Rails beginners.  Many will scoff: there are quite a few books already aimed at Rails beginners (including my currently personal recommendation <a href="http://www.sitepoint.com/books/rails2/">Simply Rails 2</a>).  Plus, Rails 3 (with some pretty major changes) is right around the corner which will probably require reworking every example in the book mid-writing. With both a saturated market and major revision looming, this very moment in history is probably the worst time for writing a book about Rails.</p>

<p>Still, I find myself at a moment in my life particularly suited to writing. I&#8217;ve spent time explaining Rails since nearly the beginning (starting with a few people in September of 2005). Over the last four years I&#8217;ve have a nearly unbroken streak of teaching Rails to classes, groups, and individuals (joined by the amazingly brilliant <a href="http://github.com/jessesielaff">Jesse Sielaff</a>).  Even including my 11 month engagement doing 80+ hour weeks at a startup working in Rails I&#8217;ve logged more hours <em>explaining</em> Rails than I have <em>using</em> it.</p>

<p>Rails has also changed a lot over the years.  The pieces have become more cleverly designed. The patterns have become better understood by the people using them and more latent inside the system itself (remember a time when a RESTful app was more a clever trick than required practice?).  These improvements have made Rails easier to explain and easier to teach in a systematic manner (unlimited choice is the enemy of the beginner).</p>

<p>Jesse and I have learned a lot about teaching Rails over the years. I&#8217;m hoping to capture some of that knowledge in print both for use in future courses and for those who want to learn Rails on their own. </p>

<h2>What It Will Be</h2>
<p>Our basic theis for teaching Rails is &#8220;tricks won&#8217;t work&#8221;.</p>

<p>Rails includes a ton of features that can increase the speed of development for experts. These features are absolute poison for a beginner. They make Rails seem like a collection of clever shortcuts instead of thoughtfully crafted framework for writing web applications. I have come to fear the phrase &#8220;Rails Magic.&#8221;</p>

<p>Even something as common for Rails programmers as form helpers represent a major conceptual hurdle for a beginner. I&#8217;ve watched literally several scores of learners stumble trying to understand how forms helpers tie into controllers.  Most, sadly, end up just &#8220;trusting the magic.&#8221; They&#8217;ll use brute force later in their code to work around some problem that, if they understood <a href="http://wonderfullyflawed.com/2009/02/17/rails-forms-microformat/">how Rails handled form submission</a>, would be trivial to solve.</p>

<p>Jesse and I teach Rails with no tricks.  You&#8217;ll find no <code>script/generate resource</code>, or even <code>script/generate controller</code>. Definitely no <code>form_for</code>.  Something like <code>map.resources</code> is too magical to start.  Hell, we don&#8217;t even show people <code>link_to</code> until they&#8217;re ready. </p>

<p>So, if you&#8217;re a Rails beginner (of have even been doing Rails for a while but it still feels too magical for your taste) give me shout on twitter <a href="http://twitter.com/trek/">@trek</a> if you&#8217;d like to beta-book this with me.  I don&#8217;t know what compensation I can offer (other than some &#8220;freeducation&#8221;).  If there&#8217;s someone you think could benefit from a book like this, feel free to send them my way.</p>

<p>I except beta-bookers to know <a href='http://www.sitepoint.com/books/html2/'>HTML, CSS</a>, and enough <a href='http://pine.fm/LearnToProgram/'>Ruby</a> to be a danger to themselves.</p>
