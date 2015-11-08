set label 1001 "2015/11/08 09:00 - 11/08 15:00 UTC\nfrom NIU at 88:45W,41:57N" at screen 0.95, screen 0.95 right

set size 1, 1
set multiplot

# elevation changes
set origin 0,0
set size 0.7,1
set timefmt "%Y/%m/%d-%H:%M:%S"
set xdata time
set xrange ["2015/11/08-09:00:00":"2015/11/08-15:00:00"]
set xlabel "UTC (hours)"
set format x "%H"
set xtics 3600
set mxtics 6
set xtics nomirror
set x2data time
set x2range ["1970/01/01-06:13:58":"1970/01/01-12:14:57"]
set x2label "LST (hours)"
set x2tics 3600
set mx2tics 6
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
set label 1002 "" at "2015/11/08-10:00:00",graph 0 point pt 11
set label 1003 "" at "2015/11/08-12:00:00",graph 0 point pt 13
set label 1004 "" at "2015/11/08-14:00:00",graph 0 point pt 15
set label 1005 "sunrise 12:35" at "2015/11/08-12:35:54",graph 0.98 right rotate nopoint
set label 1006 "nautical 11:33" at "2015/11/08-11:33:06",graph 0.98 right rotate nopoint
plot "Jupiter.dat" using 1:5 title "Jupiter 11.3h" with lines, "Mars.dat" using 1:5 title "Mars 11.9h" with lines, "Venus.dat" using 1:5 title "Venus 12.0h" with lines, "Mercury.dat" using 1:5 title "Mercury 14.5h" with lines, "Sun.dat" using 1:5 title "Sun 14.9h" with lines
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
set label 1007 "N" at 0,80 center front
set label 1008 "E" at -80,0 right front
set label 1009 "S" at 0,-80 center front
set label 1010 "W" at 80,0 left front
set label 1011 "" at -61.90277539574667,-17.981995507736013 point pt 11
set label 1012 "" at -32.15776624846542,-31.717889606825512 point pt 13
set label 1013 "" at -0.45460994983410163,-36.161304892093234 point pt 15
set label 1014 "" at -71.6452243223374,-15.51432884196931 point pt 11
set label 1015 "" at -42.20536731561442,-32.19226012442328 point pt 13
set label 1016 "" at -10.257341443938802,-39.20579069255405 point pt 15
set label 1017 "" at -44.75402146888548,-32.64080101518481 point pt 13
set label 1018 "" at -12.731834480105338,-40.2614099083386 point pt 15
set label 1019 "" at -55.91360298366812,-45.77894379665864 point pt 15
plot "Jupiter.dat" using ($3+90):(90-$4) notitle with lines, "Mars.dat" using ($3+90):(90-$4) notitle with lines, "Venus.dat" using ($3+90):(90-$4) notitle with lines, "Mercury.dat" using ($3+90):(90-$4) notitle with lines, "Sun.dat" using ($3+90):(90-$4) notitle with lines
unset label 1019
unset label 1017
unset label 1018
unset label 1014
unset label 1015
unset label 1016
unset label 1011
unset label 1012
unset label 1013
unset label 1007
unset label 1008
unset label 1009
unset label 1010
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
