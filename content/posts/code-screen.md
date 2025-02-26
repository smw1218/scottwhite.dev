+++
date = '2025-02-26T09:45:19-08:00'
title = 'I Bombed the Code Screen'
featured_image='/img/bomb.webp'
summary = 'Sh*t happens'
+++
I bombed a code screen yesterday. If you're expecting me to rant about how unfair technical assessments are, you've clicked on the wrong article. This is a personal retrospective to understand why I fell short and how I can improve moving forward.

As a former manager myself, I recognize the necessity of code screens. They serve a crucial purpose in evaluating programming abilities. The reality is that some candidates with years of professional experience still struggle with simple coding. I've worked alongside a few such developers, and the frustration of having a teammate who couldn't deliver was palpable.

I've encountered many more during interviews, which is precisely why I always do coding assessments when hiring. They ensure programmers can actually program. I know of no better way to verify someone's coding abilities than by testing them directly.

I know it's artificial and not the same as the day to day work, which is why when I'm on the interviewer side of the table, I have a wide leeway for what "passing" means. But yesterday I would have failed a candidate that performed as poorly as I did.

## The Screen

I'm not going to give away the company or the problem out of professional courtesy, but I did want to describe the problem a bit so I can articulate how and why I messed up. The problem wasn't particularly a brain teaser; it was to implement some convoluted business logic. This seems reasonable as a lot of real-world business logic can get pretty convoluted. It included some template code to fill in, and some tests to allow verification of the implementation. 

Code screens are meant to test a variety of coding skills like problem solving, clarity of thought, code implementation quality and speed. The solution wasn't immediately obvious, so there was problem solving involved. There was a bit of plumbing and structural modeling as well that required some simple implementation choices.

I started out pretty well, I read through the description and the template code. I asked some clarifying questions to the interviewer about how the logic was supposed to work then started coding. All by the book so far and I made some quick progress filling in some of the basics of the problem like modeling the structures that held state and writing the update functions. 

## Why Why Why

This all sounds reasonable, so the question remains - why did I fail? Well I failed on one of the basics: I misunderstood the requirements. I had asked some questions and tried to review my plan with the interviewer to confirm what I thought was correct, but I think he misunderstood me. I remember thinking he seemed to say my approach was ok, even though I later found out I had not understood the requirements correctly. The textual description could have given a few examples that would have clarified the situation. I'm not blaming the interviewer or the problem; it was my mistake that I didn't read through the tests more carefully as these were the source of truth.

So why didn't I read the tests more carefully? I had the thought at the time that I should have reviewed them more thoroughly during the interview but I didn't for a few reasons. The first was I _thought_ I understood the requirements well enough. The main reason though is the tests were written in a way that I found a bit confusing. The screen used Coderpad and the tests were written as checks in the main function. I was using Go for the screen and Go has a testing package, but the problem didn't use that so it would fit better into a Coderpad format. I was struggling to understand the tests so I only read through the first three or so before realizing I was burning a lot of time. I decided that I needed to start implementation and revisit the tests during a debugging phase. This strategy would have been ok if I had understood the requirements properly.

This is obviously a huge blunder, so why didn't I just keep plugging away at the tests and ask more questions? The biggest reason I jumped to implementation is that I'm not the fastest coder in this type of situation. I've always been a rather slow typist but I think I also seem to write code differently than most. There's something about the way I think that means I need to type something, then once I see it, I know it's wrong and will fix or rearrange it until it's right. But I need get something on the page to visualize how the pieces fit together. I envy the coders who can hammer out these types of problems start to finish. My approach jumps back and forth and all over the place. It often confuses the interviewer, even when I nail the solution on the first try.

So why don't I work more on my coding style and speed? I did do a lot of Leetcode practice leading up to the interview to get my speed up as much as possible. But changing the way I think about code is a lot harder. The way I do it has never been a downside in my work. While many coders are faster than me when filling in a blank function, I seem to be more productive than most of my peers at daily work. My way of coding is akin to constant refactoring. Since the majority of professional programming work is adding features to existing code, I am very fast at complex updates and fixing bugs.

## Implosion

