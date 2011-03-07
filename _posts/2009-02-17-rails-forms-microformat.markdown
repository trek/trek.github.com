--- 
layout: post
title: Rails Forms microformat
---
<p><strong>This article has been updated to reflect the latest patterns in Rails 2.3 edge (based mostly on <a href='http://github.com/rails/rails/commit/5dbc9d40a49f5f0f50c2f3ebe6dda942f0e61562'>this commit</a></strong>)</p>
<p>If you've been relying on Rails form helpers to generate forms, then you may have missed the interesting little microformat used to pass application data to and fro. In case you didn't know, form data is passed as part of the request body as a set of key/values pairs in plain text (if you're using <code>get</code> as a method for a form, it's that url section like this: <code>?name=widget12&amp;price=22</code>). The <code>name</code> attribute of the form inputs are the keys (here <code>name</code> and <code>price</code>), and the value is whatever the user entered or selected (<code>widget12</code> and <code>22</code>).</p>

<p>Most languages/frameworks for the web will reconstitute these pairs as objects accessible to the programmer.</p>

<p>For example</p>

<pre><code>&lt;input name='widget_name' /&gt;
</code></pre>

<p>is accessed with <code>$_POST["widget_name"]</code> in php, <code>self.request.get("widget_name")</code> on App Engine, and <code>params[:widget_name]</code> in Rails.</p>

<p>This format can only pass a single value for a key, so it can't represent complex data structures like hashes and arrays.  With single values in Rails, our controllers would be like this:</p>

<pre><code>def create
  @widget = Widget.new
  @widget.name  = params[:name]
  @widget.price = params[:price]
  @widget.save!
rescue ActiveRecord::RecordInvalid
  self.render('new') # Rails 2.3 version of self.render({:action =&gt; 'new'})
end
</code></pre>

<p>We'd have one <code>@widget.some_name = params[:some_name]</code> per attribute we wanted to pass.  As far as I can tell, this is what programmers in PHP/App Engine/etc mostly do.  In Rails, however, we typically use</p>

<pre><code>def create
  @widget = Widget.new(params[:widget])
  ...
end
</code></pre>

<p>and Rails auto assigns attributes correctly for us. If you've never examined the output of your helpers you may not know how this happens.  Although we can only send <code>key=value</code> over the tubes, Rails is designed to parse this string looking for specific formatting and convert certain patterns into more complex data strictures. Basically, it's a <a href="http://microformats.org/">microfrmat</a> for form inputs.</p>

<p>This parsing is handled by a <a href="http://rack.rubyforge.org/">rack</a> middleware <code>ActionController::ParamsParser</code> in Rails 2.3+, so it's a trick that could technically be available to any rack-based ruby application.</p>

<p>Having a hash accessible via <code>params[:widget]</code> occurs because all of the inputs for a widget are named with the format <code>"widget[some_attr]"</code>.  When Rails sees multiple inputs with names in this pattern, it sticks them all into a single data structure.</p>

<p>So if</p>

<pre><code>&lt;input name='name' /&gt;
&lt;input name='price' /&gt;
</code></pre>

<p>becomes</p>

<pre><code># params
{
  :name =&gt; 'widget12,
  :price =&gt; '22'
}
</code></pre>

<p>then</p>

<pre><code>&lt;input name='widget[name]'  /&gt;
&lt;input name='widget[price]' /&gt;
&lt;input name='somethingelse[attr1]' /&gt;
&lt;input name='somethingelse[attr2]' /&gt;
</code></pre>

<p>is converted to </p>

