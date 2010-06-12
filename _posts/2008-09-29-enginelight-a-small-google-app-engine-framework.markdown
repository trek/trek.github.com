--- 
layout: post
title: EngineLight - A Small Google App Engine Framework
---
<p>
<strong>Note: I abandoned this project and removed it from github. I had fun playing with AppEngine and python, but python is a poor fit for my mode of problem solving and never really tore me away from smalltalk-ish languages like Ruby and Objective-C. I much prefer <a href='http://heroku.com'>heroku</a> for easy cloud deployment. Cheers.</strong>
</p>
<p>I&#8217;m playing around with <a href="http://code.google.com/appengine/">Google&#8217;s App Engine</a> product as I sit in on <a href="http://www.si539.com/">a course I used to teach</a>, now taught by <a href="http://www.dr-chuck.com/csev-blog/">Charles Severence</a>.  I&#8217;ve been <a href="http://wonderfullyflawed.com/2008/09/08/python-for-all-sure-why-not/">fairly vocal</a> about my thoughts on the move away from Ruby to Python for this course, although I can see the draw of using App Engine for education. Deployment can be a bitch and often setting up a box with various languages for student projects is beyond the ability and budget of a <a href="http://www.si.umich.edu/computing/">small school&#8217;s IT department</a>.  I want to be helpful when the App Engine part of course comes around, so I need to spend some time and make a App Engine app.</p>

<p>App Engine provides a built-in <a href="http://code.google.com/appengine/docs/datastore/">Model class</a> that saves to Google&#8217;s Big Table, a built-in <a href="http://code.google.com/appengine/docs/gettingstarted/templates.html">template library</a> roughly ported from Django&#8217;s templates, and a <a href="http://code.google.com/appengine/docs/webapp/">webapp framework</a> for exposing both on the web. </p>

<p>For someone coming from a <a href="http://rubyonrails.com/">more robust environment</a>, developing with the provided webapp framework is painful.  Here&#8217;s sample from Google&#8217;s doc:</p>

<pre><code>from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app

class MainPage(webapp.RequestHandler):
  def get(self):
    self.response.headers['Content-Type'] = 'text/plain'
    self.response.out.write('Hello, webapp World!')

application = webapp.WSGIApplication(
                                     [('/', MainPage)],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()
</code></pre>

<p>Google&#8217;s apparently taking a very PHPesque page-structured app approach with their framework. Where a class = a page tied together with some basic routing (the <code>[('/', MainPage)]</code> bits).  It&#8217;s definitely not MVC and after spending three years doing rapidly development thanks to a structured pattern I&#8217;m in no mood to return to an earlier time.</p>

<p>Google says you can run any any WSGI-compliant framework- &#8220;including Django, CherryPy, Pylons&#8221; - and has included  the entire Django framework. I found this to be slightly untrue.  It&#8217;s like Django, but modified. And I kept getting tripped up in the subtle differences between documented features and actual implementation once it was on App Engine.</p>

<p>The same goes for the other frameworks listed: they all require a bit of monkey patching to run properly.  Someone with a lot of experience with one of these frameworks will probably go through the trouble of modifying their preferred framework to gain the benefit of using it on App Engine. But even if you do get them working, I hear there are whole parts that don&#8217;t run - or don&#8217;t run properly - on Google&#8217;s slightly off-color python environment.</p>

<p>My own attempt to get Pylons (which seemed most <a href="http://www.merbivore.com/">Merb</a>-like and therefore caught my eye) working properly with the <a href="http://code.google.com/p/appengine-monkey/wiki/Pylons">appengine-money library</a> failed miserably.</p>

<p>So, I figured: why bother? If the framework is being gutted to work on App Engine and Google provides <em>most</em> of MVC in the included Model class and Template language there isn&#8217;t much left. I&#8217;m big <a href="http://weblog.jamisbuck.org/2006/10/18/skinny-controller-fat-model">skinny controller, fat model</a> believer and think controllers should only be used as a flow control technique (hence their name) that essentially pour data into a specific template.  They&#8217;re just a way to parcel out your code into tiny manageable, patterned bits.  In Rails controllers, we rarely have more than the typical seven actions (index, show, new, create, edit, update, destroy) and a before filter or two.</p>

<p>I started EngineLight, a small encapsulation layer for the App Engine webapp framework.  It&#8217;s pretty rickety right now, but has bits of the things I&#8217;ve needed so far.  I plan on expanding it as write a sample app for App Engine.  I&#8217;m using the <a href="http://routes.groovie.org/">Python Routes libary</a> which is a quite robust port of Rails&#8217; routing system.  Really the only code I&#8217;ve needed to write myself so far is a tiny AbstractController class that encapsulates the existing Request and Response objects and builds a response using the built-in template library.  An example controller can be as simple as</p>

<pre><code>from application_controller import ApplicationController
from models import Note

class NotesController(ApplicationController):
  def index(self):
    notes = Note.all().fetch()
    self.view['notes'] = notes
    self.render_view('entries/index.html')
</code></pre>

<p>And a route might be</p>

<pre><code>def routing(m):
  m.resource('note','notes')
  return m
</code></pre>

<p>This will automatically call NotesController.index() when someone browses to <code>/notes/</code> and NotesController.show() with <code>params['id']</code> set when someone goes to <code>/notes/12</code>.</p>

<p>Check out the <a href="http://github.com/trek/engine-light/tree/master">EngineLight</a> on github. You can install it straight from there with </p>

<pre><code>easy_install easy_install http://github.com/trek/engine-light/tree/master%2Fdist%2Fenginelight-0.1dev-py2.5.egg?raw=true
</code></pre>

<p>generate a new project with</p>

<pre><code>paster create -t enginelight myappname
</code></pre>

<p>and from inside that app create models (name them singularly) and controllers (plurals, please) with</p>

<pre><code>paster controller Notes

paster model Note
</code></pre>

<p>routes will be a .py file in YourProject/congif/routes.py</p>

<p><del>Enjoy, but expect it to break a lot until I&#8217;m done!</del> I've abandoned this project. I was able to structure an app to work much like the patterns in Rails, but don't really have any interest in extracting that into a reusable library. App Engine is neat, but as a Ruby (mostly) developer it's not really my cup of tea.</p>
