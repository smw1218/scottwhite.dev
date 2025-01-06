+++
date = '2025-01-04T15:58:13-08:00'
title = 'My First Advent of Code'
summary = "What it's like to dive in as an experienced beginner."
featured_image = '/img/christmas_tree.jpg'
+++
After finding myself with a copious amount of free time heading into the holiday season, I decided to participate in the Advent of Code for the first time. I had been working a lot in Python at work and decided to get back to writing Go. AoC seemed like a good way to keep my coding skills sharp. 

I had never participated before and didn't have many expectations on what it would be like. I basically knew, like all online coding challenges, it would be algorithm-heavy. I don't want to say how old I am exactly, but let's just say it's been quite a long time since I've been in college and my major was Electrical Engineering and not Computer Science. In my professional career, writing basic algorithms has been really rare. Maybe once or twice a year, I'd get a problem where applying basic CS algorithms would be important. Most of the time, a few simple maps or sorts do the trick. All this made me a bit nervous about my prospects.

I forgot and started a on day 2, but since the first few days are pretty easy, I was able to finish the first two days in a few hours. For the very first challenge, I was not aware every question had two parts. I also thought that maybe the same input would be used across multiple days. Both of these were incorrect assumptions and I had wasted a bit of time on trying to generalize some parsing code.

## Getting Competitive

Day 3 was the first day where I did the challenge on the day-of and also about the time I found the personal leaderboard. When I saw that my time was ~12 hours, I realized that the challenges are available at 9 PM PT the day before. I decided to see how fast I could do the challenges (and maybe even work up to the leaderboard). I hadn't yet found Reddit and all the threads talking about how LLMs were dominating the leaderboard. I had taken the request to not use AI seriously and even disabled my usual use of Copilot. I also knew that using Go was going to be a bit of a hindrance, but I still wanted to challenge myself.

I started pushing myself to go faster starting on day 4 and my times started coming down. I was  getting in the swing of faster input parsing and picking good data structures. Day 5 part 2 I got done in a little over an hour and I thought I could push even harder.

## Flaming out Early
Day 6 was the day I started really pushing. I got the puzzle open right at 9 PM and got through part 1 in 36 minutes... but then came part 2. The first thought of how I could "solve" it was way over-optimized and incorrect. I ended up staying up until 1 AM before giving up for the night. This was a disaster as I had to get up at 6 AM. The next day I was tired and still working down the wrong over-optimized paths for the whole day. I realized late in the day I could just do a really simple brute force and only needed to change one line of code. This rather easy puzzle ended up being my worst time except for day 24.

I was also exhausted and I'll admit it was a huge blow to my self confidence. This was Day 6; and I knew the problems only get harder. I realized that pushing harder got my mind stuck in a rut and if I just took a more relaxed approach I'd get better results. I also put a 2-hour limit on the evening session. This put me in bed by about 11 PM so I wouldn't have so I wouldn't be killing myself getting progressively more tired as the month went on.

## Recovery
Days 7 and 8 were better and I got in the swing of things. On day 9, I had to invoke the 2-hour rule for part 2 and it worked great. I found it was usually much easier to get through the problems in the morning after a good night's sleep.

I also just stopped trying to push myself so hard. This made the experience much more fun than putting the time pressure on. The rest of that week went by ok.

## First "Hard" Weekend
The next real challenge was the weekend. The problems started getting harder and so I was regularly going over my 2-hour evening window. I have a 6 year old daughter so now the morning sessions were much more difficult and I was often trying to debug code during constant "Dada, can you play with me?" This make the challenge extra difficult, and also a bit guilt-ridden.

## Cruising
The problems were now getting harder on-average, but I was getting better at them at the same time. On average, I was taking about 3-5 hours per day.  Consistent 2 hours at night then a few more in the morning. I was also tending to do the evening sessions while watching some TV in the background. It was a bit distracting but TV is the way I unwind at night so if I got tired of coding I could just take a break.

## Pushing Through
I have to give some credit for the organizer of the AoC because I really needed an "easy" day right around day 18. And then on day 19 my wife got tired of the whole thing and I needed to take the next morning off to spend the day with her. I had done most of part 1 the day before and then managed to finish up after our outing.

This was just in time for another weekend with some of the hardest problems. There has been lots of writing about day 21 and I had to work on it most of Sunday. I can't tell you how difficult it is to concentrate with a child whining at you every five minutes. I feel pretty bad about it but since she was out of school I could make it up to her over the next week. This was the first day I needed to get some real help from Reddit to finish within the day. I never looked at code solutions directly, but I got the prioritization of the direction keys from a post. I had been on the right track but it would have taken several more hours to get it done. With that final hint, I got the solution quickly so I could spend some quality time with my kid.

