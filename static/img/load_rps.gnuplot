set encoding utf8
#set term svg size 800, 494 font "Lucida Grande"
set term svg size 800, 494 font "avenir,20"
set output "load_rps.svg"
#set title "Throughput" font "Lucida Grande,16"
set title "Throughput" font "avenir,24"
set xlabel "Concurrency"
set ylabel "RPS"
set tmargin 3
set xtics (2,20,39,50,100,150) nomirror
set ytics (50,100,150,200) nomirror
set grid xtics ytics
set key off
set xrange [-3:155]
set yrange [50:220]
plot [] [*:*] \
"-" using 1:2 smooth mcsplines with lines lw 2,\
"-" using 1:2 with points,\
"-" using 1:2 with lines lw 2,\
"-" using 1:2 with points ps 1 pt 13
2 65.4
20 175.6
50 190.0
100 196.5
150 198.6
e
2 65.4
20 175.6
50 190.0
100 196.5
150 198.6
e
-3 187
39 187
39 0
e
39 187
e
