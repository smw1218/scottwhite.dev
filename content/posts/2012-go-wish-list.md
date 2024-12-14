+++
date = '2023-09-10T12:00:00-08:00'
title = '2012 Go Wish List'
featured_image='/img/wish700.jpg'
summary = 'What would you have asked to be added to Go in 2012?'
+++
In 2012, I was working at an early mobile game studio and platform named ngmoco. My team ran a game server platform written in Ruby on Rails and we were putting a huge effort into scaling. My boss Dave was trying out many new technologies to see if they had a potential to improve our situation. He ran across a relatively new language out of Google called Go. The Go team had announced that they were working toward a 1.0 release in the near future. We were really attracted to the concurrency features and the performance improvements we could get from a compiled language. The simple syntax and already-full-featured standard library were also great bonuses.

My first project was part of our larger migration to microservices. This was 2011, and microservices were 100% DIY, and we needed what today would be called an “API gateway.” The initial project needed to proxy our whole monolith to perform authentication (OAuth1 and the shiny new OAuth2). I jumped on the project because it sounded fun, and I got to work learning Go.

It didn’t take long to have a working prototype. We had to write a lot of stuff from scratch like our own Redis client, OAuth1, OAuth2 and JWT libraries and of course a logger. We also wrote our own HTTP server and reverse proxy. Even with all that, the project only took a few months since the standard library had functionality that got us most of the way. Right out of the gate, Go was performing at a level of performance and stability that made us confident we could ship it in production.

## The Meeting & Wish List

[Brad Fitzpatrick](https://bradfitz.com/) from the Go team reached out to us after reading a blog post I wrote about us shipping Go in production. There weren’t many companies using Go at the time, especially deployed to production, and he wanted to get some feedback on our experience. He came to our office in San Francisco and met with Dave and I. I don’t remember everything about the meeting, but at some point Brad asked if there’s anything we wanted added to Go. We were already pretty happy with Go, but I remember asking for a few things so let’s review my 2012 Go Wish List.

## HTTP Server Graceful Shutdown

In this era AWS was pretty new so we had our own data center and hardware load balancers. We were running Go right behind the load balancers and, when we deployed updates, we didn’t want to drop any active requests. Go’s http.Server didn’t have a way to stop the listener and wait for in-flight responses to be flushed. We ended up writing our own HTTP server that added a way to fork/exec the running process and directly take over the running listener by reopening the file descriptor. This made it so we never dropped a request on deployment.

Brad was maintainer of the `http` package at the time and recognized the need, but he was busy with the HTTP/2 implementation. This feature got added to the 1.8 release in 2017 with `http.Server.Shutdown`.

## Dependency Management

Coming from Ruby, we were users of [Bundler](https://bundler.io). If you’re not familiar with Bundler, you’re probably familiar with some other similar package manager. I think it was the first widely used tool that used a SAT solver and the ubiquitous 2-file style where the first file has some dependency rules and the second locks dependencies on exact versions.

I remember Brad being very confused on why we would possibly need this. This was in the days where all dependencies landed in the single `GOPATH` directory. He suggested we should vendor all of `GOPATH`, but we had already gone through the pain pain of maintaining such a setup Ruby prior to Bundler. Vendoring is initially easy but we had huge issues updating vendored dependencies once they got decoupled from the upstream git repos.

At the time, I didn’t know that Google uses an enormous monorepo and has a really bad case of NIH. He didn’t understand the problem because he simply didn’t use any 3rd party dependencies. If they did, they would copy all the code into the monorepo and the Google army would take over all the maintenance internally. Maintaining permanent forks of all dependencies might work at Google scale, but not for most companies. It seemed like tracking and pulling upstream dependency updates just wasn’t something the Go team knew anything about because the Google way was so different.

Over the years, I’ve used git submodules, vendoring, dep, glide and finally go modules. It took a while to land on go modules, which work very similarly to Bundler. Modules first got released as an experiment in go1.11 in 2018 and default enabled in go1.16 in 2021. Modules is just the solution I was asking for back in 2012.

## Level Logging

A log package that includes levels was the last request we made in the meeting. As of go 1.21 released in 2023, the standard library includes the `slog` package that has levels as well as being a structured logger. The four included levels (Debug, Info, Warn and Error) happen to correspond to the exact levels I use in practice.

Back in 2012, we did what pretty much everyone did back then and wrote our own logging package. The fancy log aggregators systems we have today were just coming onto the scene back then, but I’m sure Google already had log monitoring tools that worked with the standard library’s `log.Printf/ln`.

While there have always been an abundance of 3rd party loggers with level support, the problem is there are too many loggers. Often complex libraries need to perform their own logging and not having a “standard” interface meant integrating these libraries into a larger system has always been difficult. Often every package would need to provide some shim interface so their internal logging could be made compatible with logrus, zap, zerolog etc. Worse, some projects just embed their favorite logger. Making them all play together in a single application is often impossible and you end up with a mess of different logging formats and missing context. Now that there’s a standard library logger, I’m hoping projects will quickly switch to that interface and this issue will be in the rear-view mirror.

## Sometimes wishes do come true

The Go team steadily works to meet community needs in the standard library. If you look at the progression, the uncontroversial improvements to the HTTP library were handled relatively quickly. Dependency management had multiple false starts and took a ton of work over several years to finally land on the excellent system go modules has today. Level logging doesn’t seem like it should have been the hardest problem to solve. The Go team seems to defer some solutions to the community when there’s no generally accepted standard. I remember Brad asking “Which levels would the standard library support?” A simple question, but one that’s hard to answer without research and a lot of community input. Neither of which Go had developed at the 1.0 stage. While it may seem that 11 years might be a long time to wait, all my wishes eventually came true.
