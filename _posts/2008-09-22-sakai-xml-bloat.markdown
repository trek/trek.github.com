--- 
layout: post
title: Sakai XML Bloat
---
Every once in a while I think to myself: since I'm working with an OSS education product, maybe I should take a look at the source of <a href='http://sakaiproject.org/portal'>Sakai</a>, to see how the "big boys" do it.

Then, I get lost in the mountains of XML configuration and wonder "Fuck. How much XML is there in here?"

Well, today I <em>really</em> wanted to know, so I wrote a quick ruby script to find out (written in handy 'super explicit mode' so it's easy to see what's happening):
<code>
<pre>
require 'find'

total_size = 0
dir = '/Users/trek/Downloads/sakai-src-2.5.2/'

Find.find(dir) do |path|
  if FileTest.directory?(path)
    if File.basename(path)[0] == ?.
      Find.prune       # Don't look any further into hidden directories.
    else
      next
    end
  else
    next unless File.basename(path).match(/.xml$/)
    results = []
    File.new(path, "r").each do |line|
      results &lt;&lt; line
    end
    total_size += results.size
  end
end

puts total_size
</pre>
</code>

The results: 233,149.

233,149 Lines of XML config files. Nuts.  The entire Sakai feature set could be reasonably reproduced in fewer lines of <em>code</em> in a modern web framework. I'm sure Sakai apologists will be in, hands waving, with dire warnings of "a lot going on", "enterprise ready", and "highly scalable", but considering most schools aren't MIT-sized does Sakai really provide any value with so much internal complexity?
