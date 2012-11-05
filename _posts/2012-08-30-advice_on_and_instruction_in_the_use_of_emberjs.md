---
layout: default
title: Advice on & Instruction in the use of Ember.js
---
# Advice on & Instruction in the Use Of Ember.js
[Ember.js](http://emberjs.com/) &mdash; for the unaware &mdash; is an application framework
for building sophisticated browser applications. I'm a frequent contributor to
the project and use it professionally at my current gig with [Groupon
Engineering](http://www.groupon.com/techjobs/#/about). This piece is part
tutorial, part marketing pitch.

There's currently a lot of interest in Ember and its
browser-application-crafting siblings as people are becoming more comfortable
with the browser as a legitimate application development platform and not merely a
ubiquitously deployed rendering engine for server-generated documents. [Not
everyone](https://twitter.com/dhh/status/212655990766702594) thinks this pattern
is viable moving forward, but I suspect interest in making this style of
application will only increase over time, become foolishly and inappropriately
overused, and finally settle down as a useful addition to a developer's
toolset.

I'm pretty convinced Ember will be the go-to choice for writing applications
with the sophistication, usefulness, and polish of products like
[Rdio](http://www.rdio.com/), [Square](https://squareup.com/)'s web properties,
or [Wunderkit](http://get.wunderkit.com/apps/). Ember is the only framework I've
seen so far that is genuinely tackling the real and difficult requirements of UI
Engineering. I don't say this to knock projects like
[Batman](http://batmanjs.org/), [Knockout](http://knockoutjs.com/),
[Angular](http://www.angularjs.org/), or [Backbone](http://backbonejs.org/).
They're quite good; I've played with all and have used Backbone professionally.

Like Ember, they're all experimenting with strategies for connecting data to
display and keeping the two synchronized – a notably difficult task. But only
Ember is approaching this task in a larger scope of UI Engineering that involves
even harder architecture concerns. This is part of what makes Ember.js
challenging for a learner to approach. Have you ever written an app that is
long-running, stateful, requires identity mapping, or must serialize state for
later re-entry? If you're like most web developers I meet, it's highly likely
these are all foreign or novel concepts for you. Even if you've encountered them
before in a CS class or while doing iOS development you've probably never
translated them into the browser environment.

Listen: it's not Ember that's hard. It's the concepts. When people tell me the
learning curve for Angular or Backbone is small, I call bullshit. Small for whom? Sure,
Backbone is approachable if you've spent some time writing applications with jQuery
and are familiar with callback-style evented architectures. Backbone's DNA is
basically [jQuery custom
events](http://css-tricks.com/custom-events-are-pretty-cool/) on steroids.
Angular is a dream if you're accustomed to HTML `data-` style behavior like
you find as part of [Twitter Bootstrap's javascript](http://twitter.github.com/bootstrap/javascript.html)

Even if Backbone fits squarely into your existing skill set – admittedly true
for most web developers – it's learning curve ramps up steeply if you're
dedicated to writing robust applications. Ever run into [zombie events in a
Backbone
application](http://lostechies.com/derickbailey/2011/09/15/zombies-run-managing-page-transitions-in-backbone-apps/)?
No? You've either not used it for anything big, have [Rain
Man](http://www.imdb.com/title/tt0095953/)-like ability to craft software, or
are fucking shitting me.

Here's an example of some of the view cleanup code in Rdio:

``` javascript
destroy: function () {
  var c = this;
  this.unbind();
  try {
    this._element.pause(),
    this._element.removeEventListener("error", this._triggerError),
    this._element.removeEventListener("ended", this._triggerEnd),
    this._element.removeEventListener("canplay", this._triggerReady),
    this._element.removeEventListener("loadedmetadata", this._onLoadedMetadata),
    _.each(b, function (a) {
      c._element.removeEventListener(a, c._bubbleProfilingEvent)
    }),
    _.each(a, function (a) {
      c._element.removeEventListener(a, c._logEvent)
    }),
    this._element = null,
    this.trigger("destroy")
  } catch (d) {}
}
```


If this doesn't look familiar, you're in for a world of hurt when you try to
parlay your Backbone skills into something Rdio-sized. Backbone is the best solution,
hands down, for apps where the user comes to a page, interacts with the application
for a short time before moving on, letting the [views and the models get thrown
away](https://github.com/documentcloud/backbone/issues/231). Beyond that,
it requires increasing diligence and expertise on your part.

So, here's my pitch: I want you to learn Ember. Not instead of Backbone or
Angular but _in addition to_ them. There's a lot of writing comparing the three,
but once you become familiar with them you'll see it's a totally nonsensical
comparison. Although their output is the same (i.e. a "web app") they just don't
belong in the same category.

I apologize for the long preamble, but we're exploring some concepts and
I want to be sure you're willing to allow that their strangeness is not due to
the poor architecture of Ember but to your unfamiliarity with them. If you're
willing to learn no matter how funky weird things appear at first, read on. If
you're looking to troll then just skim on: you'll find _lots_ of things to
highlight [when you create a troll twitter account with a single post maligning
a tool you've never bothered to
explore](https://twitter.com/delambro/status/234997274051219456).

## The Smallest Viable Ember Application
The smallest possible Ember application of interest can be describe thus:

```javascript
App = Ember.Application.create();

App.ApplicationView = Ember.View.extend({
  templateName: 'application'
});
App.ApplicationController = Ember.Controller.extend();


App.Router = Ember.Router.extend({
  root: Ember.Route.extend({
    index: Ember.Route.extend({
      route: '/'
    })
  })
});

App.initialize();
```

And in our HTML document body or head:

```html
<script type="text/x-handlebars" data-template-name="application">

</script>
```

Let's examine each piece in isolation.

```javascript
App = Ember.Application.create();
```
This line creates a new instance of `Ember.Application`. `Application` does two handy things:

  * provides one location for all your objects so we avoid [polluting the global namespace](https://www.google.com/search?q=don't+pollute+the+global+namespace).
  * creates one listener for each user event (e.g. 'click') and [controls event delegation](https://www.google.com/search?q=event+delegation).

&nbsp;

```javascript
App.ApplicationView = Ember.View.extend({
  templateName: 'application'
});
```
Views in Ember are responsible for:

   * determining the structure of a section of the application's rendered HTML.
   * responding to delegated user events.

In the above view we will change structure of the page only through the view's
template, which will render as the contents of the view's tag, but we could also
provide a different tag name, id, css class, or other HTML attributes for the
rendered element.

Your application _must_ have an `ApplicationView` property. An instance of this
class will be created for you and inserted into the application's view hierarchy
as the root view.

```javascript
App.ApplicationController = Ember.Controller.extend();
```

Every view has a rendering context. This is the object where Handlebars
templates will look for properties. So, if your template looks like this:

    {% raw %}{{name}}{% endraw %}

and its rendering context has a `name` property, you'll see the value outputted.
If there is no property, you'll see nothing.

A single instance of `ApplicationController` will be created for you and
automatically set as the rendering context of the `ApplicationView`. This is
obvious but bears mentioning: your application _must_ have an
`ApplicationController` property. If it lacked one, the application's root view
would have no rendering context and would be pretty useless except for
displaying static content. Ember enforces the presence of this property by
throwing an error if it's missing.

```javascript
App.Router = Ember.Router.extend({
  root: Ember.Route.extend({
    index: Ember.Route.extend({
      route: '/'
    })
  })
});
```

A `Router` in Ember behaves significantly different than you probably suspect
if you have experience with other javascript libraries using the 'router' label.
Ember's `Router` class is a subclass of its more general purpose `StateManager`.
Most browser-routers are just copying the routing pattern from familiar server
technologies. But HTTP is specifically a [stateless
protocol](http://en.wikipedia.org/wiki/Stateless_protocol) and the techniques
for routing on the server are missing important abilities when translated into
the stateful environment of browser application development.

Your application's router is responsible for tracking the state of your
application and affecting the application's view hierarchy in response to state
change. It is also responsible for serializing this state into a single string –
the URL – and for later deserializing the string into a usable application
state. Rather than being a central organizing technique, URLs are just a useful
side effect of state change.

States are the central feature of an Ember application. Yes, property
observations and automatic view updates are handy, but if that's all Ember
offered it would be only a fraction as useful for serious and robust development.

```javascript
...
root: Ember.Route.extend({
  index: Ember.Route.extend({
    route: '/'
  })
})
...
```

Your router must have these two routes. The first, `root`, really just acts as a
container for all subsequent routes. You can think of it as the route set,
rather than a proper route itself. The second `index`, can be called whatever
you like. The key feature is that it has a `route` property of `'/'`. When your
application loads, Ember will being looking through its internal route maps to
find one that matches the url in the browser. If you enter the application at
the url `'/'` your Router will automatically transition into this state.

```javascript
App.initialize();
```

Finally, calling `initialize` on your application starts the application's
routing process, sets up the necessary internal structure based on configuration
we've done earlier, and inserts an instance of your `ApplicationView` (with an
instance of `ApplicationController` as its rending context) into the page.

## Building Up An Application
From here, we can start building up an application by adding states to our
router, navigable elements in our templates to allow a user to begin
manipulating states, and views that are inserted in response to these state
changes. We'll create a tiny application that lets you see information about
committers to the main Ember repository.

Let's start that process by adding some markup and an `outlet` into our
currently empty `application` template:


```
<script type="text/x-handlebars" data-template-name="application">
  <h1>Ember Committers</h1>
  {% raw %}{{outlet}}{% endraw %}
</script>
```

An `outlet` helper defines sections of a template where we will change specific
portions of the view hierarchy in response to state change. Any template (not
just the root one) can have any number of outlets (if you give them names). This
lets you express really nuanced view hierarchies with minimal effort.

Next, add a view for all contributors and a matching controller and template:

```javascript
App.AllContributorsController = Ember.ArrayController.extend();
App.AllContributorsView = Ember.View.extend({
  templateName: 'contributors'
});
```
```
// in your page body or head:
<script type="text/x-handlebars" data-template-name="contributors">
  {% raw %}{{#each person in controller}}{% endraw %}
    {% raw %}{{person.login}}{% endraw %}
  {% raw %}{{/each}}{% endraw %}
</script>
```

Within the state that matches for the index path (`'/'`), implement a
`connectOutlets` method. It takes a single argument that will be your
application's router. Within that method get the single instance of our
`ApplicationController` class and connect its outlet with the `connectOutlet`
method:


```javascript
index: Ember.Route.extend({
  route: '/',
  connectOutlets: function(router){
    router.get('applicationController').connectOutlet('allContributors', [{login:'wycats'},{login:'tomdale'}]);
  }
})
```

Give your application a reload. You won't see much yet, but this will let you
catch any console errors now.

Let me assuage your obvious fears right now: Yes, this is a lot of code. Yes, it
seems weirdly complex. Yes, you could accomplish this same trivial task in
Backbone or Angular with far less code. Ember isn't targeting applications with
this minimal level of sophistication so it seems foolishly verbose when starting
out.

That said, this is the _single_ central pattern to an application. Once you
master it, you'll be cranking out applications like a pro. Ember applications
start out with a complexity rating of 4/10 but never get much higher than 6/10,
regardless of how sophisticated your application becomes. Backbone starts out at
1/10 but complexity grows linearly. This is a natural side effect of the types
of applications the two frameworks were specifically created for.

Let's unpack our new code, in reverse:

```javascript
index: Ember.Route.extend({
  route: '/',
  connectOutlets: function(router){
    router.get('applicationController').connectOutlet('allContributors', [{login:'wycats'},{login:'tomdale'}]);
  }
})
```

When your application is loaded at the url `'/'`, Ember will automatically
transition the application into the state I've called `index`. `connectOutlets`
is called on this state. It acts as a callback for us to connect sections of our
view hierarchy (designated with `{% raw %}{{outlet}}{% endraw %}`) to specific views based on the
state. In this case I want to connect the `{% raw %}{{outlet}}{% endraw %}` in our application
template with markup for all our contributors so I access the application's
single shared instance of `ApplicationController` and call `connectOutlet` on
it with `'allContributors'` as an argument.

When our application is `initialize`ed, a single shared instance of each
controller is created for us. Because you'll most likely access this instance
from the router, it's placed as a property of the router with a name that
matches the controller's classname but converted to lower-camel style:
`ApplicationController`'s single instance is stored as `applicationController`.

Controllers have the ability to connect outlets in the views they control. In the
above example, I'm calling `connectOutlet` with `'allContributors'` as an argument.
This will create an instance of `AllContributorsView` for us, set the shared instance of
`AllContributorsController` as the view's default rendering context, and insert
it into our view hierarchy at the point where `{% raw %}{{outlet}}{% endraw %}` appears in the
application template. The second argument, which I've hard coded as an array of
two object literals, is set as the `content` of the controller instance. (Those
who fear this kind of "magic" are free to read the documentation for Controllers
to see the full, maximally verbose and explicit arguments you can pass).

```javascript
App.AllContributorsController = Ember.ArrayController.extend();
App.AllContributorsView = Ember.View.extend({
  templateName: 'contributors'
});
```

The `AllContributorsController` is a subclass of Ember's `ArrayController` class.
`ArrayController`s acts as containers for any array-like object in Ember and
simply proxy undefined properties or methods to the underlying `content` array.

In our template, the each call (`{% raw %}{{each person in controller}}{% endraw %}`) is passed along
to the `content` of our ArrayController which I've hard-coded as an array of two
object literals with a single property each.

```
<script type="text/x-handlebars" data-template-name="contributors">
  {% raw %}{{#each person in controller}}{% endraw %}
    {% raw %}{{person.login}}{% endraw %}
  {% raw %}{{/each}}{% endraw %}
</script>
```

## Loading External Data
Ember gets a lot of flack for it's lack of "a persistence layer" when compared
to Backbone or Batman. I've never thought of this as fair criticism because I
don't think of thin wrappers around `$.ajax()` that follow a Rails-style-REST
pattern really merit the "persistence layer" label. And many other frameworks
are starting to realize this too as their thin `$.ajax()` delegation is being
fleshed out to handle the [real and difficult problems of reliably synchronizing
data between two environments when there are few structural standards to rely
on](https://plus.google.com/u/0/106300407679257154689/posts/Hv6xvZsuBBF).

The real, valid criticism is that nobody who knows Ember has offered much
guidance for how to handle data loading within an Ember application. Ember, as
I'm trying to convince you, has valuable patterns you've never used before and
it's totally unfair to maintain this assertion while simultaneously expecting
you to know how to combine these patterns with data loading solutions you've
previously used.

The best advice I can offer is: always be returning.

Ember relies on the immediate availability of data objects even if the
underlying content of those objects is still loading. This is almost certainly
different than asynchronous patterns for data loading you've used
before. Let's step through how this works, one concern at a time.

In our application so far, I've punted on data and just hard coded something
into our index state:


```javascript
index: Ember.Route.extend({
  route: '/',
  connectOutlets: function(router){
    router.get('applicationController').connectOutlet('allContributors', [{login:'wycats'},{login:'tomdale'}]);
  }
})
```

I'd much prefer to delegate that data loading out to a proper object. Let's call
to a – as yet unimplemented – `Contributor` class and a `find` method on that class:


```javascript
index: Ember.Route.extend({
  route: '/',
  connectOutlets: function(router){
    router.get('applicationController').connectOutlet('allContributors', App.Contributor.find());
  }
})
```


And now implement this object:

```javascript
App.Contributor = Ember.Object.extend();
App.Contributor.reopenClass({
  find: function(){}
});
```

This creates a new class and reopens that class to add class (sometimes called
'static') method:

If you reload your application you'll see that nothing renders now. This is
because we've set the `content` of our `AllContributorsController` to undefined
which is the default return value of our new `find` method. Let's apply some
`$.ajax` to the method:


```javascript
App.Contributor.reopenClass({
  find: function(){
    $.ajax({
      url: 'https://api.github.com/repos/emberjs/ember.js/contributors',
      dataType: 'jsonp',
      success: function(response){
        return response.data;
      }
    })
  }
});
```

Reload your application and you'll see there is still no change because,
although we request data, `find` still has no return value. It's here that
people usually code themselves into a corner trying to get their previous
experience with ajax to fit into Ember patterns, give up, and post a
StackOverflow question.

There are a few solutions to this problem but the easiest for us now is to just
make sure we're returning an array:


```javascript
App.Contributor.reopenClass({
  allContributors: [],
  find: function(){
    $.ajax({
      url: 'https://api.github.com/repos/emberjs/ember.js/contributors',
      dataType: 'jsonp',
      context: this,
      success: function(response){
        response.data.forEach(function(contributor){
          this.allContributors.addObject(App.Contributor.create(contributor))
        }, this)
      }
    })
    return this.allContributors;
  }
});
```

I've changed `find` to immediately return an array (`this.allContributors`) which
starts out empty. This will become the `content` of our controller, which is the
default rendering context for the view. When the view first renders it will loop
over the empty array and insert nothing into the page. When the ajax call is
successful we loop through the response from the server turning each chunk
of JSON into an instance of our `Contributor` class, and add it to the array.
Ember's property notification system will trigger a view re-render for just the
affected sections of the page.

Because Ember has a good property observation system we can handle the
asynchronicity from multiple points within the application structure where it's
most appropriate rather than being forced to handle it at the communication
layer.

If you reload the application you'll see an empty page before the view updates
when the data is loaded. If we were writing a slightly more complex application,
we could use a library by the core team called [Ember
Data](https://github.com/emberjs/data) that would help with functionality like
binding loading state to view display. It has far more ambitious goals than
we'll need for demonstration: stateful data synchronization, property encoding
and decoding, identity mapping, transactional communication, and more.

## Transitioning Between States
With data in hand, we can now allow users to transition between the state where
they see all contributors to a state where they see just one contributor. Our
current router looks like this

```javascript
App.Router = Ember.Router.extend({
  root: Ember.Route.extend({
    index: Ember.Route.extend({
      route: '/',
      connectOutlets: function(router){
        router.get('applicationController').connectOutlet('allContributors', App.Contributor.find());
      }
    })
  })
});
```

We'll add a sibling state to index for viewing just a single contributor. I'm
also going to rename 'index' to the more descriptive state name of
'contributors':


```javascript
App.Router = Ember.Router.extend({
  root: Ember.Route.extend({
    contributors: Ember.Route.extend({
      route: '/',
      connectOutlets: function(router){
        router.get('applicationController').connectOutlet('allContributors', App.Contributor.find());
      }
    }),

    aContributor: Ember.Route.extend({
      route: '/:githubUserName',
      connectOutlets: function(router, context){
        router.get('applicationController').connectOutlet('oneContributor', context);
      }
    })

  })
});
```

Examining this new state in isolation:

```javascript
aContributor: Ember.Route.extend({
  route: '/:githubUserName',
  connectOutlets: function(router, context){
    router.get('applicationController').connectOutlet('oneContributor', context);
  }
})
```

I've supplied a `route` property of `'/:githubUserName'`, which we'll use later
to serialize and deserialize this state. I've implemented the `connectOutlets`
method with two arguments: one to represent the entire router and one, called
`context`, which will help answer the question "_which_ contributor" later on.
Inside `connectOutlets` I've accessed the shared instance of
`ApplicationController` and used it to connect the outlet in its view (an
instance of `ApplicationView`) to a pairing of
`OneContributorView`/`OneContributorController`, which are unimplemented.

Next, we'll update the application template to include a way for users to change
the application's state from 'contributors' to 'aContributor' through
interaction. Currently our template just loops and prints the `login` property
of each contributor:

```
<script type="text/x-handlebars" data-template-name="contributors">
  {% raw %}{{#each person in controller}}{% endraw %}
    {% raw %}{{person.login}}{% endraw %}
  {% raw %}{{/each}}{% endraw %}
</script>
```

We're going to encase that login in an `<a>` tag that includes a call to the `{% raw %}{{action}}{% endraw %}` helper:


```
<script type="text/x-handlebars" data-template-name="contributors">
  {% raw %}{{#each person in controller}}{% endraw %}
    <a {% raw %}{{action showContributor person}}{% endraw %}> {% raw %}{{person.login}}{% endraw %} </a>
  {% raw %}{{/each}}{% endraw %}
</script>
```

The `{% raw %}{{action}}{% endraw %}` helper goes _within_ the opening tag of an element (here, the
`<a>`) and takes two arguments. The first, `showContributor`, is the action we'd
like to send to the current state of the application and the second, `person`,
will become the `context` argument passed through various callbacks in the
application's router.

If you reload the application now you'll see that our logins have become links.
With your console enabled, click any of the links. You'll see a warning that
your application's router 'could not respond to event showContributor in state
root.contributors'.

Add this transition action to the 'contributors' state. I like to put my actions
between route property definition and route API callbacks like
`connectOutlets`:


```javascript
contributors: Ember.Route.extend({
  route: '/',

  showContributor: Ember.Route.transitionTo('aContributor'),

  connectOutlets: function(router){
    router.get('applicationController').connectOutlet('allContributors', App.Contributor.find());
  }
})
```


The new action is written for us by the static method `transitionTo` on
the `Ember.Route` class. You can write your transitions yourself (they're just
functions), but `Ember.Route.transitionTo` saves you trouble of hand-writing
a lot of similar looking functions.

Pop back to the browser, reload the application, and try to transition again.
This time, you'll be warned that we're missing our `OneContributorView` class.
The transition has occurred and we've reached the `connectOutlets` callback
on the 'aContributor' state, but cannot properly connect our outlet yet without
the missing view class.

Implement this class and matching controller and template:

```javascript
App.OneContributorView = Ember.View.extend({
  templateName: 'a-contributor'
});
App.OneContributorController = Ember.ObjectController.extend();
```
```
// in your HTML document
<script type="text/x-handlebars" data-template-name="a-contributor">
  {% raw %}{{login}}{% endraw %} - {% raw %}{{contributions}}{% endraw %} contributions to Ember.js
</script>
```

I've made `OneContributorController` an instance of `Ember.ObjectController`.
`ObjectController` is like `ArrayController` – a tiny wrapper for objects that will
just proxy property and method access to its underlying `content` property – but
for single objects instead of collections.

If you reload the application and try to transition you should have more
success. It might be handy to enable logging on your router to get a better feel
for what is happening on transitions:

```javascript
App.Router = Ember.Router.extend({
   enableLogging: true,
   // other properties added earlier
})
```

Let's unpack what's going on when we click that link. Ember has registered
listener on the `<a>` element for you (so, no, this is nothing like going back
to _ye olde onclick_ days) that will call the matching action name
(`showContributor`) on the `target` property of the view. It just so happens
that the default target for any view is the application's router.

The router will delegate this action name to the current state. If the action is
present on the state, it will be called with the object you provided as the
second argument to `{% raw %}{{action}}{% endraw %}` as a context argument. If it's not present, the
router will walk up through the state tree towards `root` looking for a matching
action name.

Since our state _does_ have a matching name,
`showContributor: Ember.Route.transitionTo('aContributor')`, it's called. This function
transitions the router to the name state ('aContributor') and calls its
`connectOutlets` callback with the router as the first argument and the context
from the `{% raw %}{{action}}{% endraw %}` helper as the second argument:

```javascript
connectOutlets: function(router, context){
  router.get('applicationController').connectOutlet('oneContributor', context);
}
```

Within this method, we access the single shared instance of
`ApplicationController` and connect the outlet in its view (an instance of
`ApplicationView`) by inserting an instance of `OneContributorView` with the
single shared instance of `OneContributorController` as its default rendering
context.

The `content` property of this controller is set to the passed `context`
argument. Since `OneContributorController` is a descendant of
`ObjectController`, property access in the view will proxy through the
controller to this `content`.

The view renders and we see our updated view hierarchy in the browser.

## Serializing and Deserializing States
Observant readers will notice that, although we supplied a `route: '/:githubUserName'`
property on our current state, the URL displayed
in the browser has updated to a value of '#/undefined'. I mentioned
earlier that URLs were just a pleasant side effect of state changes
but we haven't talked about serializing and deserializing states yet.

After an application state is entered and `connectOutlets` has been called, the
router will call `serialize` on the state with the router itself as the first
argument and the current context as the second argument. There is a default
implementation of `serialize` that does property lookup on the context using any
dynamic slugs in the supplied `route` property as keys.

To have serialization work we can either update our `route` to include dynamic
slugs that match known properties on the object or implement our own custom
method.


```javascript
aContributor: Ember.Route.extend({
  route: '/:githubUserName',
  connectOutlets: function(router, context){
    router.get('applicationController').connectOutlet('oneContributor', context);
  },
  serialize: function(router, context){
    return {
      githubUserName: context.get('login')
    }
  }
})
```

The return value from a custom `serialize` method must be an object literal with
keys that match any dynamic slugs in the supplied `route`. The value for these
keys will be placed in the url.

Browse back to the root state of your application (i.e. go back to '/'),
reload the application, and navigate back to the 'aContributor' state for any
contributor. The url should update properly.

Unfortunately if you reload the application at this particular state you'll see
the URL updates to '#/undefined' again.

When we load an Ember application at a particular url it will attempt to match
and transition into a state with matching `route` pattern and call the state's
`connectOutlets` and `serialize` callbacks. When we reload at '#/kselden', for
example, The router matches to the state with the `route` pattern of
'/:githubUserName', transitions into it, then calls `connectOutlets` with the
router as the first argument and a second argument of ... no context at all.
Finally, `serialize` is called, also with an `undefined` context, and the
property `githubUserName` is accessed on `undefined` and the URL is updated to
'#/undefined'.

Entering the application at a particular URL doesn't give our application access
to previous loaded data so to fully load the matching state, we need to
re-access this data. States have a callback `deserialize` for doing just this.
There's a default implementation, but we can implement our own custom one as
well:


```javascript
aContributor: Ember.Route.extend({
  route: '/:githubUserName',
  connectOutlets: function(route, context){
    router.get('applicationController').connectOutlet('oneContributor', context);
  },
  serialize: function(router, context){
    return {githubUserName: context.get('login')}
  },
  deserialize: function(router, urlParams){
    return App.Contributor.findOne(urlParams.githubUserName);
  }
})
```


Above, I've mocked out what I want this deserialization interface to look like.
I'll call `App.Contributor.findOne` with the section of our url represented by
`githubUserName` and return this object. The return value of `deserialize`
becomes the `context` passed to `connectOutlets`, so I must immediately return
an object that will get populated with data later. Let's add
`App.Contributor.findOne` to allow for passing a Github user name.

Github allows us to access a user at '/users/*a name*', but this isn't within
the context of a particular repository, so we won't have access to this users
contribution count, which is part of the data we need. To see a particular
users in the context of a repository we'll need to load them all and locally
find the one we're looking for. This isn't exactly ideal, but unless you
control development of both client and server it's typical.


```javascript
findOne: function(username){
  var contributor = App.Contributor.create({
    login: username
  });

  $.ajax({
    url: 'https://api.github.com/repos/emberjs/ember.js/contributors',
    dataType: 'jsonp',
    context: contributor,
    success: function(response){
      this.setProperties(response.data.findProperty('login', username));
    }
  })

  return contributor;
}
```

The order of execution for this method is: create a new `Contributor` object with
`login` set immediately to the known value passed in as `username` from within
the 'aContributor' states's deserialize method. Then we set up some ajax and
immediately return the `Contributor` instance. When the ajax completes we find
just the contributor we're interested in by looking for the first result with a
a matching username (using `findProperty`) and update the returned `Contributor`
instance's properties with `setProperties`, which will trigger a view update of
any sections bound to properties whose values have changed.

## Repeat
That's an Ember application. States, transitioning between them, and
loading data when you need it. You can build up surprisingly sophisticated and
robust UIs by repeating this process until you're happy. Let's repeat this by
add a "back to all contributors" navigation to our template for a single contributor:

Right now the template is pretty simple:

```
<script type="text/x-handlebars" data-template-name="a-contributor">
  {% raw %}{{login}}{% endraw %} - {% raw %}{{contributions}}{% endraw %} contributions to Ember.js
</script>
```

Let's add an element with an action to transition back to the 'contributors'
state:

```
<script type="text/x-handlebars" data-template-name="a-contributor">
  <div>
    <a {% raw %}{{action showAllContributors}}{% endraw %}>All Contributors</a>
  </div>
  {% raw %}{{login}}{% endraw %} - {% raw %}{{contributions}}{% endraw %} contributions to Ember.js
</script>
```

Add this action to the 'aContributor' state:

```javascript
aContributor: Ember.Route.extend({
  route: '/:githubUserName',

  showAllContributors: Ember.Route.transitionTo('contributors')

  // ... remainder of this object's properties
})
```

Done.

Nested states are possible and encouraged as well. They come with only one
caveat: you must end the transition between states on state that is a 'leaf'
(i.e. has no child states of its own). As you convert states into more complex
sets of nested states, either remember to directly transition to one of the
child states or set an `initialState` property.

Let's convert our simple 'aContributor' state into a more complex object with
two child states. The parent 'aContributor' we'll use for fetching a contributor
and displaying her name and number of commits. Then we'll provide two nested
states: one – 'details' – for viewing additional details about the contributor
and a second – 'repos' – for showing a list of their repositories.

For reference, the 'aContributor' state looks like this:

```javascript
aContributor: Ember.Route.extend({
  route: '/:githubUserName',
  connectOutlets: function(router, context){
    router.get('applicationController').connectOutlet('oneContributor', context);
  },
  serialize: function(router, context){
    return {githubUserName: context.get('login')}
  },
  deserialize: function(router, urlParams){
    return App.Contributor.findOne(urlParams.githubUserName);
  },
})
```

And we'll change it to this:

```javascript
aContributor: Ember.Route.extend({
  route: '/:githubUserName',
  connectOutlets: function(router, context){
    router.get('applicationController').connectOutlet('oneContributor', context);
  },
  serialize: function(router, context){
    return {githubUserName: context.get('login')}
  },
  deserialize: function(router, urlParams){
    return App.Contributor.findOne(urlParams.githubUserName);
  },

  // child states
  initialState: 'details',
  details: Ember.Route.extend({
    route: '/',
    connectOutlets: function(router){
      router.get('oneContributorController').connectOutlet('details');
    }
  }),
  repos: Ember.Route.extend({
    route: '/repos',
    connectOutlets: function(router){
      router.get('oneContributorController').connectOutlet('repos');
    }
  })
})
```

Examining each state in isolation:


```javascript
initialState: 'details',
details: Ember.Route.extend({
  route: '/',
  connectOutlets: function(router){
    router.get('oneContributorController').connectOutlet('details');
  }
})
```

When we transition into 'aContributor', its callbacks (`connectOutlets`,
`serialize`, optionally `deserialize` if we're transitioning during application
load) are called. This means the `{% raw %}{{outlet}}{% endraw %}` in our application template is
filled with an instance of `OneContributorView` with the shared instance of
`OneContributorController` used as its default rendering context. The `context`
argument is passed from the `{% raw %}{{action showContributor contributor}}{% endraw %}`, through
the transition, and into this callback. We then pass it along as the second
argument to `connectOutlet` and it becomes the `content` property of the shared
`OneContributorController` instance.

Then, because we have `initialState` defined the router immediately transitions
into the state 'aContributor.details' and calls its `connectOutlets` callback:

```javascript
connectOutlets: function(router){
  router.get('oneContributorController').connectOutlet('details');
}
```

In this callback we're connecting an `{% raw %}{{outlet}}{% endraw %}` that we'll place inside the
template for a contributor (yes, outlets can be nested inside other outlets as
deeply as you'd like to). Go ahead and change


```
<script type="text/x-handlebars" data-template-name="a-contributor">
  <div>
    <a {% raw %}{{action showAllContributors}}{% endraw %}>All Contributors</a>
  </div>
  {% raw %}{{login}}{% endraw %} - {% raw %}{{contributions}}{% endraw %} contributions to Ember.js
</script>
```

to

```
<script type="text/x-handlebars" data-template-name="a-contributor">
  <div>
    <a {% raw %}{{action showAllContributors}}{% endraw %}>All Contributors</a>
  </div>
  {% raw %}{{login}}{% endraw %} - {% raw %}{{contributions}}{% endraw %} contributions to Ember.js

  <div>
    {% raw %}{{outlet}}{% endraw %}
  </div>
</script>
```


And add `DetailsView` and template. You can skip creating a `DetailsController`.
In the absence of a controller with a matching name, Ember will just use the
rendering context of the parent template, which in our case is the shared
instance of `OneContributorController` with its `context` property already set
to the contributor we're interested in:


```javascript
App.DetailsView = Ember.View.extend({
  templateName: 'contributor-details'
})
```

```
<script type="text/x-handlebars" data-template-name="contributor-details">
  <p>{% raw %}{{email}}{% endraw %}</p>
  <p>{% raw %}{{bio}}{% endraw %}</p>
</script>
```

Reload the app and navigate to the 'aContributor.details' state by clicking on a
Github username. If you have `enableLogging` on for your router you'll see we've
successfully transitioned into the state but are missing the `email` and `bio`
data. Unfortunately, these properties are not part of the contributor data that
comes from Github. We'll need to trigger a call to Github when we enter this
state to fetch additional details. Let's stub out a call to this in the
`connectOutlets` for 'aContributor.details':


```javascript
connectOutlets: function(router){
  router.get('oneContributorController.content').loadMoreDetails();
  router.get('oneContributorController').connectOutlet('details');
}
```

And add this method to our `Contributor` model:

```javascript
App.Contributor = Ember.Object.extend({
  loadMoreDetails: function(){
    $.ajax({
      url: 'https://api.github.com/users/%@'.fmt(this.get('login')),
      context: this,
      dataType: 'jsonp',
      success: function(response){
        this.setProperties(response.data);
      })
    })
  }
});
```

Now when we enter this state we'll trigger a call to load more data from Github,
immediately render the view, and the view will automatically update when
additional properties eventually have values. You can now reload the application
and transition to this state again to see the updated view.

What about transitioning between our 'aContributor.details' and
'aContributor.repos' state? This should begin to look boringly familiar soon.
Update our view to provide some navigational elements. Currently it looks like
this:

```
<script type="text/x-handlebars" data-template-name="a-contributor">
  <div>
    <a {% raw %}{{action showAllContributors}}{% endraw %}>All Contributors</a>
  </div>
  {% raw %}{{login}}{% endraw %} - {% raw %}{{contributions}}{% endraw %} contributions to Ember.js

  <div>
    {% raw %}{{outlet}}{% endraw %}
  </div>
</script>
```

And after we've added two actions:

```
<script type="text/x-handlebars" data-template-name="a-contributor">
  <div>
    <a {% raw %}{{action showAllContributors}}{% endraw %}>All Contributors</a>
  </div>
  {% raw %}{{login}}{% endraw %} - {% raw %}{{contributions}}{% endraw %} contributions to Ember.js

  <ul>
    <li><a {% raw %}{{action showDetails}}{% endraw %}>Details</a></li>
    <li><a {% raw %}{{action showRepos}}{% endraw %}>Repos</a></li>
  </ul>

  <div>
    {% raw %}{{outlet}}{% endraw %}
  </div>
</script>
```

Create the new transitions. I've placed them both within the 'aContributor'
state itself:


```javascript
  aContributor: Ember.Route.extend({
    showDetails: Ember.Route.transitionTo('details'),
    showRepos: Ember.Route.transitionTo('repos')

   // ... remainder of the state's properties ...//
  })
```

Now we can toggle between the two states. The `aContributor.repos` state will
throw an error because we're missing `ReposView`, which Ember is attempting to
find because of our `connectOutlet` call on router's `oneContributorController`:


```javascript
  connectOutlets: function(router){
    router.get('oneContributorController').connectOutlet('repos')
  }
```

Add the view and a template, again skipping the `ReposController` which will use
the shared `OneContributorController` instance as the rendering context for this
view:


```javascript
  App.ReposView = Ember.View.extend({
    templateName: 'repos'
  })
```
```
  <script type="text/x-handlebars" data-template-name="repos">
    {% raw %}{{#each repo in repos}}{% endraw %}
       {% raw %}{{repo.name}}{% endraw %}
    {% raw %}{{/each}}{% endraw %}
  </script>
```

For the view I've just looped through the `repos` property of this view's
rendering context, the shared `OneContributorController`.
`OneContributorController` is an subclass of `ObjectController`, so this `repos`
lookup is proxied along to the controller's `content` property. The `content`
is an instance of `App.Contributor` we've passed along through the
`{% raw %}{{action}}{% endraw %}`, transition, and `connectOutlets` callback.


Reload the application, navigate back to this state, and you'll see a sad dearth
of repos. As with 'aContributor.details' we need to request the appropriate data
to display. Update the `connectOutlets` of 'aContributor.details' to include a
stubbed method for fetching repos:

```javascript
  connectOutlets: function(router){
    router.get('oneContributorController.content').loadRepos();
    router.get('oneContributorController').connectOutlet('repos');
  }
```

And implement this method on our `App.Contributor` model:

```javascript
  App.Contributor = Ember.Object.extend({
    loadRepos: function(){
      $.ajax({
        url: 'https://api.github.com/users/%@/repos'.fmt(this.get('login')),
        context: this,
        dataType: 'jsonp',
        success: function(response){
          this.set('repos',response.data);
        }
      });
    },
    // other methods previously written
  })
```

Like our data retrieval in 'aContributor.details' we now transition into the
'aContributor.repos' state, trigger data retrieval and immediately update our
views. Once the data loading is complete, the view should automatically update
to reflect the new value of our `repos` property.

Reader [@sly7_7](http://github.com/sly7_7) put together [a jsFiddle of the
completed example](http://jsfiddle.net/Sly7/ZKXyg/).

## Repeat, Repeat, Repeat
You'll be surprised how quickly you can express very advanced UIs by just
repeating this pattern. More importantly, your UIs will be crazy robust. The
framework creates a small number of bindings and cleans them up when connections
change. Views tear themselves down and release memory automatically. Judicious
separation of states ensures users can't accidentally navigate into frustrating
edge case scenarios.

When your applications gets a bit larger than this example, start exploring
[Ember Data](https://github.com/emberjs/data) to cut down the number of
unnecessary ajax calls (and, more importantly, hide this interaction behind a
nice API).

You made it through all my ranting and odd turns of phrase, so I'll share
my [secret](https://twitter.com/trek/status/239063773846052864) vision
for Ember: I want Ember to be a gateway drug for good UI
engineering the way Rails was for good application development. You may
scoff – "Rails is bloated, I prefer express.js" – but express is just
stealing the best tricks from years of battle tested Rails experimentation.

Rails turned many of us from dabblers into developers and Ember
has that same feel of _rightness_ for me that Rails did in 2004.
You might reject Ember, but I hope it's after you've toyed with
it and built something serious so you can reject it for substantive
reasons or informed aesthetics, not simply because it seemed
odd, new, or frighteningly different.

> Copy-editing and proofing graciously provided by
> [@frodsan](https://twitter.com/frodsan),
> [@patrickbaselier](https://twitter.com/patrickbaselier), and
> [@edimoldovan](https://twitter.com/edimoldovan).
> Remaining foolish errors or omissions are mine.
