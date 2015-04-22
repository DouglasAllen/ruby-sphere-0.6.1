set label 1001 "2015/04/22 00:00 - 04/22 10:00 UTC\nfrom NIU at 88:45W,41:56N" at screen 0.95, screen 0.95 right

set size 1, 1
set multiplot

# elevation changes
set origin 0,0
set size 0.7,1
set timefmt "%Y/%m/%d-%H:%M:%S"
set xdata time
set xrange ["2015/04/22-00:00:00":"2015/04/22-10:00:00"]
set xlabel "UTC (hours)"
set format x "%H"
set xtics 7200
set mxtics 4
set xtics nomirror
set x2data time
set x2range ["1970/01/01-08:03:57":"1970/01/01-18:05:35"]
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
set label 1002 "" at "2015/04/22-02:00:00",graph 0 point pt 3
set label 1003 "" at "2015/04/22-04:00:00",graph 0 point pt 5
set label 1004 "" at "2015/04/22-06:00:00",graph 0 point pt 7
set label 1005 "" at "2015/04/22-08:00:00",graph 0 point pt 9
set label 1006 "" at "2015/04/22-10:00:00",graph 0 point pt 11
set label 1007 "sunset 00:42" at "2015/04/22-00:42:29",graph 0.98 right rotate nopoint
set label 1008 "nautical 01:47" at "2015/04/22-01:47:44",graph 0.98 right rotate nopoint
set label 1009 "nautical 09:59" at "2015/04/22-09:59:01",graph 0.98 right rotate nopoint
plot "Vir.dat" using 1:5 title "Vir 13.3h" with lines
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
set label 1014 "" at -53.009820970256044,-32.69352230701965 point pt 3
set label 1015 "" at -20.763426156886847,-42.31167107848109 point pt 5
set label 1016 "" at 12.394959412110763,-43.3571413472505 point pt 7
set label 1017 "" at 45.024922342734854,-36.000471640515414 point pt 9
plot "Vir.dat" using ($3+90):(90-$4) notitle with lines
unset label 1014
unset label 1015
unset label 1016
unset label 1017
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
