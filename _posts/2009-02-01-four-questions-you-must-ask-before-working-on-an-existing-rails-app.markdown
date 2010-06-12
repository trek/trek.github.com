--- 
layout: post
title: Four Questions You Must Ask Before Working on an Existing Rails App
---
<p>I&#8217;ve received an increasing number of requests for work on existing Rails projects lately.  As Rails nears its fifth birthday and third major revision, the framework has existed long enough that a round of applications started in the earlier days are coming up major additions or revisions. Five years is also long enough for the original developer(s) to have moved on, for the  application&#8217;s needs to expand faster than the current development team can handle them, or for an update the latest version of Rails to offer a tempting increase in reliability and decrease in LOC count. </p>

<p>Regardless of why I&#8217;m being approached, there are some questions I pose before accepting any work on an existing project. I want to share them to help people avoid some of the nasty time-stealing surprises I&#8217;ve had. Most of these questions are best answered by actually checking out the code and getting a sense of it yourself. Ask if you can have checkout rights (which often involves signing an NDA) before bidding on work.  If you can&#8217;t get access there are some ways you can glean the information with properly worded communication.</p>

<h3>1. Does the project have sufficient test coverage?</h3>

<p>The specific testing paradigm (TestUnit vs. RSpec vs. something else) isn&#8217;t important but <em>having tests</em> is.  An untested project means you&#8217;ll spend more time figuring out how the developers intended the project to work and may face some nasty surprises when unexpectedly poor architecture choices are discovered (possibly increasing the amount of time the project takes).</p>

<p>An untested application also has a <em>signifincalty</em> higher chance of breaking when you touch it.  If the project is untested, are you willing to go everywhere in the application, trying every action manually with a variety of data to make sure your changes didn&#8217;t break process you don&#8217;t know about? Tests give you the confidence to boldly make changes. </p>

<p>If the original programmer(s) are around you can ask them to write tests or suggest that your first task on the job is to pair program with them and write tests.  If the original folks are gone and can&#8217;t be contracted to help with testing, think very carefully about accepting the project.</p>

<p>The easiest way to determine test coverage is to run the tests yourself and use tools like <a href="http://eigenclass.org/hiki.rb?rcov">Rcov</a>. If the client won&#8217;t give you access to the full project, ask them to send along the largest test file and the smallest test file.  The largest should cover a variety of concepts, or one a single concept in a variety of situations. The smallest should do more than assert that true is, in fact, true.</p>

<p>If there are no tests and you still want to take on the project make sure the client is comfortable paying the additional costs associated with learning the application and writing tests to cover the existing code first (before <em>any</em> new code/features can be added). Inform them ahead of time that despite your best efforts the application will break in unexpected ways because there isn&#8217;t an existing description of those expectations. These setbacks should be payed for by the client.</p>

<p>Most potential clients balk when I tell them their untested application might burn through the entire budget just arriving at the point where new development becomes possible. I usually let these jobs pass me by.  After-the-fact test writing isn&#8217;t enjoyable even if the client is willing to pay for it; coding a project where breaking existing features is a constant worry is even less enjoyable.</p>

<h3>2. Does the project strictly follow the MVC and REST patterns?</h3>

<p>These two pattens form the essential core of Rails.  In addition to being a good a way of organizing an application these two pattens are  virtually expected by the framework. This wasn&#8217;t always strictly the case in earlier versions of Rails. People who develop Rails and people who develop <em>using</em> Rails were still hashing out how these patterns should be expressed in ruby code (remember Jamis Buck&#8217;s <a href='http://weblog.jamisbuck.org/2006/10/18/skinny-controller-fat-model'>Skinny Controller, Fat Model</a> article? What was a good practice in 2006 is a required pattern now).</p>

