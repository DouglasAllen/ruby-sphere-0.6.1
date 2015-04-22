set label 1001 "2004/10/20 18:00 - 10/21 06:00 HST\non test\nfrom Mauna Kea at 155:28W,19:50N" at screen 0.95, screen 0.95 right

set size 1, 1
set multiplot

# elevation changes
set origin 0,0
set size 0.7,1
set timefmt "%Y/%m/%d-%H:%M:%S"
set xdata time
set xrange ["2004/10/20-18:00:00":"2004/10/21-06:00:00"]
set xlabel "HST (hours)"
set format x "%H"
set xtics 7200
set mxtics 4
set xtics nomirror
set x2data time
set x2range ["1970/01/01-19:37:54":"1970/01/02-07:39:52"]
set x2label "LST (hours)"
set x2tics 7200
set mx2tics 4
set format x2 "%H"
set yrange [3.8637033051562737:1.0]
set ylabel "sec(z)"
set ytics auto
set mytics 5
set ytics nomirror
set y2label "El(deg)"
set y2tics ("15" 3.8637033051562737, "30" 2.0, "45" 1.4142135623730951, "60" 1.1547005383792517, "75" 1.035276180410083)
set grid
set key bottom
set key samplen 2
set label 1002 "" at "2004/10/20-20:00:00",graph 0 point pt 21
set label 1003 "" at "2004/10/20-22:00:00",graph 0 point pt 23
set label 1004 "" at "2004/10/21-00:00:00",graph 0 point pt 1
set label 1005 "" at "2004/10/21-02:00:00",graph 0 point pt 3
set label 1006 "" at "2004/10/21-04:00:00",graph 0 point pt 5
set label 1007 "" at "2004/10/21-06:00:00",graph 0 point pt 7
set label 1008 "nautical 18:42" at "2004/10/20-18:42:26",graph 0.98 right rotate nopoint
set label 1009 "nautical 05:30" at "2004/10/21-05:30:43",graph 0.98 right rotate nopoint
plot "NGC 1068.dat" using 1:5 title "NGC 1068 2.7h" with lines
unset timefmt
unset xdata
set xrange [*:*]
unset xlabel
set mxtics
set yrange [*:*] noreverse
unset ylabel
set format x "% g"
set xtics mirror
unset x2label
unset x2tics
set ytics auto
set mytics
unset y2label
unset y2tics
set ytics mirror
unset grid
set key default
unset label 1002
unset label 1003
unset label 1004
unset label 1005
unset label 1006
unset label 1007
unset label 1008
unset label 1009

# polar plot
set origin 0.65,0
set size 0.35,1
set polar
set xtics (5, 30, 60, 75)
unset border
set format x ""
set ytics ("15" 75, "30" 60, "60" 30, "85" 5)
set xtics axis nomirror
set ytics axis nomirror
set angles degrees
set size square
set grid polar 30
set xrange [-75:75]
set yrange [-75:75]
set label 1010 "N" at 0,80 center front
set label 1011 "E" at -80,0 right front
set label 1012 "S" at 0,-80 center front
set label 1013 "W" at 80,0 left front
set label 1014 "" at -46.78305470942573,-15.326844233229348 point pt 23
plot "NGC 1068.dat" using ($3+90):(90-$4) notitle with lines
unset label 1014
unset label 1010
unset label 1011
unset label 1012
unset label 1013
unset polar
unset xtics
set xtics auto
set border
set format x "% g"
unset ytics
set ytics auto
unset angles
set grid nopolar
set grid xtics ytics
unset grid
set size nosquare
set xrange [*:*]
set yrange [*:*]

unset multiplot
unset size

unset label 1001
