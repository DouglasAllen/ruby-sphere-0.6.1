set label 1001 "2016/02/11 09:00 - 02/11 15:00 UTC\nfrom NIU at 88:45W,41:57N" at screen 0.95, screen 0.95 right

set size 1, 1
set multiplot

# elevation changes
set origin 0,0
set size 0.7,1
set timefmt "%Y/%m/%d-%H:%M:%S"
set xdata time
set xrange ["2016/02/11-09:00:00":"2016/02/11-15:00:00"]
set xlabel "UTC (hours)"
set format x "%H"
set xtics 3600
set mxtics 6
set xtics nomirror
set x2data time
set x2range ["1970/01/01-12:28:31":"1970/01/01-18:29:30"]
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
set label 1002 "" at "2016/02/11-10:00:00",graph 0 point pt 11
set label 1003 "" at "2016/02/11-12:00:00",graph 0 point pt 13
set label 1004 "" at "2016/02/11-14:00:00",graph 0 point pt 15
set label 1005 "sunrise 12:56" at "2016/02/11-12:56:39",graph 0.98 right rotate nopoint
set label 1006 "nautical 11:54" at "2016/02/11-11:54:55",graph 0.98 right rotate nopoint
# no star is visible
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
# no star is visible
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