At some point in the discussion with the interviewer I realized I must be missing something major. I finally realized I had a huge misunderstanding - with only about five minutes left. Shit. This is when the panic set in. There's nothing worse than realizing you're about to fail really hard and this certainly isn't a state of mind where I'm able to do complex problem solving. As soon as I wrote some code, I knew it was the wrong approach and said so. The interviewer gave me some hints, though some imply I still don't quite understand all the requirements and I got even more panicked. I tried really hard to refactor what I had quickly to what I think was the right solution, but even with a bit of extra time, I was cooked. 

The interview ended with an broken implementation and not a single test passing 😢

## Under Pressure

Time bounding an interview is necessary just because everyone's time is valuable. If people are testing for speed, then that's also a test to weed out the slower coders. The last reason is to test how a developer performs under pressure. I was interviewing for a backend role and debugging and fixing issues during an outage requires both speed and precision under pressure to minimize the downtime. So testing how a candidate performs under pressure does seem reasonable. So did I crack under pressure?

Yes and no. I've been through a ton of outages and emergencies in my career, and I'm 100% confident I'm good in an emergency. I've fixed a ton of issues quickly and accurately and on numerous occasions I've saved teammates from making blunders that would make the problem worse. I had some really good mentors early in my career and the #1 thing to be successful in an emergency is: *don't panic*. I panicked in this interview and, honestly, cracked under pressure. Doing some deep self reflection, I think I know how interviews are different for me.

When I'm debugging an outage, I'm laser focused on the problem. In an interview, my focus is split between the problem and my interview performance. When I'm coding a hard problem, I'm typically not narrating out loud, though I sometimes do it in pair programming sessions. In an interview that's what you're supposed to do so you can explain your thought process to the interviewer. Many people think verbally, and this is easy for them. I'm a visual thinker so it's a huge distraction from my thought process. In addition to the narration distraction, I have to think extra hard about how I'm sounding to the interviewer. When I'm working with my colleagues on a problem, they're all working on it with me. The interviewer's job is judging me and I'm constantly aware of it. This is where I crack.

I have stage fright. It's something that I've worked on over the years, but it comes out in some unexpected places. I think the common factor is me being aware that other people are thinking about me. I've given presentations where if I stay focused on the topic I'm fine. If I think that others are focused on the material and not me, I'm also fine. But the second I think I'm personally in the spotlight, it triggers an immediate fight-or-flight response. This can happen even if I'm just given a compliment in a big meeting. I've had it happen just being the center of attention in a conversation with a few strangers. 

Interviews are a middle ground because I have practiced suppressing the thoughts that I'm being judged, and focus on the process and questions. This works right up until the point I mess something up. The realization that I've messed up focuses my mind on what the interviewer will think about my mistake.  Then the panic sets in and, once it starts, it can last hours. The problem-solving part of my brain is greatly diminished as my thoughts constantly snap back to negative self-reflection. I've had it carry over from one interview to the next, even for minor mistakes, and it's really hard to calm down until I'm out of the situation. In this interview, I managed to get through almost all of the screen without major panic and I think I could have gotten at least a partial solution if I hadn't panicked. 

## More Better

I'm struggling to know for sure how I can improve. I should have spent more time understanding the tests, but it's hard to say for sure if that would have been any better. I could have ended up spending too much time on those and had the same result: running out of implementation time. The general advice is to make sure you understand the problem fully before starting to code so it's probably the best bet.

More practice with time pressure I think would help. Outside of competitive coding, this is an interview-only skill, but it's something that can be practiced. Most screens also have some algorithmic problem so grinding on Leetcode easys and meduims can help. The hards and many mediums are brain teasers, or require specific knowledge about data structure or dynamic programming patterns. Practicing these does help improve the skills and some companies still use these for screens, even though many just test if you've solved a similar problem recently. The practice I did prior to this interview seemed like a good fit, but I think I needed to take more time-bound tests.

Getting over my stage fright? Therapy maybe? I'll probably need a job with insurance for that so it's a bit of a Catch 22.

If you're reading this I hope it was helpful to hear my struggles and how I approach improvement. It's uncommon for people to talk about interview failures in a constructive way. I've got over 25 years of professional coding experince and I've given hundreds of code screens myself. Despite that, I still fail the interview codes screens sometimes. I like getting this type of thing off my chest so I don't dwell on my failures and I can focus on improving for next time. Wish me luck 🍀
