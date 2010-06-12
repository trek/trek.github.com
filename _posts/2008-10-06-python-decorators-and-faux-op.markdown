--- 
layout: post
title: Python Decorators and Faux-OP
---
I recently found a feature of Python that I quite like (although think the interface for using it is poorly designed): decorators.

Decorators are Python functions that alter what happens when a function is called.  In the example:
<code> </code>
<pre>
@do_some_magic
def foo
  pass</pre>
the function reference by <code>do_some_magic</code> will be called before <code>foo</code> to perform some magic.  This opens up some interesting metaprogramming opportunities. I'd like to use it to my tiny <a href="http://wonderfullyflawed.com/2008/09/29/enginelight-a-small-google-app-engine-framework/">MVC framework</a> for Google App Engine for adding additional behavior to actions:
<code> </code>
<pre>  @login_required
  @authorize
  @only_adminstrators
  def show
    pass</pre>
For what I want to do it's not as powerful as Rails' before_filter, but more pythonic (I hope) and will require less custom code.  Unfortunately, to use decorators I need <code>login_required</code>, <code>authorize</code>, and <code>only_adminstrators</code> to be scoped correctly to the instance object.

<code>Self</code>, like many OOP aspects of Python, is accomplished by some internal trickery that is exposed to the programmer. Internal trickery I can handle; having it exposed to me, I cannot.
In Ruby, <code>self</code> is handled by the language and always behaves in a predictable way (referencing the receiver of a method call). In Python, <code>self</code> for a function is accomplished by some hoop-jumping. The first (secret and hidden) argument to a method in Python represents the object receiving the message.

So, you get methods definitions like
<code> </code>
<pre>  def full_name(self)
    self.first_name + " " + self.last_name</pre>
This is called with
<code> </code>
<pre>  person.full_name()</pre>
and <code>self</code> will be set to the object represented by <code>person</code>. "But wait!" you say, "you just called <code>full_name</code> with no arguments. How did it handle having called a method that clearly is defined with one argument being called with none?"

<del>Trickery</del>Explicitness.  Despite appearing like this method requires you to provide an argument, it doesn't.  The called object is automatically inserted for you. In fact, calling this method with an argument (even one you think would be meaningful like, say, the instance object) will cause Python to throw an error:

<code> </code>
<pre>  person.full_name(person)</pre>
will return
<code> </code>
<pre>TypeError: full_name() takes exactly 1 argument (2 given)</pre>
Yeah, you read that right. I passed one argument and I'm told that, in fact, I passed two and it wants one.  Python handles passing the first argument for me. Why it couldn't handle keeping track of <code>self</code> internally and keep argument counts more obvious is something a more experience Python programmer would have to answer.  To demonstrate just how faked <code>self</code> is, we can in fact call this first (magic and hidden) argument to a method anything we want:

<code> </code>
<pre>  def full_name(identity_crisis)
    identity_crisis.first_name + " " + identity_crisis.last_name</pre>
has the same effect. Python programmers just use the word <code>self</code> by convention.

This loose concept of identity in Python instance objects was tripping me up when using decorators. With the sample code below

<code> </code>
<pre>class Foo(object):
  def __init__(self, arg):
    self.name = arg

  def dec(self):
    self.name = "something else!"

  @dec
  def bar(self):
    return self.name</pre>
I expected calling <code>bar</code> would show me the <code>name</code> attribute of the object, now altered to "something else!".
<code> </code>
<pre>  x = Foo('x')
  x.name # returns 'x'
  x.bar()  # expecting "something else!", but got TypeError: 'NoneType' object is not callable</pre>
Huh? What in my code is NoneType?  Well it turns out that inside my decorator <code>dec</code>, the object represented by <code>self</code> doesn't have a <code>name</code> because <code>self</code> doesn't refer to the instance object.  If you're Python person, stop chucking. If you're a Ruby person, read that again.  Why wouldn't <code>self</code> refer to the instance object?

Well, even though the decorator was defined in the same way as every other instance method in the class, the first (secret and hidden) argument of a decorator function isn't the instance object. It's the function that it decorates.  So, <code>self</code> here refers to the function <code>bar</code>. I read elsewhere that by convention the first (secret and hidden) argument to a decorator is named <code>fn</code>.  So, I clean up the code a bit to make it more obvious that I don't have access to my instance object:

