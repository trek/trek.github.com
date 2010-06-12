--- 
layout: post
title: iTunes U via Ruby
---
I've been involved with Apple's <a href='http://www.apple.com/education/itunesu/'>iTunes U </a>project since it's inception. My <a href='http://www.dent.umich.edu/'>former employer</a> was one of the initial schools to use iTunes U. We began recording <em>all</em> of our classes lecture material in 2005 as a kind of digital note taking service and the project is still going strong in 2008 (with something like 3000 lectures recorded to date).

The project was <a href='http://connect.educause.edu/Library/EDUCAUSE+Quarterly/PodcastingLectures/39987?time=1221235539'>a smashing success for us</a> and has since led to iTunes U adoption <a href='http://www.ur.umich.edu/0708/Apr14_08/00.php'>Unviersity-wide</a>.

Apple released a XML-based webservices API to iTunes U about a year and a half ago. It's not fantastic<sup><a href='#one'>1</a></sup>, but it does open up access to iTunes U in new an interesting ways. Unfortunately Apple only provides sample scripts for authenticating to their service, not actually using it for other tasks (like finding or updating material).  Double disaster: these scripts are only offered in C, Java, Perl, Python, and Shell, leaving Ruby developers out in the cold.

That's an odd move, considering Ruby is a <a href='http://www.pragprog.com/titles/bmrc/rubycocoa'>first-class citizen in the OS X/Cocoa world</a>, <a href='http://www.apple.com/server/macosx/features/podcasts.html'>Apple's Podcast Producer</a> software is <a href='http://developer.apple.com/documentation/Darwin/Reference/ManPages/man1/pcastaction.1.html'>written in Ruby</a>, and it seems like every <a href='http://www.tbray.org/ongoing/When/200x/2007/11/12/-big/IMGP7123.jpg'>Ruby developer in the world is sporting a Macbook</a> these days.

I'm working (semi-secretly) with a company on a new education-targeted product based in Rails.  I can't talk much about the focus but I can say that products like Blackboard and Sakai are emphatically <em>not</em> the competition.  We wanted iTunes U integration to be part of an extended set of plugins available to augment the core product.


We've extracted the juicy bits into a new gem called RTunesU.  You can snag it via ruby gems
<pre><code>
  gem install rtunesu
</code></pre>

or check out the source from the <a href='http://github.com/trek/rtunesu/'>github repo</a>
<pre><code>
  git clone git://github.com/trek/rtunesu.git
</code></pre>

RTunesU fully wraps Apple's XML web services inside happy little objects. It's comparable to the <a href='http://code.google.com/p/itunesu-api-java'>third-party Java library</a> for iTunes U.  Those interested in the power of metaprogramming should check out the relative sizes of each library.  I think all of RTunesU is smaller than the Course class in Java.

To use it you'll need access to your institution's site name, administrator credentials, and shared secret (all provided by Apple at signup time).

Below are some example uses:

Establishing a connection
<pre><code>
  require 'rtunesu'
  include RTunesU

  user = RTunesU::User.new(0, 'admin', 'Admin', 'admin@example.com')
  u.credentials = ['Administrator@urn:mace:example.edu']

  connection = RTunesU::Connection.new(:user =&gt; u,
  :site =&gt; 'example.edu',
  :shared_secret =&gt; 'STRINGOFTHIRTYTWOLETTERSORDIGITS')

</code></pre>

Once you have a connection you can use it to find any Entity in iTunes U if you know it's type (e.g. 'Course', 'Group') and its Handle attribute.

<pre><code>
  course = Course.find(12345678, connection)
  #=&gt; &lt;RTunesU::Course:0x355854 Handle=12345678 Name=&#x27;Learning in iTunes&#x27;&gt;
</code></pre>

This Entity will have access to all of its attributes and sub-entities and parent entities.  You can access attributes and sub-entities with its name as a method.  You can access an objets parent entity with the .parent method.

Accessing attributes:
<pre><code>
  course.Handle
  #=&gt; 12345678
  course.Name
  #=&gt; "Learning in iTunes"
  course.Instructor
  #=&gt; "James E. Professor"
</code></pre>

Accessing sub-entities
<pre><code>
  course.Groups
  #=&gt; [&lt;RTunesU::Group:0x355854&gt;, &lt;RTunesU::Course:0x192044&gt;]
  course.Groups.first
  #=&gt; &lt;RTunesU::Group:0x355854 Handle=9876543 Name=&#x27;Lectures&#x27;&gt;
  course.Groups.first.Name
  #=&gt; "Lectures"
</code></pre>

Accessing an Entity's parent
<pre><code>
  course.parent
  #=&gt; &lt;RTunesU::Section:0x9875854&gt;
  course.parent.name
  #=&gt; "Learning Technologies"
</code></pre>

Enjoy!

<a id='one'>1.</a> I spoke at WWDC with some folks about this.  I won't name names, but the decision to not follow practices like REST was apparently due to the difficulty of getting WebObjects to live in the present.  The current style of interaction being used in iTunes U WS was the easiest to implement on top of the existing code base.
