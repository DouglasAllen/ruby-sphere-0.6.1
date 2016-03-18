set label 1001 "2016/03/17 00:00 - 03/17 16:00 UTC\nfrom NIU at 88:45W,41:57N" at screen 0.95, screen 0.95 right

set size 1, 1
set terminal png size 1200,800
set output 'tonight.png'
#set multiplot

# elevation changes
set origin 0,0
set size 0.7,1
set timefmt "%Y/%m/%d-%H:%M:%S"
set xdata time
set xrange ["2016/03/17-00:00:00":"2016/03/17-16:00:00"]
set xlabel "UTC (hours)"
set format x "%H"
set xtics 7200
set mxtics 4
set xtics nomirror
set x2data time
set x2range ["1970/01/01-05:45:02":"1970/01/01-21:47:39"]
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
set label 1002 "" at "2016/03/17-02:00:00",graph 0 point pt 3
set label 1003 "" at "2016/03/17-04:00:00",graph 0 point pt 5
set label 1004 "" at "2016/03/17-06:00:00",graph 0 point pt 7
set label 1005 "" at "2016/03/17-08:00:00",graph 0 point pt 9
set label 1006 "" at "2016/03/17-10:00:00",graph 0 point pt 11
set label 1007 "" at "2016/03/17-12:00:00",graph 0 point pt 13
set label 1008 "" at "2016/03/17-14:00:00",graph 0 point pt 15
set label 1009 "" at "2016/03/17-16:00:00",graph 0 point pt 17
set label 1010 "sunset 00:04" at "2016/03/17-00:04:32",graph 0.98 right rotate nopoint
set label 1011 "sunrise 12:03" at "2016/03/17-12:03:04",graph 0.98 right rotate nopoint
set label 1012 "nautical 01:04" at "2016/03/17-01:04:53",graph 0.98 right rotate nopoint
set label 1013 "nautical 11:02" at "2016/03/17-11:02:49",graph 0.98 right rotate nopoint
plot "Aldebaran.dat" using 1:5 title "Aldebaran 4.6h" with lines, "Rigel.dat" using 1:5 title "Rigel 5.2h" with lines, "Capella.dat" using 1:5 title "Capella 5.3h" with lines, "Betelgeuse.dat" using 1:5 title "Betelgeuse 5.9h" with lines, "Sirius.dat" using 1:5 title "Sirius 6.7h" with lines, "Procyon.dat" using 1:5 title "Procyon 7.7h" with lines, "Pollux.dat" using 1:5 title "Pollux 7.8h" with lines, "Jupiter.dat" using 1:5 title "Jupiter 11.2h" with lines
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
unset label 1010
unset label 1011
unset label 1012
unset label 1013

