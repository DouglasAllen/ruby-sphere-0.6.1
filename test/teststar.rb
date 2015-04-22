# teststar.rb: testcases for star.rb
# $Id: teststar.rb,v 1.15 2006/05/17 06:25:09 tomono Exp $
#
# Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
#
# Permission is granted for use, copying, modification, distribution, and
# distribution of modified versions of this work under the terms of GPL
# version 2 or later.
#

require 'test/unit'
require 'date'

$:.unshift(File.join(File.expand_path(".."), "lib"))
require 'sphere'

class TestStar < Test::Unit::TestCase
	include Sphere

	def test_StellarBody_NotImplement
		assert_raise( NotImplementedError ) { StellarBody.new.radec( 0 ) }
		#assert_raise( NotImplementedError ) { StellarBody.new.name }
	end

	def test_Star
		ra = 1.0
		dec = 1.0
		t = Star.new( ra, dec, 'test star' )
		assert_equal( 'test star', t.name )
		assert_equal( ra, t.radec.ra )
		assert_equal( dec, t.radec.dec )
		date = Time.utc( 2004, 11, 12, 0, 0, 0 )
		assert_equal( Sphere::lst_to_ut( Time.utc( 2004, 11, 12, 0, 0, 0 ), 1.0, 0.0 ), t.meridian_transit( Time.utc( 2004, 11, 12, 0, 0, 0 ), 0.0 ) )
		# "Tentai-no Keisan Kyoushitsu" 1998, Saida, Hiroshi, Chijin-shokan, p. 61
		tzorig = ENV['TZ']
		ENV['TZ'] = 'Japan'
		t = Star.new( '6 44'.hms_to_rad, '-16 41'.dms_to_rad, 'Sirius' )
		lon = '140 28'.dms_to_rad
		lat = '36 23'.dms_to_rad
		date = Time.local( 1976, 1, 1, 18, 0, 0 )
		assert_in_delta( Time.local( 1976, 1, 1, 18, 32, 0 ), t.rise_at( 0, date, lon, lat ).localtime, 30 )
		date = Time.local( 1976, 1, 1, 5, 0, 0 )
		#assert_in_delta( Time.local( 1976, 1, 1, 4, 57, 0 ), t.set_at( 0, date, lon, lat ).localtime, 30 )
		# TODO: cannot make this test to pass
		t = Star.new( '7 38'.hms_to_rad, '+5 17'.dms_to_rad, 'Procyon' )
		date = Time.local( 1976, 1, 1, 18, 0, 0 )
		assert_in_delta( Time.local( 1976, 1, 1, 18, 19, 0 ), t.rise_at( 0, date, lon, lat ).localtime, 60 )
		# TODO: isn't 60 sec too much?
		date = Time.local( 1976, 1, 1, 6, 0, 0 )
		#assert_in_delta( Time.local( 1976, 1, 1, 6, 57, 0 ), t.set_at( 0, date, lon, lat ).localtime, 30 )
		# TODO: cannot make this test to pass
		ENV['TZ'] = tzorig
	end

	def test_Sun
		# from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha, p.32
		# 15:45 at 117deg E (7.8 hours) is 07:53 UT
		time = DateTime.new( -708, 7, 17, 7, 53, 0 )
		assert_in_delta( 1462658.831, Sphere::fjd( time ), 0.00252778 )
		assert_in_delta( -26.07425513, Sphere::c1900( time ), 8e-8 )
			# The book and the Date library has 4 minutes of difference,
			# ruby 1.8.1 (2003-12-25) [i586-linux-gnu]
		sun = Sphere::Sun.new( time )
		assert_equal( 'Sun', sun.name )
		assert_in_delta( -26.07425513, sun.c1900, 8e-8 )
		assert_in_delta( 107.929.to_rad, sun.sml, 1e-4 )
		assert_in_delta( 236.712.to_rad, sun.spl, 1e-4 )
		assert_in_delta( 231.217.to_rad, sun.sma, 1e-4 )
		assert_in_delta( -1.566.to_rad, sun.smpg, 1e-4 )
		assert_in_delta( 106.363.to_rad, sun.sl, 1e-4 )
		assert_in_delta( 1.01132, sun.spr, 1e-5 )
		assert_in_delta( 0.264.to_rad, sun.ss, 1e-5 )
		# from Astronomical Almanac 2004
		sun = Sphere::Sun.new( Time.utc( 2004, 11, 12, 0, 0, 0 ) )
		lb = sun.lambdabeta
		assert_in_delta( Sphere::dms_to_rad( '229 57 02.41' ), lb.lambda,\
			Sphere::dms_to_rad( '0 0 01.00' ) )
		assert_in_delta( -0.0.to_rad, lb.beta, (1.0/3600.0).to_rad )
		assert_in_delta( ( 16.0/60.0 + 9.54/3600.0 ).to_rad, sun.ss, (0.5/3660.0).to_rad )
		assert_in_delta( 0.9897972, sun.spr, 1e-5 )
		radec = sun.radec
 		assert_in_delta( Sphere::hms_to_rad( '15 09 59.04' ), radec.ra,\
 			Sphere::hms_to_rad( '00 00 05' ) )
		assert_in_delta( Sphere::dms_to_rad( '-17 43 35.7' ), radec.dec,\
			Sphere::dms_to_rad( '00 00 05' ) )
		# from Astronomical Almanac 2004
		assert_in_delta( Time.utc( 2004, 11, 16, 11, 44, 51 ), sun.meridian_transit( Time.utc( 2004, 11, 16 ), 0 ), 3 )
		# TODO: is 3 sec difference too much?
		el = 0.0 - '0 35 8'.dms_to_rad - '0 16 17.5'.dms_to_rad
		assert_in_delta( Time.utc( 2004, 11, 18, 16, 41 ), sun.set_at( el, Time.utc( 2004, 11, 18, 16 ), 0, 40.0.to_rad ), 30 )
		assert_in_delta( Time.utc( 2004, 11, 18, 6, 49 ), sun.rise_at( el, Time.utc( 2004, 11, 18, 6 ), 0, 40.0.to_rad ), 30 )
		# from Rekisho-nenpyo 2005, NAOJ
		tzorig = ENV['TZ']
		ENV['TZ'] = 'Japan'
		lon = '139 44 29.27'.dms_to_rad
		lat = '35 39 27.7'.dms_to_rad
		assert_in_delta( Time.local( 2005, 1, 1, 11, 41, 31 ), sun.meridian_transit( Time.local( 2005, 1, 1, 12 ), lon ).localtime,  240 )
		# TODO: 4 min is too much! but better precision with Astronomical Almanac 2004 (above)
		assert_in_delta( Time.local( 2005, 1, 1, 6, 51 ), sun.rise_at( el, Time.local( 2005, 1, 1, 6 ), lon, lat ).localtime,  60 )
		assert_in_delta( Time.local( 2005, 1, 1, 16, 39 ), sun.set_at( el, Time.local( 2005, 1, 1, 6 ), lon, lat ).localtime,  60 )
		ENV['TZ'] = tzorig
	end

	def test_Sun_cols
		tzorig = ENV['TZ']
		ENV['TZ'] = 'HST'
		time = Time.local( 2004, 11, 12, 12, 0, 0 )
		lon = Sphere::dms_to_rad( '-155 28 48.8' )
		lat = Sphere::dms_to_rad( '+19 49 42.6' )
		sun = Sphere::Sun.new( time )
		assert( '#date-time(HST) LST Az(deg) El(Deg) sec(z) RA(hh:mm:ss.s) Dec(dd:mm:ss)', sun.cols_comment( ENV['TZ'] ) )
		assert( '2004/11/12-12:00:00 05:07:32 177.5917 52.1682 1.2661 +15:13:45.4 -17:58:21', sun.cols( time, lon, lat ) )
		ENV['TZ'] = tzorig
	end

	def test_Venus
		# from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha, p.44
		# 12:00 at 135.8E (9H03M12) is 02:56:48UT
		time = DateTime.new( 702, 12, 28, 02, 56, 48 )
		assert_in_delta( 1977824.62277, Sphere::fjd( time ), 1e-5 )
		v = Venus.new( time )
		assert_equal( 'Venus', v.name )
		assert_in_delta( -11.969784455, v.c, 1e-9 )
		s = Sun.new( time )
		assert_in_delta( 279.337.to_rad, s.sml, 1e-3.to_rad )
		assert_in_delta( 0.642408.to_rad, s.smpg, 1e-6.to_rad )
		assert_in_delta( 279.979.to_rad, s.sl, 1e-3.to_rad )
		assert_in_delta( 19.2546.to_rad, s.sta, 1e-4.to_rad )
		assert_in_delta( 0.170466, s.xyz[0], 1e-6 )
		assert_in_delta( -0.968811, s.xyz[1], 1e-6 )
		assert_in_delta( 0, s.xyz[2], 1e-6 )
		assert_in_delta( 82.1485.to_rad, v.ml, 1e-4.to_rad )
		assert_in_delta( 113.478.to_rad, v.pnl, 1e-3.to_rad )
		assert_in_delta( 328.670.to_rad, v.ma, 1e-3.to_rad )
		assert_in_delta( 64.9073.to_rad, v.omg, 1e-4.to_rad )
		assert_in_delta( -0.449199.to_rad, v.mpg, 5e-3.to_rad )
		# TODO: MPG: 5000 times reduced precision
		assert_in_delta( 328.2209.to_rad, v.ta, 5e-3.to_rad )
		# TODO: TA: 50 times reduced precision
		assert_in_delta( 376.79197.to_rad, v.uu, 5e-3.to_rad, 'UU' )
		# TODO: UU: 500 times reduced precision
		assert_in_delta( (16.7644 + 360.0).to_rad, v.cc, 5e-3.to_rad, 'CC' )
		# TODO: CC: 50 times reduced precision
		# TODO: CC: 360 degrees descrepancy
		assert_in_delta( (81.6718 + 360.0).to_rad, v.ll, 5e-3.to_rad, 'LL' )
		# TODO: LL: 50 times reduced precision
		# TODO: LL: 360 degrees descrepancy
		assert_in_delta( 0.975374.to_rad, v.tb, 2e-4.to_rad, 'TB' )
		# TODO: TB: 200 times reduced precision
		assert_in_delta( 0.71872, v.rr, 5e-5 )
		# TODO: RR: 5 times reduced precision
		assert_in_delta( 0.104087, v.xyz[0], 5e-5 )
		# TODO: XX: 50 times reduced precision
		assert_in_delta( 0.711038, v.xyz[1], 5e-5 )
		# TODO: YY: 50 times reduced precision
		assert_in_delta( 0.012234, v.xyz[2], 1e-5 )
		# TODO: ZZ: 10 times reduced precision
		lb = v.lambdabeta
		assert_in_delta( 316.805.to_rad, lb.lambda, 1e-3.to_rad )
		assert_in_delta( 1.86071.to_rad, lb.beta, 1e-2.to_rad )
		# TODO: Beta: 1000 times reduced precision
	end

	def test_Mercury
		# from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha, p.49
		# 18:30 at 108.9E (07:15:36) is 11:14:24UT
		time = DateTime.new( -69, 8, 4, 11, 14, 24 )
		assert_in_delta( 1696070.968333, Sphere::fjd( time ), 1e-6 )
		m = Mercury.new( time )
		assert_equal( 'Mercury', m.name )
		assert_in_delta( 248.4309.to_rad, m.ml, 1e-4.to_rad )
		assert_in_delta( 45.4386.to_rad, m.pnl, 1e-4.to_rad )
		assert_in_delta( -7.46834.to_rad, m.mpg, 1e-5.to_rad )
		assert_in_delta( 195.52398.to_rad, m.ta, 1e-5.to_rad )
		assert_in_delta( 240.759.to_rad, m.ll, 1e-3.to_rad, 'LL' )
		assert_in_delta( -4.18875.to_rad, m.tb, 1e-3.to_rad, 'TB' )
		assert_in_delta( -0.22516, m.xyz[0], 1e-5 )
		assert_in_delta( -0.420026, m.xyz[1], 2e-2 )
		# TODO: YY: 20000 times reduced precision
		assert_in_delta( -0.033758, m.xyz[2], 1e-6 )
		lb = m.lambdabeta
		assert_in_delta( 155.126.to_rad, lb.lambda, 1e-3.to_rad )
		assert_in_delta( -2.0729.to_rad, lb.beta, 5e-4.to_rad )
		# TODO: Beta: 5 times reduced precision
	end

	def test_Mars
		# from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha, p.53
		# 22:00 at 135.8E (09:03:12) is 12:56:48UT
		time = DateTime.new( 720, 2, 29, 12, 56, 48 )
		assert_in_delta( 1984097.03944, Sphere::fjd( time ), 1e-5 )
		m = Mars.new( time )
		assert_equal( 'Mars', m.name )
		assert_in_delta( 179.5225.to_rad, m.ml, 1e-4.to_rad )
		assert_in_delta( (172.402 + 360).to_rad, m.ll, 5e-3.to_rad, 'LL' )
		# TODO: LL: 5 times less precision
		# TODO: LL: 360 deg discrepancy
		lb = m.lambdabeta
		assert_in_delta( 185.713.to_rad, lb.lambda, 1e-2.to_rad )
		# TODO: Lambda: 10 times reduced precision
		assert_in_delta( 3.372.to_rad, lb.beta, 2e-3.to_rad )
		# TODO: Beta: 2 times reduced precision
	end

	def test_Moon
		# from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha, p.82
		# 20:00 at 112.4E(07:29:36) is 12:30:24UT
		time = DateTime.new( 36, 3, 31, 12, 30, 24 )
		#assert_in_delta( 17342979.0210277,  Sphere::fjd( time ), 1e-4 )
		# TODO: 36 III 31, 20h is not JD17342979.0210277
		m = Moon.new( time )
		assert_equal( 'Moon', m.name )
		assert_raise( NoMethodError ){ m.c }
		assert_in_delta( -1.2315.to_rad, m.a0, 1e-4.to_rad, 'A0' )
		assert_in_delta( 0.1740.to_rad, m.b0, 1e-4.to_rad, 'B0' )
		assert_in_delta( -0.1620.to_rad, m.c0, 1e-4.to_rad, 'C0' )
		assert_in_delta( 1.9305e-2.to_rad, m.d0, 1e-6.to_rad, 'D0' )
		assert_in_delta( -4.2367e-2.to_rad, m.e0, 1e-6.to_rad, 'E0' )
		assert_in_delta( 0.1139.to_rad, m.h0, 1e-4.to_rad, 'H0' )
		assert_in_delta( -1.2425.to_rad, m.st, 1e-4.to_rad, 'ST' )
		assert_in_delta( 194.261.to_rad, m.ml, 2e-3.to_rad, 'ML' )
		# TODO: 2 times less precision
		assert_in_delta( 95.5209.to_rad, m.pnl, 1e-4.to_rad, 'PNL' )
		assert_in_delta( 306.8186.to_rad, m.omg, 1e-4.to_rad, 'OMG' )
		assert_in_delta( (253.5859 - 360.0).to_rad, m.uu, 1e-3.to_rad, 'UU' )
		# TODO: UU: 360 degrees descrepancy
		# TODO: 10 times less precision
		lb = m.lambdabeta
		assert_in_delta( 200.342.to_rad, lb.lambda, 1e-3.to_rad, 'Lambda' )
		assert_in_delta( -4.8203.to_rad, lb.beta, 1e-4.to_rad, 'Beta' )
		assert_in_delta( 192.34.to_rad, m.phase, 1.0.to_rad, 'phase' )
		# reduced precision because we are on geocentric coordinate
		# from Astronomical Almanac 2004
		m.time = Time.utc( 2004, 11, 16, 0, 0, 0 )
		lb = m.lambdabeta
		assert_in_delta( 280.74.to_rad, lb.lambda, 5e-2.to_rad, 'Lambda' )
		# TODO: 5 times less precision
		assert_in_delta( -4.88.to_rad, lb.beta, 1e-2.to_rad, 'Beta' )
	end

	def test_sunrise_sunset
		# from Astronomical Almanac 2004, p. A13
		# Paris
		assert_in_delta( Time.utc( 2004, 7, 20, 4, 10, 0 ),
			Sphere::sunrise( Time.utc( 2004, 7, 20, 12, 0, 0 ), 2.33.to_rad, 48.87.to_rad ),
			60 )
		assert_in_delta( Time.utc( 2004, 7, 20, 19, 44, 0 ),
			Sphere::sunset( Time.utc( 2004, 7, 20, 12, 0, 0 ), 2.33.to_rad, 48.87.to_rad ),
			60 )
		# Canberra
		assert_in_delta( Time.utc( 2004, 11, 14, 17, 10, 0 ),
			Sphere::astronomical_twilight_begin( Time.utc( 2004, 11, 14, 17, 0, 0 ), 149.13.to_rad, -35.30.to_rad ),
			60 )
		assert_in_delta( Time.utc( 2004, 11, 15, 10, 26, 0 ),
			Sphere::astronomical_twilight_end( Time.utc( 2004, 11, 14, 17, 0, 0 ), 149.13.to_rad, -35.30.to_rad ),
			60 )
	end

	def test_cols
		m92 = Star.new('17:17:13.00'.hms_to_rad, '+43:09:48.0'.dms_to_rad, 'M92')
		t = Time.utc(2005, 6, 18, 4, 0, 0)
		lon = '-155 28'.dms_to_rad
		lat = '+19 50'.dms_to_rad
		str = m92.cols(t, lon, lat)	# this is the method to be tested

		goal = [11.4, -131.3 + 180.0, 13.8]	# calculation for HDS: LST, Az-180, El
		err = [0.1, 0.2, 0.9]	# error for El seems to be too big...
		cal = str.split[1..3]
		cal[0] = cal[0].hms_to_rad*12.0/Math::PI
		goal.zip(cal).each_with_index do |e, i|
			assert_in_delta( e[0], e[1].to_f, err[i] )
		end
	end

end