<code> </code>
<pre>class Foo(object):
  def __init__(self, arg):
    self.name = arg

  def dec(fn):
    # self.name = "something else!"

  @dec
  def bar(self):
    return self.name</pre>
but am still left with the question of "how to I get the instance object?". I know that functions have a <code>im_self</code> attribute (don't ask me what the <em>im_</em> part means, I have no idea; Python seems obsessed with short names instead of meaningful ones). So, maybe I can call that:

<code> </code>
<pre>class Foo(object):
  def __init__(self,name):
    self.name = name

  def dec(fn):
    fn.im_self.name = 'not what you think!'

  @dec
  def bar(self):
    return self.name</pre>
alas, I receive a Traceback:

<code> </code>
<pre>Traceback (most recent call last):
  File "&lt;stdin&gt;", line 1, in &lt;module&gt;
  File "&lt;stdin&gt;", line 16, in Foo
  File "&lt;stdin&gt;", line 7, in dec
AttributeError: 'function' object has no attribute 'im_self'</pre>
Aha! Only <em>certain</em> functions have access to <code>im_self</code>. Not this one, where it would be useful for accessing the instance object, but other ones.  So, I ask again, how do I get access to the instance object inside of a decorator?

I'm sure an experienced Python programmer has already seen my problem: I keep thinking of <code>self</code> as some sort of implicit aspect of OOP where any object knows how to refer to itself using <code>self</code>. I'm not thinking about <code>self</code> as an argument to function floating out in space, connected to a class by the thinnest of lifelines. The real question isn't "how to get <code>self</code>" it's "how to get the the arguments of decorated function, of which in instance object is the 0th (secret and hidden) argument."

I stumbled upon the answer immediately when I started thinking about it <em>correctly</em>: <a href="http://www.siafoo.net/article/68#getting-the-arguments">another, nested function</a>.  If I put another nested function inside my decorator and return that at the end of the decorator I'll be able to access the arguments (of which the instance objet is the 0th).

<code> </code>
<pre>class Foo(object):
  def __init__(self,name):
    self.name = name

  def dec(fn):
    def inner(*args):
      args[0].name = 'not what you thought, huh?'
      return fn(*args)
    return inner

  @dec
  def bar(self):
    return self.name</pre>
and now, as expected
<code> </code>
<pre> x = Foo('x')
 x.name  # 'x'
 x.bar() #'not what you thought, huh?'
 x.name  # 'not what you thought, huh?'</pre>
I know Python programmers defend this with a cry of "explicit is better than implicit," but this is really a mix of explicit and implicit. In my method definition I <em>explicitly</em> refer to the instance object which is then <em>implicitly</em> known when I call the method; <em>explicitly</em> passing it as argument will fail.  And, because some functions in a class (decorators) take a function as a first argument, I cannot guarantee that this implicit rule is consistently applied.

Of course the instance object actually <em>is</em> passed when you understand that classes in Python behave closer to a namespacing mechanism than class objects and
<code> </code>
<pre>  x = Foo('x')
  # call the bar method of our new Foo object
  x.bar()</pre>
is nothing more than <em>implicit</em> shorthand  for <em>explicit</em> syntax:

<code> </code>
<pre>  x = Foo('x')
  # call the bar method of Foo with an instance of Foo as an argument
  Foo.bar(x)</pre>
To create what other languages would treat as a class method, where <code>self</code> would refer to the class object you decorate the function with the <code>@classmethod</code> decorator
<code> </code>
<pre>  @classmethod
  def classy(self):
    return self</pre>
which is really just shorthand for the old-style syntax of creating a class method:
<code> </code>
<pre>  def classy(self):
    return self
  classy = classmethod(classy)</pre>
Comparing this to languages like Ruby, Smalltalk, or Objective-C I hesitate before telling people that Python is an object oriented language. Python clearly allows a programmer to support the object orientation <em>pattern</em> in their own code, but much of pattern implementation smells of functional programming tricks.

Still, apart from all of that, decorators are a cool idea.
