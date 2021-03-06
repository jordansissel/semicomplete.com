+++
# Imported from original pyblosxom .txt format at 2015-08-14
date = "2010-06-21T19:24:23-07:00"
title = "Debugging java threads with top(1) and jstack.\n"
# Marked a draft because frankly my old writing may not be worth surfacing again.
# I made bad word choices and had some strong-and-closed opinions years ago.
# We learn over time, eh? :)
type = "old"
categories = [ "old" ]
tags = ["java", "debugging"]
+++

At work, we're testing some new real-time bidding on ADX and are working
through some performance issues.

Our server is jetty + our code, and we're seeing performance problems at
relatively low QPS.

The first profiling attempt used [YJP](http://www.yourkit.com/index.jsp), but when it was attached to
our server, the system load went up quickly and looked like this:

`load average: 2671.04, 1653.95, 771.93`

Not good; the load average while running with the profiler attached jumps to a
number roughly equal to the number of application threads (3000 jetty threads).
Possible PEBCAK here, but needless to say we couldn't use YJP for any
meaningful profiling.

Stepping back and using some simpler tools proved to be much more useful. The standard
system tool "top" can, in most cases show per-thread stats instead of just
per-process. Unfortunately, top(1) doesn't seem to have a "parent pid" option,
but luckily for us, our java process was the only one running as the user
'rfi'. Further, some top implementations can take a single process (top -p PID)
which would be useful here. 

If we make top output threads and sort by cpu time, we get an idea of the
threads that spend the most time being busy. Here's a sample:

```
top - 22:29:34 up 87 days, 21:45,  9 users,  load average: 10.31, 12.58, 8.45
Tasks: 3237 total,   5 running, 3231 sleeping,   0 stopped,   1 zombie
Cpu(s): 53.9%us,  2.6%sy,  0.0%ni, 42.3%id,  0.0%wa,  0.0%hi,  1.1%si,  0.0%st
Mem:  16432032k total, 10958512k used,  5473520k free,   149100k buffers
Swap: 18474740k total,    77556k used, 18397184k free,  5321140k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    <b><u>TIME+</u></b>    TIME COMMAND
32149 rfi       16   0 13.7g 6.8g  13m S 50.7 43.3 134:38.08 134:38 java
28993 rfi       15   0 13.7g 6.8g  13m S  5.5 43.3  13:26.85  13:26 java
28995 rfi       16   0 13.7g 6.8g  13m S  3.6 43.3   8:17.84   8:17 java
32151 rfi       15   0 13.7g 6.8g  13m S  1.9 43.3   5:47.59   5:47 java
29143 rfi       16   0 13.7g 6.8g  13m S  0.0 43.3   4:18.51   4:18 java
28990 rfi       15   0 13.7g 6.8g  13m S  1.0 43.3   3:58.86   3:58 java
28989 rfi       15   0 13.7g 6.8g  13m S  0.6 43.3   3:58.83   3:58 java
28992 rfi       15   0 13.7g 6.8g  13m S  1.0 43.3   3:58.72   3:58 java
28986 rfi       16   0 13.7g 6.8g  13m S  1.0 43.3   3:58.00   3:58 java
28988 rfi       16   0 13.7g 6.8g  13m S  0.6 43.3   3:57.94   3:57 java
28987 rfi       15   0 13.7g 6.8g  13m S  0.6 43.3   3:56.89   3:56 java
28991 rfi       15   0 13.7g 6.8g  13m S  1.0 43.3   3:56.71   3:56 java
28985 rfi       15   0 13.7g 6.8g  13m S  1.3 43.3   3:55.79   3:55 java
28994 rfi       15   0 13.7g 6.8g  13m S  1.0 43.3   2:05.35   2:05 java
29141 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   1:09.66   1:09 java
32082 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   0:56.29   0:56 java
28998 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   0:52.27   0:52 java
29359 rfi       15   0 13.7g 6.8g  13m S  3.2 43.3   0:45.11   0:45 java
31920 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   0:43.46   0:43 java
31863 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   0:41.67   0:41 java
31797 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   0:41.56   0:41 java
31777 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   0:41.31   0:41 java
30807 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   0:41.22   0:41 java
31222 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   0:40.70   0:40 java
30622 rfi       15   0 13.7g 6.8g  13m S  3.9 43.3   0:40.56   0:40 java
31880 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   0:39.77   0:39 java
29819 rfi       15   0 13.7g 6.8g  13m S  4.8 43.3   0:39.15   0:39 java
29438 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   0:39.11   0:39 java
30363 rfi       15   0 13.7g 6.8g  13m R  0.0 43.3   0:39.03   0:39 java
31554 rfi       15   0 13.7g 6.8g  13m S  0.0 43.3   0:38.82   0:38 java
```

I included lots of threads in the output above so you can get an idea,
visually, of the time buckets you could place each thing in.

The important column is "TIME+" here. You can see that there's some uniqueness
in the times that probably give you an indication of the similarity in duties between
each thread with similar times (all the near 4-hour times are probably of
similary duty, etc).

If you grab a stack trace from your java process, you can map each process id
above to a specific thread. You can get a stack by using jstack(1) or sending
SIGQUIT to the java process and reading the output.

Java stack traces, for each thread, have similar headers:

```
"thread name" prio=PRIORITY tid=THREADID nid=LWPID STATE ...
```

The thing we care about here is the LWPID (light weight process id) or also
known as the process id.


Find my java process (must be run as the user running the process):

```
% sudo -u rfi jps
28982 ServerMain
3041 Jps
```

If I take the 2nd highest pid from the top output above, 28993, what thread
does this belong to? If you look at the stack trace, you'll see that java
outputs the 'nid' field in hex, so you'll have to convert your pid to hex
first.

```
% printf "0x%x\n" 28993
0x7141

% grep nid=0x7141 stacktrace
"VM Thread" prio=10 tid=0x000000005e6d9000 nid=0x7141 runnable 

# What about the first pid?
% printf "%0x%x\n" 32149
0x7d95

% grep -A3 nid=0x7d95 stacktrace
2010-06-22 03:15:26.489485500 "1257787176@Jetty Thread Pool-2999 - Acceptor0 SocketConnector@0.0.0.0:2080" prio=10 tid=0x00002aad3dd43000 nid=0x7d95 runnable [0x00002aadc62d9000]
2010-06-22 03:15:26.489507500    java.lang.Thread.State: RUNNABLE
2010-06-22 03:15:26.489512500   at java.net.PlainSocketImpl.socketAccept(Native Method)
2010-06-22 03:15:26.489518500   at java.net.PlainSocketImpl.accept(PlainSocketImpl.java:390)
```

From the above output, I can conclude that the most cpu-intensive threads in my
java process are the Jetty socket acceptor thread and the "VM Thread". A red flag
should pop up in your brain if a 4-hour-old process has spent 2.25 hours spinning
in accept().

FYI, googling for "VM Thread" and various java keywords doesn't seem to find much
documentation, though most folks claim it has GC and other maintenance-related
duties. I am not totally sure what it does.

In fact, if you look at the top 10 pids, none of them are actually anything
that runs the application code - they are all management threads (thread pool,
socket listener, garbage collection) outside of my application.

```
32149 1257787176@Jetty Thread Pool-2999 - Acceptor0 SocketConnector@0.0.0.0:2080
28993 VM Thread
28995 Finalizer
32151 pool-7-thread-1
29143 pool-3-thread-1
28990 GC task thread#5 (ParallelGC)
28989 GC task thread#4 (ParallelGC)
28992 GC task thread#7 (ParallelGC)
28986 GC task thread#1 (ParallelGC)
28988 GC task thread#3 (ParallelGC)
```

To be fair to the rest of this app, there are 3000 worker threads that each
have around 40 minutes (or less) of cpu time, so the application is doing
useful work, it's important to observe where you are wasting time - in this
case, the jetty accept thread. The GC-related data may be an indication that
garbage collection could be tuned or avoided (through thread-local storage,
etc).

Lastly, since each of these IDs are LWP IDs, you can use other standard tools
(strace/truss, systemtap/dtrace, etc) on them.

Knowing the accept thread is consuming lots of time should make you run 
[tcpdump](http://sysadvent.blogspot.com/2008/12/sysadmin-advent-day-1.html)
if you haven't already, and in this case I see a few hundred new connections
per second, which isn't very high and leads us further down the road of debugging.