<pre><code># params
{
  :widget =&gt; {:name =&gt; 'widget12, :price =&gt; '22'},
  :somethingelse =&gt; {:attr1 =&gt; '', :attr2 =&gt; ''}
}
</code></pre>

<p>Even with the text-to-hash parsing we could still do data assignment long-hand</p>

<pre><code>def create
  @widget = Widget.new
  @widget.name  = params[:widget][:name]
  @widget.price = params[:widget][:price]
  ...
end
</code></pre>

<p>However, since <code>ActiveRecord::Base.new</code> takes an optional hash argument we can shorten it to <code>Widget.new(params[:widget])</code></p>

<p>That's nifty, but Rails Forms (<code>rForms</code> maybe?) can do much more.  Take a gander at these patterns:</p>

<h3>Nested Hashes</h3>

<pre><code>&lt;!-- form.html --&gt;
&lt;input name='foo[bar][attr1]' value='A'&gt;
&lt;input name='foo[bar][attr2]' value='B'&gt;
</code></pre>

<p></p>

<pre><code># FoosController#some_action
# params
{:foo =&gt; {
    :bar =&gt; {
      :attr1 =&gt; 'A', :attr2 =&gt; 'B'
    }
  }
}
</code></pre>

<h3>Deeply Nested Hashes</h3>

<pre><code>&lt;!-- form.html --&gt;
&lt;input name='foo[qux]' value='I am the qux'&gt;
&lt;input name='foo[bar][baz][attr1]' value='A'&gt;
&lt;input name='foo[bar][baz][attr2]' value='B'&gt;
</code></pre>

<p></p>

<pre><code># FoosController#some_action
# params
{:foo =&gt; {
    :qux =&gt; "I am the qux",
    :bar =&gt; {
       :baz =&gt;
          :attr1 =&gt; 'A', :attr2 =&gt; 'B'
       }
    }
  }
}
</code></pre>

<h3>Arrays</h3>

<p>If you have <code>[]</code> without text inside of it as the final characters of the name attribute, you'll get an array on the other end:</p>

<pre><code>&lt;!-- form.html --&gt;
&lt;input name='foo[baz]', value='the baz' /&gt;
&lt;input name='foo[many_bars][]' value='bar 3' /&gt;
&lt;input name='foo[many_bars][]' value='bar 2' /&gt;
&lt;input name='foo[many_bars][]' value='bar 1' /&gt;
&lt;input name='foo[many_bars][]' value='bar none' /&gt;
</code></pre>

<p></p>

