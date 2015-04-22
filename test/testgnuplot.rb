# testgnuplot.rb: testcases for gnuplot.rb
# $Id: testgnuplot.rb,v 1.6 2004/12/21 05:05:33 tomono Exp $
#
# Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
#
# Permission is granted for use, copying, modification, distribution, and
# distribution of modified versions of this work under the terms of GPL
# version 2 or later.
#

require 'test/unit'
$:.unshift(File.join(File.expand_path(".."), "lib"))
require 'sphere'

ENV['TZ'] = 'HST'

class TestGnuPlot < Test::Unit::TestCase
	include Sphere
	attr_reader :plot

	def setup
		@ngc1068 = Star.new(
			# Simbad
			( 2.0 + 42.0/60.0 + 40.83/3600.0 ) / 12.0 * Math::PI,
			-( 0.0 + 0.0/60.0 + 48.4/3600.0 ).to_rad,
			'NGC 1068'
		)
		@plot = GnuPlot.new( \
			Allocation.new( \
				Time.local( 2004, 10, 20, 18, 0, 0 ), \
				Time.local( 2004, 10, 21, 6, 0, 0 ), \
				Observatory::of( 'Mauna Kea' ), \
				'test' \
			)
		)
		@plot.stars << @ngc1068
	end

	def test_datafilename
		assert_equal( 'NGC 1068.dat', @plot.data_filename( @ngc1068 ) )
	end

	def notest_polar_timestamps
		set, unset = @plot.polar_timestamps( @ngc1068 )
		set_goal = <<'_SET'
set label 1001 "22h" at -46.7963456383208,-15.3203643419974 center nopoint
set label 1002 "00h" at -16.2773740741644,-19.318330170272 center nopoint
set label 1003 "02h" at 14.4028857185496,-19.4324949036396 center nopoint
set label 1004 "04h" at 44.9416116175511,-15.688514007467 center nopoint
_SET
		unset_goal = <<'_UNSET'
unset label 1001
unset label 1002
unset label 1003
unset label 1004
_UNSET
		assert_equal( set_goal, set )
		assert_equal( unset_goal, unset )
	end

	def notest_time_plot_setups
		header, footer = @plot.time_plot_setups
		header_goal = <<'_END'
set timefmt "%Y/%m/%d-%H:%M:%S"
set xdata time
set xrange ["2004/10/20-18:00:00":"2004/10/21-06:00:00"]
set xlabel "HST"
set yrange [15:90]
set ylabel "El(deg)"
set format x "%H:%M"
set ytics 15
set mytics 3
set grid
_END
		footer_goal =<<'_END'
unset xdata
unset grid
_END
		assert_equal( header_goal, header )
		assert_equal( footer_goal, footer )
	end

	def notest_time_plot_plots
		@plot.stars << @ngc1068
		plot_goal = %Q|plot "NGC 1068.dat" using 1:5 title "NGC 1068" with lines, "NGC 1068.dat" using 1:5 title "NGC 1068" with lines\n|
		assert_equal( plot_goal, @plot.time_plot_plots )
	end

	def notest_polar_plot_plots
		@plot.stars << @ngc1068
		plot_goal = %Q|plot "NGC 1068.dat" using ($3+90):(90-$4) title "NGC 1068" with lines, "NGC 1068.dat" using ($3+90):(90-$4) title "NGC 1068" with lines\n|
		assert_equal( plot_goal, @plot.polar_plot_plots )
	end

	def notest_polar_plot_setups
		header, footer = @plot.polar_plot_setups
		header_goal =<<'_END'
set polar
set xtics (0, 30, 60, 75)
unset border
set format x ''
set ytics ("15" 75, "30" 60, "60" 30)
set xtics axis nomirror
set ytics axis nomirror
set angles degrees
set size square
set grid polar 30
set xrange [-75:75]
set yrange [-75:75]
set label 1001 "N" at 0,75 center
set label 1002 "E" at -75,0 right
set label 1003 "S" at 0,-75 center
set label 1004 "W" at 75,0 left
_END
		footer_goal =<<'_END'
unset label 1001
unset label 1002
unset label 1003
unset label 1004
unset polar
unset xtics
set border
unset format x
unset ytics
unset anlges
unset size
unset grid
_END
		assert_equal( header_goal, header )
		assert_equal( footer_goal, footer )
	end

	def notest_time_plot
		puts
		puts @plot.time_plot
	end

	def notest_polar_plot
		puts
		puts @plot.polar_plot
	end

	def test_frame_legend
		header, footer = @plot.frame_legend
		#~ p header
		#~ p footer
		header_goal =<<'TFL'
set label 1001 "2004/10/20 18:00 - 10/21 06:00 HST\non test\nfrom Mauna Kea at 155:28W,19:50N" at screen 0.95, screen 0.95 right
TFL
		footer_goal =<<'TFL'
unset label 1001
TFL
		assert_equal( header_goal, header )
		assert_equal( footer_goal, footer )
	end

	def notest_multiplot
		puts
		puts @plot.multiplot
	end

	def notest_creating_files
		@plot.create_plotfile
		@plot.create_datafiles
		#@plot.store_files( 'testgnuplot-files' )
		#puts "\n*** files are stored in testgnuplot-files/\n\n"
	end

	def notest_plot_x11
		@plot.plot
	end

	def test_plot_eps
		@plot.plot( 'postscript eps enhanced', 'visibility.eps' )
		#@plot.store_files( 'testgnuplot-files' )
		#puts "\n*** files are stored in testgnuplot-files/\n\n"
	end

	def test_plot_ps
		@plot.plot( 'postscript landscape enhanced', 'visibility.ps' )
		#@plot.store_files( 'testgnuplot-files' )
		#puts "\n*** files are stored in testgnuplot-files/\n\n"
	end

	def notest_el_range
		@plot.el_min = 45.to_rad
		@plot.el_max = 75.to_rad
		@plot.plot( 'png', 'visibility.png' )
		@plot.store_files( 'testgnuplot-files' )
		puts "\n*** files are stored in testgnuplot-files/\n\n"
	end

	def notest_az_range
		@plot.az_center = 90.to_rad
		@plot.az_halfwidth = 45.to_rad
		@plot.plot( 'png', 'visibility.png' )
		@plot.store_files( 'testgnuplot-files' )
		puts "\n*** files are stored in testgnuplot-files/\n\n"
	end

end
