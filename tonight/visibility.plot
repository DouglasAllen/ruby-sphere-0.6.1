set label 1001 "2015/04/20 18:00 - 04/21 06:00 UTC\nfrom NIU at 88:45W,41:56N" at screen 0.95, screen 0.95 right

set size 1, 1
set multiplot

# elevation changes
set origin 0,0
set size 0.7,1
set timefmt "%Y/%m/%d-%H:%M:%S"
set xdata time
set xrange ["2015/04/20-18:00:00":"2015/04/21-06:00:00"]
set xlabel "UTC (hours)"
set format x "%H"
set xtics 7200
set mxtics 4
set xtics nomirror
set x2data time
set x2range ["1970/01/01-01:59:01":"1970/01/01-14:00:59"]
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
set label 1002 "" at "2015/04/20-20:00:00",graph 0 point pt 21
set label 1003 "" at "2015/04/20-22:00:00",graph 0 point pt 23
set label 1004 "" at "2015/04/21-00:00:00",graph 0 point pt 1
set label 1005 "" at "2015/04/21-02:00:00",graph 0 point pt 3
set label 1006 "" at "2015/04/21-04:00:00",graph 0 point pt 5
set label 1007 "" at "2015/04/21-06:00:00",graph 0 point pt 7
set label 1008 "sunset 00:41" at "2015/04/21-00:41:23",graph 0.98 right rotate nopoint
set label 1009 "nautical 01:46" at "2015/04/21-01:46:23",graph 0.98 right rotate nopoint
plot "Psc.dat" using 1:5 title "Psc 0.3h" with lines, "Ari.dat" using 1:5 title "Ari 2.5h" with lines, "Tau.dat" using 1:5 title "Tau 4.5h" with lines, "Gem.dat" using 1:5 title "Gem 7.0h" with lines, "Cnc.dat" using 1:5 title "Cnc 8.5h" with lines, "Leo.dat" using 1:5 title "Leo 10.5h" with lines, "Vir.dat" using 1:5 title "Vir 13.3h" with lines, "Lib.dat" using 1:5 title "Lib 15.2h" with lines, "Sco.dat" using 1:5 title "Sco 16.3h" with lines, "Aqr.dat" using 1:5 title "Aqr 22.3h" with lines
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
set label 1014 "" at 54.87303902050524,-17.025790353039735 point pt 21
set label 1015 "" at 21.358173778046336,-19.51796716951761 point pt 21
set label 1016 "" at 48.37194472572501,-8.347481118963943 point pt 23
set label 1017 "" at 70.1576753015456,12.989964661874629 point pt 1
set label 1018 "" at -7.498663184946457,-23.647058492822396 point pt 21
set label 1019 "" at 21.804826191132616,-21.497061961798668 point pt 23
set label 1020 "" at 49.358944252035876,-10.26864256956151 point pt 1
set label 1021 "" at 71.79576003720652,11.256120305247574 point pt 3
set label 1022 "" at -41.37035220781771,-9.951443884669212 point pt 21
set label 1023 "" at -14.22091508301474,-18.836069500644935 point pt 23
set label 1024 "" at 14.145736202950692,-18.84770824699239 point pt 1
set label 1025 "" at 41.30192788849532,-9.987545275643162 point pt 3
set label 1026 "" at 64.1541096970241,8.593979409580205 point pt 5
set label 1027 "" at -60.370678239134314,1.0980285219194812 point pt 21
set label 1028 "" at -35.444675680292654,-15.039467072099695 point pt 23
set label 1029 "" at -7.21615224817335,-21.659340421911974 point pt 1
set label 1030 "" at 21.590313335399806,-19.464181514102606 point pt 3
set label 1031 "" at 48.57772197085621,-8.216040654865473 point pt 5
set label 1032 "" at 70.29976416753048,13.211001628056565 point pt 7
set label 1033 "" at -63.33406560359353,-3.8023138291114678 point pt 23
set label 1034 "" at -36.90902488560243,-20.0566699931137 point pt 1
set label 1035 "" at -7.429890407177263,-26.66520315046851 point pt 3
set label 1036 "" at 22.573974304352852,-24.44430157768629 point pt 5
set label 1037 "" at 50.89555512248431,-13.117643074983087 point pt 7
set label 1038 "" at -54.030724173654775,-32.21924674260672 point pt 3
set label 1039 "" at -21.842895300584093,-42.13701399753386 point pt 5
set label 1040 "" at 11.30912303500672,-43.45340693972498 point pt 7
set label 1041 "" at -53.52415342932286,-46.4655427356859 point pt 5
set label 1042 "" at -19.70017056346048,-54.709235178629136 point pt 7
plot "Psc.dat" using ($3+90):(90-$4) notitle with lines, "Ari.dat" using ($3+90):(90-$4) notitle with lines, "Tau.dat" using ($3+90):(90-$4) notitle with lines, "Gem.dat" using ($3+90):(90-$4) notitle with lines, "Cnc.dat" using ($3+90):(90-$4) notitle with lines, "Leo.dat" using ($3+90):(90-$4) notitle with lines, "Vir.dat" using ($3+90):(90-$4) notitle with lines, "Lib.dat" using ($3+90):(90-$4) notitle with lines, "Sco.dat" using ($3+90):(90-$4) notitle with lines, "Aqr.dat" using ($3+90):(90-$4) notitle with lines
unset label 1041
unset label 1042
unset label 1038
unset label 1039
unset label 1040
unset label 1033
unset label 1034
unset label 1035
unset label 1036
unset label 1037
unset label 1027
unset label 1028
unset label 1029
unset label 1030
unset label 1031
unset label 1032
unset label 1022
unset label 1023
unset label 1024
unset label 1025
unset label 1026
unset label 1018
unset label 1019
unset label 1020
unset label 1021
unset label 1015
unset label 1016
unset label 1017
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