<pre><code># FoosController#some_action
# params
{:foo =&gt; {
    :baz =&gt; "the baz",
    :many_bars =&gt; ["bar 3","bar 2","bar 1", "bar none"]
}
</code></pre>

<h3>Arrays in a hash</h3>

<pre><code>&lt;!-- form.html --&gt;
&lt;input name='foo[qux][corge]'      value='the corge' /&gt;
&lt;input name='foo[qux][graults][]'  value='grault 1' /&gt;
&lt;input name='foo[qux][graults][]'  value='grault 2' /&gt;
&lt;input name='foo[qux][graults][]'  value='grault 3' /&gt;
</code></pre>

<p></p>

<pre><code># FoosController#some_action
# params
{:foo =&gt; {
    :qux =&gt; {
      :corge =&gt; 'the corge',
      :graults =&gt; ["grault 1", "grault 2", "grault 3"]
    }
}
</code></pre>

<h2>Using It</h2>

<p>Now that you've seen the the basics of structuring the format, how can we use it to do complex data manipulations in the UI and keep the same tiny <code>@object = ClassName.new(params[:something])</code> or <code>@object = ClassName.find(params[:id]).update_attributes!(params[:something])</code> snippets in our controller?  Let&#8217;s examine <code>belongs_to</code> as an exemplar:</p>

<h3><code>belongs_to</code></h3>

<p>Assuming the following classes</p>

<pre><code>class Widget &lt; ActiveRecord::Base
  belongs_to :creator
end

class Creator &lt; ActiveRecord::Base
  has_many :widgets
end
</code></pre>

<p>The simplest way to create a <code>Widget</code> and assign a <code>creator</code> is with a form like this:</p>

<pre><code>&lt;!-- form.html --&gt;
&lt;input name='widget[name]' &gt;
&lt;input name='widget[price]' &gt;
&lt;input name='widget[creator_id]' &gt;
</code></pre>

<p></p>

<pre><code># WidgetsController#create
# params
{:widget =&gt;
  {
    :name =&gt; 'widget 10',
    :price =&gt; '22',
    :creator_id =&gt; '971'
  }
}
</code></pre>

<p>And a single form can do attribute assignment and object association (nb: just for demonstration purposes. Doing this with nested routes and calls to <code>Creator#.widgets.build(params[:widget])</code> is probably more idiomatic and secure).</p>

<h4>create new object, new <code>belongs_to</code></h4>

<p>But that only works for an existing <code>Creator</code> object (we need the <code>id</code>).  What if we wanted to make a new <code>Widget</code> and associate a new <code>creator</code> all at once?  The first step is to tell our model we&#8217;ll be expecting nested attributes for assignment.  We do this by adding <code>accepts_nested_attributes_for(:relationship_name)</code> where <code>:relationship_name</code> is the name of our relationship (in Rails 2.3 and above).</p>

<p>Go ahead and change</p>

<pre><code>class Widget &lt; ActiveRecord::Base
  belongs_to :creator
end
</code></pre>

<p>to</p>

<pre><code>class Widget &lt; ActiveRecord::Base
  belongs_to :creator
  accepts_nested_attributes_for :creator
end
</code></pre>

<p>Now our <code>Widget</code> objects have a method <code>creator_attributes</code> (the pattern here is <em>relationship_name</em>_attributes).  This method takes a hash and will loop through the hash&#8217;s key, assigning values to a nested object.  We know that, from the examples above, we can create nested hashes with input names like <code>foo[bar][baz]</code>.  </p>

<p>Our inputs for single-form widget/creator making will look like this:</p>

<pre><code>&lt;!-- form.html --&gt;
&lt;input name='widget[name]' &gt;
&lt;input name='widget[price]' &gt;

&lt;input name='widget[creator_attributes][name]' &gt;
&lt;input name='widget[creator_attributes][height]' &gt;
</code></pre>

<p></p>

<pre><code># WidgetsController#create
# params
{:widget =&gt;
  {
    :name =&gt; 'widget 10',
    :price =&gt; '22',
    :creator_attributes =&gt; {
      :name =&gt; 'John McInventorson',
      :height =&gt; '121'
    }
  }
}
</code></pre>

<p>Passing <code>params[:widget]</code> to a <code>Widget.create</code> will create both a new <code>Widget</code> object, a new <code>Creator</code> object, and will associate the two.</p>

<h4>update existing object, update existing <code>belongs_to</code></h4>

<p>However, if we use that same form later to do an update for the <code>Widget</code> and the <code>creator</code>, we <em>will overwrite</em> the original creator object. For example:</p>

<pre><code># script/console
params = {
  :id =&gt; 4,
  :widget =&gt; {
    :name =&gt; 'widget 10',
    :price =&gt; '22',
    :creator_attributes =&gt; {
      :name =&gt; 'John McInventorson',
      :height =&gt; '121'
    }
  }
}
@widget = Widget.find(params[:id])
@widget.creator.id # =&gt; 12
@widget.update_attributes!(params[:widget])
@widget.creator.id # =&gt; 92 # OVERWRITTEN!
</code></pre>

<p>Why is this? Part of the difficult in doing multiple objects in a single form is signaling <em>intent</em>.  When you send <code>_attribute</code> data along with attributes of some base object, which of the following intents does that signal to application?</p>

<ul>
<li>create a new associated object</li>
<li>update an existing associated object, creating one if it doesn&#8217;t exist</li>
</ul>

<p>It can only have a single meaning; Rails chooses, in this case, to create and associate a <em>new</em> related object.  We can signal our intent to update the attributes of the <em>existing</em> associated object by including its <code>id</code> attribute in the <code>_attributes</code> hash.</p>

<pre><code>    &lt;!-- form.html --&gt;
    &lt;input name='widget[name]' &gt;
    &lt;input name='widget[price]' &gt;

    &lt;input name='widget[creator_attributes][id]' &gt;
    &lt;input name='widget[creator_attributes][name]' &gt;
    &lt;input name='widget[creator_attributes][height]' &gt;
</code></pre>

<p></p>

<pre><code>    # WidgetsController#update
    # params
    {:widget =&gt;
      {
        :name =&gt; 'widget 10',
        :price =&gt; '22',
        :creator_attributes =&gt; {
          :id =&gt; 12,
          :name =&gt; 'John McInventorson',
          :height =&gt; '121'
        }
      }
    }
    @widget = Widget.find(params[:id])
    @widget.creator.id # =&gt; 12
    @widget.update_attributes!(params[:widget])
    @widget.creator.id # =&gt; 12. UPDATED!
</code></pre>

<h4>update an existing object, remove existing <code>belongs_to</code></h4>

<p>Next question: when we <em>don&#8217;t</em> send related <code>_attribute</code> data, which of the following intents does that signal?</p>

<ul>
<li>don&#8217;t update the existing associated object.</li>
<li>remove the associated object from the database.</li>
<li>remove the association, but leave the related object in the database.</li>
</ul>

<p>Again: there can be only one. In Rails if we don&#8217;t included any nested <code>_attributes</code> data it means we&#8217;re simply uninterested in the associated object.  It will be left in the database, untouched. To delete an associated object, Rails Forms use a special <code>'_delete</code> form input whose value should be anything that evaluates to <code>true</code> coming from a form (that&#8217;d be <code>'1'</code>, <code>1</code>, <code>'true'</code>, and <code>true</code>).</p>

<pre><code>    &lt;!-- form.html --&gt;
    &lt;input name='widget[name]' &gt;
    &lt;input name='widget[price]' &gt;

    &lt;input name='widget[creator_attributes][id]' &gt;
    &lt;input name='widget[creator_attributes][_delete]' &gt;
</code></pre>

<p></p>

<pre><code>    # WidgetsController#update
    # params
    {:widget =&gt;
      {
        :name =&gt; 'widget 10',
        :price =&gt; '22',
        :creator_attributes =&gt; {
          :id =&gt; 12,
          :_delete =&gt; '1'
        }
      }
    }
</code></pre>

<p>A few notes:</p>

<ul>
<li>For this to work, you must add <code>:allow_destroy =&gt; true</code> to your <code>accepts_nested_attributes_for</code> call. This is <code>:false</code> by default and delete requests are silently ignored.  In our application, this will be <code>accepts_nested_attributes_for(:creator, :allow_destroy =&gt; true)</code>.</li>
<li>This removes both the association <em>and</em> the associated object from the database. Misusing forms can cost you data. Make sure they do what you intend (test, test, test!).</li>
</ul>

<p>If you want to remove the association but leave the associated object (useful if that other object is needed elsewhere) send an input with the foreign key set to an empty string:</p>

<pre><code>    &lt;!-- form.html --&gt;
    &lt;input name='widget[name]' &gt;
    &lt;input name='widget[price]' &gt;

    &lt;input name='widget[creator_id]' value=''&gt;
</code></pre>

<p></p>

<pre><code>    # WidgetsController#create
    # params
    {:widget =&gt;
      {
        :name =&gt; 'widget 10',
        :price =&gt; '22',
        :creator_id =&gt; ''
      }
    }
</code></pre>

<p>From the <code>belongs_to</code> example, we can distill some rules for nested associated objects:</p>

<ul>
<li>Associated object data is sent in a nested <code>*_attributes</code> hash where <code>*</code> is the name of your relationship (e.g. <code>belongs_to(:dog)</code>/<code>dog_attributes</code>, <code>belongs_to(:foo)</code>/<code>foo_attributes</code>).</li>
<li>If the hash does not include an <code>id</code>, Rails will create and associate a new object (leaving the old object, if there is one, in the system, unassociated).</li>
<li>If the hash includes an <code>id</code>, Rails will update the existing associated object.</li>
<li>If the hash includes an <code>id</code> and a <code>_delete</code> set to something <em>truthy</em> the object will be deleted from the database and the association will be removed.</li>
<li>If you want to remove the relationship but not the object, set the foreign key (here <code>creator_id</code>) to <code>''</code> in the form.</li>
</ul>

<h3><code>has_one</code> or <code>composed_of</code></h3>

<p>We can reuse these patterns for the opposite side of a 1-to-1 data relationship (<code>has_one</code> or <code>composed_of</code>).</p>

<p>Assuming the classes</p>

<pre><code>class Addresss &lt; ActiveRecord::Base
  belongs_to :creator
end

class Creator &lt; ActiveRecord::Base
  has_one :address
  accepts_nested_attributes_for :address
end
</code></pre>

<h4>creating a new object, new <code>has_one</code> object</h4>

<p>We can handle multiple models in one form with</p>

<pre><code> &lt;!-- form.html --&gt;
&lt;input name="creator[name]" /&gt;
&lt;input name="creator[height]" /&gt;
&lt;input name="creator[address_attributes][street1]" /&gt;
&lt;input name="creator[address_attributes][street2]" /&gt;
&lt;input name="creator[address_attributes][city]" /&gt;
</code></pre>

<p></p>

<pre><code># CreatorsController#create
# params
{:creator =&gt;
  {
    :name =&gt; 'James McInventorson',
    :height =&gt; '133',
    :address_attributes =&gt; {
      :street1 =&gt; '123 Main Street'
      :street2 =&gt; 'Office 5b'
      :city    =&gt; 'Anywhereville'
    }
  }
}
</code></pre>

<p>This will create a new <code>Creator</code> object, create a new <code>Addresss</code> object, and associate the two.  </p>

<h4>updating and existing object, updating existing <code>has_one</code></h4>

<p>The same caveats for <code>belongs_to</code> exists here. Updating with the same form will overwrite the existing <code>address</code> with a new one.  So</p>

<pre><code># script/console
params = {
 :id =&gt; 4,
 :creator =&gt; {
     :name =&gt; 'James McInventorson',
     :height =&gt; '133',
     :address_attributes =&gt; {
       :street1 =&gt; '123 Main Street'
       :street2 =&gt; 'Office 5b'
       :city    =&gt; 'Anywhereville'
     }
   }
 }
@creator = Creator.find(params[:id])
@creator.address.id # =&gt; 1012
@creator.update_attributes!(params[:creator])
@creator.creator.id # =&gt; 3101 # OVERWRITTEN!
</code></pre>

<p>We signal to Rails that the current address should be update by including the <code>id</code> of the address in the hash</p>

<pre><code> &lt;!-- form.html --&gt;
&lt;input name="creator[name]" /&gt;
&lt;input name="creator[height]" /&gt;
&lt;input name="creator[address_attributes][id]" /&gt;
&lt;input name="creator[address_attributes][street1]" /&gt;
&lt;input name="creator[address_attributes][street2]" /&gt;
&lt;input name="creator[address_attributes][city]" /&gt;
</code></pre>

<p></p>

<pre><code># CreatorsController#update
# params
{:creator =&gt;
  {
    :name =&gt; 'James McInventorson',
    :height =&gt; '133',
    :address_attributes =&gt; {
      :id =&gt; 1012,
      :street1 =&gt; '123 Main Street'
      :street2 =&gt; 'Office 5b'
      :city    =&gt; 'Anywhereville'
    }
  }
}
</code></pre>

<h4>updating existing object, deleting existing <code>has_one</code></h4>

<p>Same rules as <code>belongs_to</code>:</p>

<pre><code>&lt;input name="creator[name]" /&gt;
&lt;input name="creator[height]" /&gt;
&lt;input name="creator[address_attributes][id]" /&gt;
&lt;input name="creator[address_attributes][_delete]" /&gt;
</code></pre>

<p></p>

<pre><code># CreatorsController#update
# params
{:creator =&gt;
  {
    :name =&gt; 'James McInventorson',
    :height =&gt; '133',
    :address_attributes =&gt; {
      :id =&gt; 1012,
      :_delete =&gt; '1'
    }
  }
}
</code></pre>

<p>From these examples we can distill some rules:</p>

<ul>
<li>Associated object data is sent in a nested <code>*_attributes</code> hash where <code>*</code> is the name of our association (e.g. <code>has_one(:baz)</code>/<code>baz_attributes</code>, <code>has_one(:bar)</code>/<code>bar_attributes</code>).</li>
<li>If the hash does not include an <code>id</code>, Rails will create and associate a new object (leaving the old object, if there is one, in the system, unassociated).</li>
<li>If the hash includes an <code>id</code>, Rails will update the existing associated object.</li>
<li>If the hash includes an <code>id</code> and a <code>_delete</code> set to something <em>truthy</em> the object will be deleted from the database and the association will be removed.</li>
</ul>

<h3><code>has_many</code></h3>

<p>We can do basic <code>has_many</code> associating by submitting a form like the one below (probably with some javascript that inserts hidden inputs)</p>

<pre><code> &lt;!-- form.html --&gt;
&lt;input name='creator[name]' &gt;
&lt;input name='creator[height]' &gt;
&lt;input name='creator[widgets_ids][]' &gt;
&lt;input name='creator[widgets_ids][]' &gt;
&lt;input name='creator[widgets_ids][]' &gt;
&lt;input name='creator[widgets_ids][]' &gt;
</code></pre>

<p></p>

<pre><code># CreatorsController#create
# params
{:creator =&gt;
  {
    :name =&gt; 'James McInventorson',
    :height =&gt; '133',
    :widgets_ids =&gt; ["1","45","1323","1231"]
  }
}
</code></pre>

<p>That will call the <code>Creator#widgets_ids=</code> method that you get with the <code>has_many</code> relationship and associate the widgets in the same call that assigns the name and height attributes of the creator. Be aware that <code>widgets_ids=(ary)</code> overwrites the previous relationships (so if you have <code>widgets_ids</code> of <code>[10,40,51]</code> and would like to add <code>87</code> to that list, you'll have to send <code>[10,40,51,87]</code>, not just <code>[87]</code>). It will look like this.</p>

<pre><code>    &lt;!-- form.html --&gt;
    &lt;input name="creator[name]" /&gt;
    &lt;input name="creator[height]" /&gt;
    &lt;input name="creator[widget_ids][]" value='10' /&gt;
    &lt;input name="creator[widget_ids][]" value='40' /&gt;
    &lt;input name="creator[widget_ids][]" value='51' /&gt;
    &lt;input name="creator[widget_ids][]" value='87' /&gt;
</code></pre>

<h4>complex <code>has_many</code></h4>

<p>Expressing data manipulation of complex <code>has_many</code> relationships is quite tricky.
Imagine you want to have a single form where a new <code>Creator</code> and his <code>widgets</code> can be entered at once, but also, at a later date, that same form could be used to update existing widgets, add new widgets, or delete old widgets.</p>

<p>That's a tall order. To do it we need to be able to tell</p>

<ul>
<li>which widgets are being updated</li>
<li>which widgets are being added</li>
<li>which widgets should be removed (does the lack of a widget on the form indicate we want to remove its association to this creator or remove its entry from the database entirely? Or, does it mean we're just not interested in manipulating its data right now?)</li>
</ul>

<h4>creating a new object, and new <code>to_many</code> relationships</h4>

<p>To add a new <code>to_many</code> relationship in a single submission the microformat uses nested hashes:</p>

<pre><code> &lt;!-- form.html --&gt;
&lt;input name="creator[name]" /&gt;
&lt;input name="creator[height]" /&gt;
&lt;input name="creator[widget_attributes][0][name]" /&gt;
&lt;input name="creator[widget_attributes][0][price]" /&gt;
</code></pre>

<p></p>

<pre><code># CreatorsController#create
# params
{:creator =&gt;
  {
    :name =&gt; 'James McInventorson',
    :height =&gt; '133',
    :widget_attributes =&gt; {
        :0 =&gt; {
          :name =&gt; 'Basic Confabulator',
          :price =&gt; '19'
        }
    }
  }
}
</code></pre>

<p>Let's break down these naming rules for new objects:</p>

<pre><code>creator[widget_attributes][0][price]
</code></pre>

<ul>
<li>the outermost key (<code>creator</code> here) can be called anything you like, and will be accessed with <code>params[:creator]</code> (or whatever you called it).</li>
<li><code>widget_attributes</code> follows the pattern of <em>has_many_relationship_name</em>_attributes. So, if your relationship was <code>has_many :dogs</code>, you <em>must</em> use <code>dogs_attributes</code>, <code>has_many :foos</code> uses <code>foos_attributes</code>, <code>has_many :flavors</code> will be <code>flavors_attributes</code>.</li>
<li><code>widgets_attributes</code> will be a hash, so it must be followed by brackets containing a unique identifier. Here we've used <code>[0]</code>. Because this identifier must be unique on the form (otherwise the hashes will overwrite each other), if we wanted a form that added two widgets at once we'd need <code>creator[widget_attributes][0]</code> and <code>creator[widget_attributes][foobar]</code> (the exact text doesn't matter as long as it's unique).</li>
</ul>

<h4>updating an existing object and existing <code>to_many</code> relationships</h4>

<p>To update an existing <code>has_many</code> related object, include its <code>id</code> in the <code>_attributes</code> hash:</p>

<pre><code>    &lt;!-- form.html --&gt;
    &lt;input name="creator[name]" /&gt;
    &lt;input name="creator[height]" /&gt;

    &lt;input name="creator[widget_attributes][0][id]" /&gt;
    &lt;input name="creator[widget_attributes][0][name]" /&gt;
    &lt;input name="creator[widget_attributes][0][price]" /&gt;

    &lt;input name="creator[widget_attributes][1][id]" /&gt;
    &lt;input name="creator[widget_attributes][1][name]" /&gt;
    &lt;input name="creator[widget_attributes][1][price]" /&gt;
</code></pre>

<p></p>

<pre><code>    # CreatorsController#create
    # params
    {:creator =&gt;
      {
        :name =&gt; 'James McInventorson',
        :height =&gt; '133',
        :widget_attributes =&gt; {
            0 =&gt; {
              :id =&gt; 459,
              :name =&gt; 'Advanced Confabulator',
              :price =&gt; '23.00'
            },
            1 =&gt; {
              :id =&gt; 231,
              :name =&gt; 'Ectoplasm Inducer',
              :price =&gt; '1223.00'
            }
        }
      }
    }
</code></pre>

<p>There are some notable features to recognize:</p>

<ul>
<li>Like other relationships, if you have <code>_attributes[n]</code> hash that does not include an <code>id</code>, a new object will be created and associated. Because this is <code>has_many</code> relationship, the number of related objects will be incremented by 1.   </li>
<li>To create new associations to <em>existing</em> objects use the array format to add the existing objects&#8217; ids to <code>Creator#widgets_ids</code> with inputs names like <code>creator[widgets_ids][]</code>. Again: Be aware that <code>widgets_ids=(ary)</code> overwrites the previous relationships (so if you have <code>widgets_ids</code> of <code>[10,40,51]</code> and would like to add <code>87</code> to that list, you'll have to send <code>[10,40,51,87]</code>, not just <code>[87]</code>). It will look like this:</li>
</ul>



<pre><code>&lt;!-- form.html --&gt;
&lt;input name="creator[name]" /&gt;
&lt;input name="creator[height]" /&gt;
&lt;input name="creator[widget_ids][]" value='10' /&gt;
&lt;input name="creator[widget_ids][]" value='40' /&gt;
&lt;input name="creator[widget_ids][]" value='51' /&gt;
&lt;input name="creator[widget_ids][]" value='87' /&gt;
</code></pre>

<h4>Removing a existing <code>to_many</code> relationship</h4>

<p>To remove an existing <code>has_many</code> related item, include <code>_delete</code> inside its unique hash.  The value should be set to anything that will evaluate to <code>true</code> coming form a form (that's <code>"1"</code>, <code>1</code>, <code>"true"</code>, and <code>true</code>).</p>

<pre><code>&lt;!-- form.html --&gt;
&lt;input name="creator[name]" /&gt;
&lt;input name="creator[height]" /&gt;

&lt;input name="creator[widget_attributes][0][id]" value='1'/&gt;
&lt;input name="creator[widget_attributes][0][_delete]" value='1'/&gt;
</code></pre>

<p></p>

<pre><code>{:creator =&gt;
  {
    :name =&gt; 'James McInventorson',
    :height =&gt; '133',
    :widget_attributes =&gt; {
        0 =&gt; {:id =&gt; 22, :_delete =&gt; '1'}
    }
  }
}
</code></pre>

<p>Some notes:</p>

<ul>
<li>Deleting this way is turned off by default. You enable it in the model by adding <code>:allow_destroy =&gt; true</code> to <code>accepts_nested_attributes_for</code> (e.g. <code>accepts_nested_attributes_for(:widgets, :allow_destroy =&gt; true</code>))</li>
<li>This method deletes the association <em>and</em> associated object. To delete only the association, send the updated <code>_ids</code> attribute with the ids you don't want removed: if you have <code>widgets_ids</code> of <code>[10,40,51]</code> and would like to remove <code>10</code> and <code>40</code> from that list send <code>[51]</code>.</li>
</ul>



<pre><code>&lt;!-- BEFORE: form.html --&gt;
&lt;input name="creator[name]" /&gt;
&lt;input name="creator[height]" /&gt;
&lt;input name="creator[widget_ids][]" value='10' /&gt;
&lt;input name="creator[widget_ids][]" value='40' /&gt;
&lt;input name="creator[widget_ids][]" value='51' /&gt;
</code></pre>

<p></p>

<pre><code>&lt;!-- AFTER: form.html --&gt;
&lt;input name="creator[name]" /&gt;
&lt;input name="creator[height]" /&gt;
&lt;input name="creator[widget_ids][]" value='51' /&gt;
</code></pre>

<h3>All together now!</h3>

<p>Combining these techniques can net us some very sophisticated data manipulations. Below is a form that will update a <code>Creator</code>, his <code>address</code>, updates three existing <code>widgets</code>, adds one <code>widget</code>, and deletes two <code>widgets</code>.</p>

<p>Here's the form on page-load, before we manipulate it:</p>

<pre><code>&lt;!-- BEFORE: form.html -- &gt;
&lt;input name="creator[name]" /&gt;
&lt;input name="creator[height]" /&gt;

&lt;!-- address --&gt;
&lt;input name="creator[address][id]" /&gt;
&lt;input name="creator[address][street1]" /&gt;
&lt;input name="creator[address][street2]" /&gt;
&lt;input name="creator[address][city]" /&gt;

&lt;!-- widgets --&gt;
&lt;input name="creator[widget_attributes][0][id]" /&gt;
&lt;input name="creator[widget_attributes][0][name]" /&gt;
&lt;input name="creator[widget_attributes][0][price]" /&gt;

&lt;input name="creator[widget_attributes][1][id]" /&gt;
&lt;input name="creator[widget_attributes][1][name]" /&gt;
&lt;input name="creator[widget_attributes][1][price]" /&gt;

&lt;input name="creator[widget_attributes][2][id]" /&gt;
&lt;input name="creator[widget_attributes][2][name]" /&gt;
&lt;input name="creator[widget_attributes][2][price]" /&gt;

&lt;input name="creator[widget_attributes][3][id]" /&gt;
&lt;input name="creator[widget_attributes][3][name]" /&gt;
&lt;input name="creator[widget_attributes][3][price]" /&gt;

&lt;input name="creator[widget_attributes][4][id]" /&gt;
&lt;input name="creator[widget_attributes][4][name]" /&gt;
&lt;input name="creator[widget_attributes][4][price]" /&gt;
</code></pre>

<p>and here is the form after manipulation.</p>

<pre><code>&lt;!-- AFTER: form.html -- &gt;
&lt;input name="creator[name]" /&gt;
&lt;input name="creator[height]" /&gt;

&lt;!-- address --&gt;
&lt;input name="creator[address][id]" /&gt;
&lt;input name="creator[address][street1]" /&gt;
&lt;input name="creator[address][street2]" /&gt;
&lt;input name="creator[address][city]" /&gt;

&lt;!-- widgets --&gt;
&lt;input name="creator[widget_attributes][0][id]" /&gt;
&lt;input name="creator[widget_attributes][0][name]" /&gt;
&lt;input name="creator[widget_attributes][0][price]" /&gt;


&lt;input name="creator[widget_attributes][1][id]" /&gt;
&lt;input name="creator[widget_attributes][1][name]" /&gt;
&lt;input name="creator[widget_attributes][1][price]" /&gt;

&lt;input name="creator[widget_attributes][2][id]" /&gt;
&lt;input name="creator[widget_attributes][2][name]" /&gt;
&lt;input name="creator[widget_attributes][2][price]" /&gt;

&lt;input name="creator[widget_attributes][3][id]" /&gt;
&lt;input name="creator[widget_attributes][3][_delete]" value='1'/&gt;


&lt;input name="creator[widget_attributes][4][id]" /&gt;
&lt;input name="creator[widget_attributes][4][_delete]"  value='1'/&gt;

&lt;input name="creator[widget_attributes][new_1][name]" /&gt;
&lt;input name="creator[widget_attributes][new_1][price]" /&gt;
</code></pre>