## Finish Line
Day 24 part 2 was the last big hurdle for me. This was the first problem where I didn't have any good theories on how to solve the problem and had to just try a bunch of different approaches (many of which didn't work). It was also getting right up to Christmas, so finding coding time was more dicey. I ended up solving it manually after having my code narrow the search. After finishing, I fixed the code up to narrow it down where it would solve completely in code; but that was after the end. Sadly, I got there at about 9:30 PM PT on Christmas day so both day 24 and 25 show greater than 24 hours. I also realized I had the almost correct solution like 6 hours earlier and if I had just found the single mistake, I could have finished day 25 in less than 24 hours 😕

## The Good
It was fun to be a part of a big group all working on a similar thing. I enjoyed the different problems and had fun writing code where the stakes are low. It was fun to look forward to a new challenge and see how I stacked up against everyone else in the community. I got to do a bunch of things like complex string/list manipulation and graph and maze searches that I've never done before.

## The Bad
It took me a few days to turn off the professional SWE part of my brain. The best way to do AoC requires skipping over things that are typically really important like error handling, proper separation of concerns and testability. While it was fun to work on problems I don't see often, it's definitely not good practice for an actual job writing software. I looked at many of the  solutions on the Reddit thread and most were _very_ difficult to read and understand. Often the most concise ones were the hardest to understand. Especially ones that listed leaderboard positions were very confusing. To be honest, looking back at my own solutions, I can hardly figure out what I was doing only a few days later. This is the right way to write code for this type of competition, but if you're working on a team, code like this is unmaintainable.

Unlike many of the participants, I've been a professional SWE for a loooong time. I'm used to solving problems with code so these were just variations on that. Most of the problems were puzzles that need to be solved. I enjoy the occasional puzzle, but I can't say it was much of a learning experience. Many of my solutions were not heavily optimized, so there's some algorithmic tricks I could learn. I could go back and learn the more optimized techniques, but given the time commitment, I'm not sure it's worth it unless I plan to get into competitive coding.

## The Ugly
As I've mentioned, AoC was a big time commitment over the holidays and with a wife and small child it was a bit too much. I could practice Leetcode all year to get to a more competitive speed, but solving Leetcode-style problems isn't the most enjoyable activity for me. I'd rather be building real things, learning something new, or writing blog posts.

Trying to make the leaderboard was pretty silly as a beginner. Once I stopped obsessing, things got a lot better.

## Conclusion
It was fun to do AoC and I feel proud of myself that I got my fifty stars with only a little help from Reddit. It's a big time commitment unless you're already really fast at this type of problem, but I think it's worth it to push through to the end if you've got the time. My advice (and many others seem to agree) is to ignore the leaderboard and take the AoC as a self-challenge and learning opportunity. It's way more fun that way.

Here's my personal leaderboard:
```
      --------Part 1---------   --------Part 2---------
Day       Time    Rank  Score       Time    Rank  Score
 25   01:11:19    4870      0       >24h   10594      0
 24   02:07:38    5842      0       >24h   12489      0
 23   01:08:38    4603      0   02:17:02    4551      0
 22   00:30:33    3606      0   01:59:11    3758      0
 21   11:06:34    7641      0   17:22:25    6987      0
 20   12:40:37   16468      0   13:47:52   12671      0
 19   16:05:55   21666      0   16:19:53   19023      0
 18   01:32:48    6369      0   01:57:12    6397      0
 17   01:43:53    6388      0   13:33:18   10373      0
 16   02:22:02    6286      0   03:13:11    4712      0
 15   02:02:20    7246      0   13:41:21   15336      0
 14   11:06:25   24697      0   12:01:45   20982      0
 13   02:23:38    9911      0   14:26:35   23663      0
 12   01:50:21    9096      0   12:56:54   17652      0
 11   00:31:43    7518      0   12:52:49   28708      0
 10   01:17:06    8878      0   01:19:40    8321      0
  9   01:11:20    8055      0   12:30:35   24260      0
  8   01:03:07    7523      0   01:33:36    7865      0
  7   00:48:05    7303      0   01:31:33    8698      0
  6   00:26:16    5081      0   20:47:24   42145      0
  5   00:35:56    7534      0   01:04:22    7406      0
  4   01:37:16   14389      0   01:52:00   12494      0
  3   12:18:21   75212      0   12:38:27   64531      0
  2       >24h  116902      0       >24h   91238      0
  1       >24h  154703      0       >24h  144769      0
```
Here's [my code in github](https://github.com/smw1218/advent-of-code-2024).