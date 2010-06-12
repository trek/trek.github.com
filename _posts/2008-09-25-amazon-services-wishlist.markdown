--- 
layout: post
title: Amazon (services) wishlist
---
I'm a big fan of Amazon's Web Services (AWS) suite. Amazon offers a compelling, nearly end-to-end solution for hosting web applications that continues to solve annoying infrastructure problems using a pay-as-you go model to keep costs down.  My love affair started with Simple Storage Service (S3) which gives you limitless storage for static files, making it an ideal asset server for your application's javascript, css, images, movies, and music.

S3 can't process files, so it's not a place to place scripts that need server-side execution. Thankfully, Amazon provides Elastic Computer Cloud (EC2).  For $0.10 an hour (plus some nominal bandwidth charges) you get a fully accessible linux box that you can configure to your heart's content. I recommend starting with the brilliant Eric Hammond's public Ubuntu server images from <a href='http://alestic.com/'>alestic.com</a> and configure from there.  Once you have box you can save it and launch instances as needed.

Until recently EC2 had some major flaws: when an instance went down you'd lose all data (making it less than suitable for database use) and you weren't guaranteed to get the same IP address with a new machines (meaning additional downtime while DNS propagates with a new IP).  Amazon has since solved these issues with Elastic Block Storage (essentially a 1GB-1TB external drive that can be attached to any instance and persists even if the instance goes down) and Elastic IP Addresses (IP addresses assigned to your account that can be pointed at any running instance, so your DNS stays valid when an instance dies). Check out Eric Hammond's article on <a href='http://developer.amazonwebservices.com/connect/entry.jspa?categoryID=100&amp;externalID=1663'>combining EBS with MySQL</a> and the <a href='http://developer.amazonwebservices.com/connect/entry.jspa?externalID=1192'>ElasticDB</a> concept for combining CouchDB, EC2 and EBS.

Even with these additions there are some parts of the server-in-the-cloud equation that are still missing from Amazon's offering.  Since Christmas is right around the corner, I've complied an AWS Wishlist for the jolly elves in Seattle.

1. Tiny EC2 Instance
Currently Amazon offers instances from <a href='http://aws.amazon.com/ec2/#pricing'>$0.10 to $0.80 an hour</a>. For a dime you get a Small Instance that comes with 1.7 GB of memory, 1 EC2 Compute Unit (which Amazon says is the equivalent of a "1.0-1.2 GHz 2007 Opteron or 2007 Xeon processor"), and 160 GB of instance storage.  This is plenty powerful enough for the early stages of a small startup.  For a proof of concept, demo machine, or student project it's too powerful and far too expensive: those dimes, plus bandwidth, add up to between $70 and $90 a month.

I'd love to see a Tiny Instance with 512 MB of memory, .25 EC2 Compute Unit, and 10 GB of instance storage for $5 a month, or possibly free with a limit of three Tinys per account. Three free Tinys would be a shot across Google's bow, competing with their <a href='http://googleappengine.blogspot.com/2008/05/announcing-open-signups-expected.html'>announced price structure</a> and spur a lot of interest for AWS as a development sandbox.

2. Load Balancer
One of the amazing benefits of AWS/EC2 is the ability to scale application machines as needed. Get dugg and are being hit hard? Spin up 10 extra boxes.  When the peak is over kill those boxes without dealing with the hassle of service reps or contracts.  But, how do you properly balance to the new machines (and then stop balancing to them when they're destroyed)?  You could set up an instance for load balancing, but that's a bit excessive. I'd love to see the next step in Elastic IPs and be able to specific a number of machines to attach to an external IP and choose a balancing strategy via a web services API.

3. DNS
With load balancing and DNS Amazon could offer an end-to-end platform solution.  Register your domain with godaddy and point it at AWS.  Then you'd be able to control it all with their APIs or build yourself a nice web interface for connecting domains, IP addressess, services, machines, and load balancers.

4. Email
Yes, each of us could launch an instance and configure it as a mail server. But why bother?  Typical uses for mail in a webapp are sending out a few notifications, creating accounts, and resetting passwords.  I'd gladly pay some nominal fee to avoid complicating my server setup with a machine to send and receive a few messages.

5. SMS
Amazon already has the ability to send text messages. Extending this to their AWS users would be great for developers who want to integrate mobile phones into their business.

Oh Amazon elves I've been a very good boy this year! Feel free to drop me a line and let me know when I can expect my new AWS toys!
