set encoding utf8
#set term svg size 800, 494 font "Lucida Grande"
set term svg size 800, 494 font "avenir,20"
set output "load_ms.svg"
set title "Performance" font "avenir,24"
set xlabel "Concurrency"
set ylabel "ms"
set tmargin 3
set xtics (2,20,39,50,100,150) nomirror
set ytics (0,200,400,600,800,1000) nomirror
set grid xtics ytics
set key off
set xrange [-3:155]
set yrange [0:800]
plot [] [*:*] \
"-" using 1:2 smooth mcsplines with lines lw 2,\
"-" using 1:2 with points,\
"-" using 1:2 with lines lw 2,\
"-" using 1:2 with points ps 1 pt 13,\
"-" using 1:2 with lines lw 1
2 28.3
20 111.0
50 249.1
100 494.2
150 756.3
e
2 28.3
20 111.0
50 249.1
100 494.2
150 756.3
e
-3 200
39 200
39 0
e
39 200
e
0 0
e
