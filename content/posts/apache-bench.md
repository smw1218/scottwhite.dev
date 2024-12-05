+++
date = '2012-01-19T15:12:00-08:00'
title = 'Apache Bench'
summary = 'Apache Bench (`ab`) is a command line HTTP performance and load testing tool.'
+++
Apache Bench (`ab`) is a command line HTTP performance and load testing tool. It has been around for twenty years and every time I need to do some load testing on a new API my team is about to launch, I try all the latest HTTP load/perf tools. Despite being the oldest player on the field, Apache Bench (`ab`) is still the easiest tool to use. 

## Setup

Let’s take a look at the minimum apache bench run:

```
$ ab -c 2 -n 10 http://www.apache.org/
```
The three options are: concurrency (-c 2), number of requests (-n 10) and URL (http://www.apache.org).

Apache Bench will create concurrent workers, in this example two, and each worker will make requests one after another until the total number of requests have been processed:

![Apache Bench Run](/img/abrun.png)

Each request takes a slightly different amount of time. Each worker must wait until its request has completed before it can start the next request, but it will start the next request as quickly as possible. It’s easy to see from the picture that 2 workers would take about half as long to perform 10 requests as a single worker would if it performed all the requests sequentially.

Concurrency is the best way to simulate load on your web application. As your application gets more users, your concurrency will go up but it won’t go up in a 1-to-1 ratio since most requests can be processed in a short period of time for a given user. Unlike Apache Bench workers, real users don’t make requests one after another as quickly as possible; real load has lots of gaps and bursts.

Simulating this bursty traffic is difficult and inconsistent. Simulating traffic the Apache Bench way gives you a good worst-case burst scenario.

The number of requests will depend on your application but the rule is that you want this number to be large enough to get a fairly consistent average performance and throughput. For instance if your application has a cache, the first request will be slower than subsequent requests so only doing a few requests will create a skew the result to some number in between the cached result and the non-cached result (which does not match any real request). The rule of thumb is to make the number big (thousands or more), then lower it as long as the lower number gets similar results.

## Results

There’s a lack of documentation on the output of Apache Bench and how the different statistics it produces should be interpreted. Here’s a sample run:

```
1   This is ApacheBench, Version 2.3 <$Revision: 1706008 $>
2   Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
3   Licensed to The Apache Software Foundation, http://www.apache.org/
4   
5   Benchmarking www.apache.org (be patient).....done
6   
7   
8   Server Software:        Apache/2.4.7
9   Server Hostname:        www.apache.org
10  Server Port:            80
11  
12  Document Path:          /
13  Document Length:        55153 bytes
14  
15  Concurrency Level:      2
16  Time taken for tests:   0.790 seconds
17  Complete requests:      10
18  Failed requests:        0
19  Total transferred:      554950 bytes
20  HTML transferred:       551530 bytes
21  Requests per second:    12.66 [#/sec] (mean)
22  Time per request:       157.948 [ms] (mean)
23  Time per request:       78.974 [ms] (mean, across all concurrent requests)
24  Transfer rate:          686.23 [Kbytes/sec] received
25  
26  Connection Times (ms)
27                min  mean[+/-sd] median   max
28  Connect:       35   38   1.4     38      40
29  Processing:   114  119   3.9    120     126
30  Waiting:       37   41   1.4     41      42
31  Total:        150  157   4.7    158     166
32  
33  Percentage of the requests served within a certain time (ms)
34    50%    158
35    66%    158
36    75%    160
37    80%    162
38    90%    166
39    95%    166
40    98%    166
41    99%    166
42   100%    166 (longest request)
```

Let’s take a look at this line by line then pick out the gems for a closer look.

* 1-7   Apache Bench Info
* 8-12  Information about the server/URL you're testing.
* 13    Document Length Length of the server response, i.e. Content-length (not including HTTP headers!).
* 15    Concurrency Level The parameter you specified with -c. It's nice to have it repeated if you're logging many runs to files.
* 16    Time taken for tests Total time for the whole run to complete.
* 17    Complete requests The parameter you specified with -n (unless `ab` fails to complete the whole run).
* 18    Failed requests Any request that didn't complete or wasn't valid HTTP (HTTP error codes like 404 are reported as "Non-2xx responses" if they happen during the test).
* 19    Total transferred Number of bytes downloaded from the server including headers.
* 20    HTML transferred Number of response bytes downloaded not including headers (not necessarily just HTML). If the URL always returns the same data this = (Line 13) * (Line 17)
* 21    Requests per second (Line 17) / (Line 16)
* 22    Time per request [#1] The sum of the time it took for each request divided by the number of requests
* 23    Time per request [#2] (Line 16) / (Line 17)
* 24    Transfer rate (Line 20) / (Line 16)
* 31 Connection Times Component breakdown of each request.
* 32   Connect Time it takes to establish the TCP connection (does not include any of the HTTP transaction)
* 29    Processing Total time minus the Connect time. This will include all the HTTP IO, plus the waiting time. The IO time could be calculated by Processing - Waiting
* 30    Waiting This is the time between writing the last byte of the request and receiving the first byte of the response. Note that Processing includes this time
* 31    Total Total request time including opening the TCP connection time
* 33-42 Percentage of the requests... For stat geeks, this is a cumulative distribution. Note that it starts at 50% because when you're load/performance testing you only usually care about the slow requests. This gives you lots of information about what percent of your requests are having trouble (because it's usually not all of them)

## Performance metrics

I like to think about performance as what my customer is experiencing, which helps me pick the best metric to use when measuring it. Once you pick a metric it’s also important to pick a goal value for that metric. It’s negotiable depending on your business need, but having a goal is necessary to decide when performance is bad enough that it should be considered a failure of your application and require action to resolve it.

### Time per request [1]
This gives you the average response time for each request, which is a good model of what your customer is going to see in the real world. Because it’s an average, however, it has the normal gaps that averages generally have. A few long requests can skew this number wildly and if similar requests have a different performance (such as the cached vs. non-cached example from before) then the actual value a specific customer sees could be very different from what `ab` reports.

### Time per request [2]
“There are three kinds of lies: lies, damned lies, and statistics.” I HATE this number and I wish `ab` didn’t spit it out at all. You can see that the minimum request time was 125ms but this number is about half of that. It has nothing to do with what a customer sees but is more a value of throughput, and throughput is better measured by “requests per second”, as in: 1 / (time per request [2])

### Transfer rate
This could be important to maximize for your customers, but it’s not terrifically likely.

### 100%,99%,95% etc
Percentages are my favorite metric after time per request [1], because at 100% you’ve included the very worst possible customer experience. Everyone gets the occasional hiccup or corner-case, so even 99% or 95% are pretty good. Just remember that given multiple requests, the percentage chance that a given customer is going to see a number worse than your target percent (T) is:

`1 — T^n`

where n is the number of requests. So, for 3 requests, the chances of getting a single request longer than the 95th percentile is:

`1–(0.95^3) = 14%`

Using 90%, it’s 27% for 3 requests. If an important function takes 3 requests to complete, then on average 1 out of 4 customers are going to fail your performance spec for one of the 3 requests. 100% is usually safe, but it may be hard or even impossible to achieve.

### Requests per second
I left this for last because, like time per request [2], it’s not usually something your customer directly cares about. One customer making a few requests doesn’t care that there are thousands of other customers also making requests. This number is all about scaling your server.

## Scaling

Requests per second (or minute or hour) gives you a good indication of how well your application scales. This number typically maxes out for a given deployed application, and once it does, you’ll have to change something if you expect to keep making your hard-won performance goals.

It could be as easy as adding more servers, or as hard as a total re-architecting of your software or database. The number that `ab` returns is the maximum requests per second (unless your app is faster than `ab`).

Requests per second (or minute) and Time per request are usually easy and inexpensive to collect in production so you can predict when your application will get over-loaded or performance starts to lag. It is well worth the effort to collect this data to know in advance that you should get another couple of servers running. See an additional article for a deeper dive into how to use `ab` for Load Testing.

There are some pitfalls to watch out for when using `ab` results for real-world planning. Because it only tests one URL at a time, you can have issues with mixed request interactions (like mixing database reads and writes). You’ll also want to be careful about caching. If your app caches a response and `ab` only tests the cached response, you’ll see a very different real-world performance if your cache-hit rate is low. To address this, test with caching disabled and multiply your numbers by your expected (or measured) hit rate. So, if your non-cache average is 300ms and your cache average is 50ms, with a 70% hit rate your actual average will be about `((300ms * 0.30) + (50ms * 0.70)) = 125ms`.

One other thing to note when comparing `ab` to other tools is that `ab` only supports HTTP 1.0. This is important because in HTTP 1.0, Keep-Alive is disabled by default. Many articles assume `ab` is slow because it runs slower than other tools by default but the cause is almost always Keep-Alives. To enable Keep-Alives, pass the `-k` flag and set the Keep-Alive header `-H "Connection: Keep-Alive"`.

## Conclusions

Use Apache Bench! It’s a really great tool when you know how to use it and interpret the results. Any other tool also works great as long as it also reports your favorite performance metric and requests per second.
