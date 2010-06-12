--- 
layout: post
title: Python Will Not Be The Programming Language of the Future
---
<p>I&#8217;ve blogged previously about sitting in the <a href="http://si.umich.edu">School of Informations</a>&#8217;s <a href="http://si539.com/">SI 539: Design of Complex Websites</a>, my <a href="http://wonderfullyflawed.com/2008/09/08/python-for-all-sure-why-not/">opinion of language choice</a>, and my <a href="http://wonderfullyflawed.com/2008/09/29/enginelight-a-small-google-app-engine-framework/">frustrations with parts of App Engine</a>.  After the last session of the course I had a short conversation with <a href="http://www.dr-chuck.com/csev-blog/">Chuck</a> about the nature of the SI&#8217;s programming requirement, the state of various languages and development environments, and the possibility of offering a solid selection of high-level, high-specificity half semester courses focusing on a single development space (Rails, App Engine, iPhone, Android, OLPC, RFID, etc). SI&#8217;s current programming offerings aim for a basic competency level.  This aim is a major disservice to the HCI students in the program who graduate with no completed projects and no &#8220;hard&#8221; skills they can apply, even at a beginner level.  </p>

<p>This, I think, is putting them at a major disadvantage against graduates from places like <a href="http://www.hcii.cmu.edu/">CMU</a> who leave with several completed projects under their belt.  SI&#8217;s students are leaving with some reports, diagrams, and concept pieces untempered by actual development experience. I&#8217;ve found almost SI student suffer from a near-fatal case of wouldn&#8217;t-it-be-cool-itis. They&#8217;re full of great ideas but, lacking practical experience, unable to  weigh the value added to product against the cost of adding it (&#8220;Feature X will be very valuable to users, but more costly than features A, B, and C which combined will do more to improve the experience&#8221;).</p>

<p>During this conversation Chuck tossed out one of those nuggets so surprising that you can only nod along, mouth agape.  I can&#8217;t recall the exact quote, but this comes close, &#8220;I think Ruby had its year, but now it&#8217;s pretty much over. Python&#8217;s everywhere. I mean, Google uses it. It&#8217;s the future world programming language.&#8221;</p>

<p>Two thing struck me as odd in this statement. First, the notion that Python has somehow become a major language recently and Ruby&#8217;s growth since its 2005 entrance into popular attention has stalled. The second, that some language is on its way to becoming the One Language To Rule Them All.</p>

<p>Sadly, I don&#8217;t carry around a Ruby Defense Kit, so I just had to trust the the experience behind Chuck&#8217;s opinion.</p>

<p>His assertion <em>seemed</em> odd to me, though. Based on my experience I see roughly the same amount of Python and Ruby chatter.  I encounter Ruby developers in the wild more often, and meet more people interesting in moving to Ruby than to Python, but this could just be my personal experience. Clearly I needed to dig a little deeper and get some perspective on the question.</p>

<p>Based on what I found, I think Chuck is experiencing perspective bias from his recent heavy Python involvement.  Generally I found the following things:</p>

<ul>
<li>Python is growing</li>
<li>Ruby is growing</li>
<li>Python grew faster this year than last</li>
<li>Ruby grew faster last year than this year</li>
<li>Python grew from almost no interest to its current level over 12 years</li>
<li>Ruby grew from almost no interest to its current level in 3 years</li>
<li>There&#8217;s a slight trend towards Ruby over Python for new web projects (likely caused by Rails)</li>
</ul>

<p>Although book trends aren&#8217;t a perfect representation of language use <a href="http://radar.oreilly.com/archives/2008/03/state-of-the-computer-book-mar-23.html">O&#8217;Reilly book sales chart</a> from earlier this year is a nice summary of what I generally found:</p>

<p><a href="http://radar.oreilly.com/Language_all.jpg"><img src="http://radar.oreilly.com/Language_all-tm.jpg" alt="" title=""></a></p>

<p>You can also find some great data by doing trend searches on <a href="http://www.indeed.com/jobtrends">indeed.com</a>.</p>

<p>Neither Python nor Ruby is a minority language, but neither are they majority languages. They appear to be growing by cannibalizing from Java, C/C++, PHP, and Perl. The question that speaks directly to Chuck&#8217;s second point (Python is on its way to becoming <em>the</em> world programming language) is whether one of these languages will continue to cannibalize until it becomes the dominant language.</p>

<p>That seemed to be happening with C++, until it didn&#8217;t. That was the hope with Java until everyone realized  <a href="http://en.wikipedia.org/wiki/Write_once,_run_anywhere">WORA</a> was a myth.</p>

<p>Chuck thinks we're in store for another round of this, but I don't.  The need, and desire, for a single language for all your development has passed.  The number, and variety, of devices we develop for has grown and each device has particular needs better met by particular languages and frameworks.</p>

<p>Consider the Mac platform.  I could develop native Ruby (or Python) applications for Mac OS X, but I lose all the major productivity boosts of <a href="http://en.wikipedia.org/wiki/Cocoa_(API">Cocoa</a>). I could develop Cocoa apps with Ruby (or Python) but Cocoa is filled with an expression style better suited to Objective-C so I use obj-c.</p>

<p>You can tell a similar story about Windows. </p>

<p>The iPhone uses Cocoa, Java dominates on other mobile devices, there&#8217;s a lot of interest in Erlang for highly concurrent systems, if your market is web you need Javascript (unless you use GWT, Pyjamas, or soon-to-be-released <a href="http://github.com/jessesielaff/red/">Red</a>), Lua is starting to dominate in game scripting, C# is king for Xbox XNA games, and some day Nintendo will realize that <a href="http://www.warioworld.com/apply/">requiring a separate, secure office and charging $2,000 - $10,000</a> is driving indie game developers to the iPhone/Touch.</p>

<p>There&#8217;s a high chance you&#8217;re currently working professionally in multiple languages each best suited to its particular job.  I don&#8217;t foresee a massive move to ruby cocoa or iron python. Who is so tied to a particular language that they&#8217;d be willing to give up major advantages of programming in another language where it&#8217;s most appropriate?</p>

<p>Certainly not me. My love of Ruby can&#8217;t overcome my love of being lazy.</p>
