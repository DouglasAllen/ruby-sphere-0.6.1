# testwcs.rb: testcases for wcs.rb
# $Id: testwcs.rb,v 1.5 2005/12/07 23:41:09 tomono Exp $
#
# Copyright (C) 2005 Daigo Tomono <dtomono at freeshell.org>
#
# Permission is granted for use, copying, modification, distribution, and
# distribution of modified versions of this work under the terms of GPL
# version 2 or later.
#

require 'test/unit'
$:.unshift(File.join(File.expand_path(".."), "lib"))
require 'sphere'

class TestWCS < Test::Unit::TestCase
	include Sphere

	def test_wcs_cd_set
		# both should work
		wcs1 = WCS.new
		wcs1.cd = [[-0.003.to_rad, 0.0.to_rad], [0.0.to_rad, 0.003.to_rad]]
		wcs2 = WCS.new
		wcs2.cd = Matrix[[-0.003.to_rad, 0.0.to_rad], [0.0.to_rad, 0.003.to_rad]]
		assert_equal( wcs1, wcs2 )
	end

	def setup
		# `FITS no Tebiki Rev. 5' 2004, Astronomical Data Analysis Center,
		# National Astronomical Observatory of Japan,
		# ((<URL:http://www.fukuoka-edu.ac.jp/~kanamitu/fits/fits_t50/>))
		@wcs = WCS.new(
			[[-0.003.to_rad, 0.0.to_rad], [0.0.to_rad, 0.003.to_rad]],
			'TAN',
			180.to_rad,
			RaDec.new( 45.83.to_rad, 63.57.to_rad )
		)

		@tests = [
			[[   1.0,   2.0 ], [ 47.503264, 62.795111 ]],
			#[[   1.0, 512.0 ], [ 47.595581, 64.324332 ]],
			# reference seems to be wrong
			[[ 511.0, 512.0 ], [ 44.064419, 64.324332 ]],
		]
	end

	def test_reverse_conversion
		@tests.each do|t|
			src = XY.new( t[0][0] - 256.0, t[0][1] - 257.0 )
			dst = @wcs.radec_to_xy( @wcs.xy_to_radec( src ) )
			assert_in_delta( src.x, dst.x, 0.000001, "X from (#{t[0][0]}.#{t[0][1]})" )
			assert_in_delta( src.y, dst.y, 0.000001, "Y from (#{t[0][0]}.#{t[0][1]})" )
		end
	end

	def test_to_radec
		@tests.each do|t|
			pix = XY.new( t[0][0] - 256.0, t[0][1] - 257.0 )
			radec = pix.to_radec( @wcs )
			assert_in_delta( radec.ra.to_deg, t[1][0], 0.000001, "RA from (#{t[0][0]},#{t[0][1]})" )
			assert_in_delta( radec.dec.to_deg, t[1][1], 0.000001, "Dec from (#{t[0][0]},#{t[0][1]})" )
		end
	end

	def test_on_comics
		# from ds9
		crpix = XY.new( 185.0, 115.0 )
		ctype = 'TAN'
		longpole = 180.0.to_rad
		radec = RaDec.new( 169.61966250.to_rad, 33.09435278.to_rad )
		#cd = Matrix[[0, -1], [-1, 0]]*0.00003611.to_rad	# from CDij
		#cd = Matrix[[0, 1], [1, 0]]*0.00003611.to_rad	# from PCij
		cd = Matrix[[1, 0], [0, 1]]*0.00003611.to_rad	# INST-PA: 0
		wcs = WCS.new( cd, ctype, longpole, radec )
		puts
		{
			[185,115] => %w(11:18:28.719 +33:05:39.67),
			[1,1] => %w(11:18;29.898 +33:06:03.59),
			[320,1] => %w(11:18:29.898 +33:05:22.12),
			[1,240] => %w(11:18:27.426 +33:06:03.59),
			[320,240] => %w(11:18:27.426 +33:05:22.12),
		}.each_pair do |p, r|
		  pix = XY.new( p[0], p[1] ) - crpix
			goal = RaDec.new( r[0].hms_to_rad, r[1].dms_to_rad )
			radec = pix.to_radec( wcs )
			#puts "#{pix+crpix}\tgoal:#{goal.coord( 1 )}\n\t\tgot: #{radec.coord( 1 )}"
			assert_equal( goal.coord( 1 ), radec.coord( 1 ), "from #{pix + crpix}" )
			assert_in_delta( goal.ra.to_deg, radec.ra.to_deg, 0.001/3600*15, "RA from #{pix + crpix}" )
			#assert_in_delta( goal.dec.to_deg, radec.dec.to_deg, 0.01/3600, "Dec from #{pix + crpix}" )
		end
	end

	def test_plus_minus
		assert_equal( XY.new( 1, 2 ) + XY.new( 3, 4 ), XY.new( 4, 6 ) )
		assert_equal( XY.new( 1, 2 ) - XY.new( 3, 4 ), XY.new( -2, -2 ) )
	end

	def test_to_s
		assert_equal( '(1,2)', XY.new( 1, 2 ).to_s )
	end
end

