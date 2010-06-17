--- 
layout: post
title: Automating iTunes Gift Cards
excerpt: "<p>I&#8217;m finishing up a project for the <a href='http://www.sph.umich.edu/'> University of Michigan School of Public Health</a> that involves using iTunes Gift Cards as a participant incentive. They&#8217;ve pre-bought about $20,000 of Gift Cards and given me the ids. We <em>could</em> just have participants copy/paste their code into iTunes, but I wanted to create a smooth user experience for redeeming.</p>
"

---
I'm finishing up a project for the <a href='http://www.sph.umich.edu/'> University of Michigan School of Public Health</a> that involves using iTunes Gift Cards as a participant incentive. They've pre-bought about $20,000 of Gift Cards and given me the ids.

We <em>could</em> just have participants copy/paste their code into iTunes, but I wanted to create a smooth user experience for redeeming.

The base url for iTunes Redeeming is <code>https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/redeemLandingPage</code> (you can drag links from iTunes into a text editor to get their url) but I wanted to pre-fill the code field or automatically submit my request with the code supplied.
<img src='http://s3.amazonaws.com/ember/mXilF9dfifTTnbLcDScrP8Ma0vHYBBG1_o.png' />

I suspected I could send a query parameter along with that url, but not being able to view source, I had no idea what to name it.  So, I went to a place where I've seen automatic click-to-redeem before, Apple's own <a href='http://www.facebook.com/iTunes?ref=ts'>iTunes Facebook fan page</a>.

Sure enough their fan page just sends a request to the same url with a query parameter of <code>?code=123456ABCDEF</code>.  Pass that along with the url and it will send your redemption code along without user intervention and will display inline error messages if your code is bunk for some reason

<img src='http://img.skitch.com/20100114-m7ujrbdkuatuwq7pjkmtmfrayj.jpg' />