<p>In Rails 2+ deviating too far from these patterns means you&#8217;ll expend a lot of energy fighting the framework.  You can easily pick out a Rails developer who doesn&#8217;t like or understand MVC and REST. Be wary if their <code>routes.rb</code> isn&#8217;t much more than <code>map.connect ':controller/:action/:id'</code>, their actions are named <code>about</code>, <code>dashboard</code>, <code>contact</code>, <code>save</code>, <code>js_save</code>, and those actions contain a lot of data manipulation. </p>

<p>In applications structured this way expect a sizable portion of your task to be rearchitecting. </p>

<p>If you&#8217;re fortunate enough to inherit a well structured MVC/REST application you&#8217;ll find that the task of upgrading to new versions of Rails is easier and understanding how the various parts of the application are pieced together will feel natural.</p>

<h3>3. Which version of Rails does the project use?</h3>

<p>Rails 2.2 is a vastly different beast than Rails 1.0 was (and Merb 2/Rails 3 will be even more so). The framework has eliminated a lot of work that was previously done by the developer. Routing is more robust, the REST pattern is better integrated, models have an improved DSL for describing and manipulating complex data relations, and there is an amazing ecosystem of third party libraries that make development highly enjoyable.</p>

<p>If you&#8217;re looking at a Rails 1 application, speak frankly with clients about the advantages of new versions of Rails.  Converting to Rails 2+ slows down development initially but you&#8217;ll reap the benefits later in the project. Of course, if the application also does not follow MVC/REST (point 2) and isn&#8217;t tested (point 1), converting to later version of Rails will be a major undertaking (one that the client may not be willing to pay for).</p>

<p>You&#8217;ll know which version of Rails is being used because it will be frozen into <code>/vendor</code> or declared as <code>RAILS_GEM_VERSION</code> in <code>/config/environment.rb</code></p>

<h3>4. How is deployment managed?</h3>

<p>Eventually clients want their application updated in a production environment.  Deploying Rails has changed as wildly as the framework itself - and at an equally rapid pace. Updating an older deployment structure to a newer one is much easier if deployment is automated.  If the deployment instructions start with &#8220;first ftp the project to each box, then ssh in and run the command&#8230;&#8221; or don&#8217;t exist at all, you&#8217;ll need to manually examine how the production machines are configured and, hopefully, work with a previous developer to avoid missing any steps.</p>

<p>Right now I&#8217;m following most people&#8217;s suggestion of deploying via <a href="http://www.modrails.com/">mod_rails</a> unless there is some specific reason apache won&#8217;t work.  This may involved changing hosting companies and porting over persisted data.</p>

<h3>I&#8217;m taking the job. Now what?</h3>

<p>If you&#8217;re lucky, you&#8217;ll be asked to work on a well tested, documented, properly modeled, MVC/RESTful Rails 2.2 app that just needs a little love.  For those unlucky souls approaching a less than ideal existing project: think carefully about how you will manage your client&#8217;s expectation.  Clients think the money they paid for existing code is an investment already made and set in stone.</p>

<p>They won&#8217;t want to hear that it took you 15 hours to &#8220;just add a button&#8221; because you had to follow someone&#8217;s convoluted logic down the garden path. They especially won&#8217;t want to hear that it took <em>30</em> hours to add the button because the apparatus behind that button was such a Rube Goldberg-esque collection of chicken wire and plaster that you had to rewrite a lot of code. (We once cleverly refactored away about 10% of own code. This upset the CEO who asked us to send her the old code so she could keep it: for her, more code == a product that did more.  She couldn&#8217;t recognize that a drop in LOC wasn&#8217;t matched by an equal percentage of loss in function). </p>

<p>Remind your clients that web applications are complex systems. When the requirements of a complex system change, sometimes fundamental implementation changes are needed. When you add a second story to your house, sometimes you need to update the foundation. The original foundation isn&#8217;t broken, it just won&#8217;t support the weight of the extra space.  Keeping the material from the current roof to put back on can be more costly than just building a new one (and a new roof can have better insulation to help cut energy costs because building technology has improved since Roof version 1.0).</p>
