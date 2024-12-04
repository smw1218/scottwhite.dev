+++
date = '2017-10-22T12:00:00-08:00'
title = 'Load Testing the Easy Way'
+++
In my career I've repeatedlyfound myself in the position of needing to test the performance and scalability of our backend services. It's usually before a launch or just prior to an expected bump in traffic. I worked several years on fitness products, so ramping up for New Year's resolutions is something that happened every year. With all this practice, I've developed a methodology that I think works better than the standard approach.

Before we jump in, let's talk about the standard approach. Step 1 is to create a test environment that closely matches production. This usually means a full-sized database and a similarly sized cluster of application servers. Step 2 is to create a test harness that can produce simulated load aka HTTP requests. This is usually done with a tool like JMeter, Siege, Apache Bench or [K6](https://k6.io/). Step 3 is to repeatedly run the test with ramping concurrency levels and measure the performance and throughput. Many site recommend test runs of 5 to 15 minutes to check for stability. The first pass is just checking if something "broke", but this is just the low hanging fruit. It's often necessary to push through to lower the latency of many endpoints and it may take many passes to get to the desired throughput. I'm going to call this a "full-scale" load test.

If you've every taken this approach, you know it can be difficult and time-consuming. Creating a blended traffic test that simulates realistic user load is more of an art than a science. It’s difficult to debug issues across the whole distributed system as failures can cascade out masking the actual bottlenecks. With long ramps and run times, getting the data you need to create fixes then testing them once they're written can take a significant amount of time. Full-scale load testing can also be very expensive. I was involved with testing a pre-launch system and it cost about $50,000 just in AWS costs to run a full scale test. It only required a few weeks of testing to get to the desired scale, but the test harness and test environment were both quite large. Due to all the costs associated with this type of testing, I've found that it's rarely done at all, and almost never done on regular code changes.

To get around these issues, I've developed a methodology that decomposes the full-scale test to something that can be much more easily run and allows for faster debugging and fixes. It requires making some simplifying assumptions, but it has worked well in practice to reliably characterize a variety of server software. It allows for testing on a smaller scale and can usually be run on both on a regular development machine or an existing QA environment.

You'll need an HTTP load testing tool that supports two metrics that need to be tracked during the load test: performance and throughput. Performance is defined as the time a user has to wait for a request to be completed and needs to be measured for each request. Server endpoints are usually measured on the order of milliseconds and the test tool should report this number for each request or an aggregate like average or 95th percentile. Throughput is measured in requests per second (RPS). If you have the number of requests and total test time, you can just divide. Unlike performance, throughput is not directly user-facing but instead is a measure of server utilization. This metric allows us to estimate the number of servers required to handle the load later. The tool also needs to support setting a concurrency level. Apache Bench is a good choice simply because it's available everywhere (and we'll soon see we don't need a large distributed cluster for this technique).

We're just going to pick a single endpoint to test at a time. To get realistic numbers, we'll need to deploy the endpoint's service along with it's dependencies like a database and any other service it depends on. Always start by testing a single “scaling unit,” which usually means a pod, container, VM or server. Whatever is the smallest unit that you would expected to bring online to handle more traffic. For brevity, I'm going to call this the "server". Make sure to get a separate server on the same network to run the test harness that is the same performance or better than the server under test.

Since you only have one server under test, you should only need a single test harness of the same size. Because the test harness doesn’t really perform any business logic, a well designed one should be able to easily overwhelm your server that is performing business logic. This assumes that you’re running the test harness on the exact same scaling unit as the server, but if the test harness is much more performant than the server, then a smaller scale server should do. The easiest path is to keep it simple and use the same or better server for the test harness and also monitor the test server to make sure it doesn’t exhaust resources like hit 100% CPU etc. Beware that if the endpoint is too trivial, you may run into harness scaling issues.

Most test tools require specification of a total number of requests or a total test time. The best number of requests to run is the minimum amount to get a repeatable result. Make a few test runs and if you get within about 5% run to run then that should be good enough. From experience, this tends to fall in the hundreds to thousands of requests. It takes a lot less requests than you might expect and single run usually only take a 5 to 10 seconds to get stable results. This is good because we want frequent runs and a full test will require multiple runs. Languages that might be doing some warmup or JIT might require a warmup run after startup. Just running a single test at some medium concurrency level is usually enough. Be sure to throw away the results of the warmup run to make sure your numbers are more repeatable.

Now that everything is setup, execute multiple runs of your test at different concurrency levels. A good start would be 1, 2, 10, 50, 100, 200. If you find you’re failing your performance spec badly, you can stop there and not bother running higher concurrency levels. If you’re still within spec at the end and the responses per second are still increasing, you need to do more runs with higher concurrency.

You'll end up with data that typically looks like this:

```
Concurrency     RPS     ms2              
2               65.4    28.3
20              175.6   111.0
50              190.0   249.1
100             196.5   494.2
200             198.6   756.3
```

For analysis, make two plots; the x-axis should always be concurrency. The y-axis for plot one is  performance in ms and plot 2 is throughput in RPS. Performance tends to get worse (higher latency) with concurrency approximately linearly. RPS should increase and then level out or decline slowly as the system under test saturates it's resources.

![Latency](/img/load_ms.svg)

For this example, 200ms was chosen as a performance target. This limits the concurrency to 39.

![Throuput](/img/load_rps.svg)

Moving to the throughput plot, at a concurrency of 39, throughput is about 190 RPS.

On the performance graph find the point on the line where it crosses your performance spec. Find the concurrency at this level; this is the maximum concurrency the server can handle. Going above this level means your performance is failing spec and you users will have a bad experience. If you take that level of concurrency to the Throuput graph and find the RPS, this is the maximum RPS your server can handle. In order to handle more RPS, add more servers. Since each server is identical, the number of servers required is just the total required RPS divided by the RPS per server.

Assumption #1: No shared resource will be constrained when adding more servers. When this occurs, it tends to be a database or network bandwidth. The database can be tested in a similar manner with the frontend servers considered clients.

Assumption #2: Your curves are well-behaved. The data can bounce around a bit but the curves should fit the general description. If the curves bounce around or are flat to start, then this methodology won’t work. This is usually a sign that the architecture of the code is not scaling with concurrency and performance bottlenecks in the code should be investigated.

Assumption #3: You will hit a limit based on some constrained resource. This is most often CPU, but could be memory or I/O. If none of the hardware limits are reached, there may be a soft limit where the code is locking or synchronized around a single resource like a DB connection or just a mutex on a data structure. The last constraint which bears some mention is context switching.

If you run your test to high enough concurrency levels, you’ll generally see a point where performance climbs exponentially and RPS drops precipitously. If this is accompanied by high system CPU, it is a sure sign you’ve got too many threads and you’re spending more time context switching than actually processing. I’ve never seen this happen within a reasonable performance threshold, but it might happen if a request fans out to many threads. In this scenario, a reduction in the number of processing threads would increase overall performance.

This technique is cheap and easy enough that it can be run during normal automated testing to catch performance or scalability regressions. The numbers are also typically proportional if the same technique is used on a local developer machine so the test can be run in a tight development loop. I typically do this with a single concurrency level often while collecting profiling data. I can quickly iterate on performance improvements then push the code out to the test environment for final testing. There's a lot more to be said on the details of load testing and I'll save that for another post.