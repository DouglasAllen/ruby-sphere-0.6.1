# testsatellite.rb: testcases for satellite.rb
#
# Copyright (C) 2007 Daigo Tomono <dtomono at freeshell.org>
#
# Permission is granted for use, copying, modification, distribution, and
# distribution of modified versions of this work under the terms of GPL
# version 2 or later.
#

require 'test/unit'
require 'date'

$:.unshift(File.join(File.expand_path(".."), "lib"))
require 'sphere'

# test in this file are based on a calculation of
# http://www.lizard-tail.com/isana/lab/googlesat/test/googlesat.js
class TestSatellite < Test::Unit::TestCase
	include Sphere
	def setup
		@tle = Satellite::TLE.new(<<'_END')	# ISS
1 25544U 98067A   07297.39694683  .00020000  00000-0  20000-3 0  9002
2 25544  51.6382 157.5777 0002396 120.7477 239.3923 15.75924388 31168
_END
		@date = Time.gm(2007, 10, 26, 7, 10, 40)
	end

	def test_decode_tle
		assert_equal(25544, @tle.satellite_number)
		assert_equal('U', @tle.classification)
		assert_equal(2007, @tle.epoch_year)
		assert_in_delta(297.39694683, @tle.epoch, 1e-8)
		assert_in_delta(51.6382.to_rad, @tle.inclination, 1e-4.to_rad)
		assert_in_delta(157.5777.to_rad, @tle.right_ascention, 1e-4.to_rad)
		assert_in_delta(0.0002396, @tle.eccentricity, 1e-7)
		assert_in_delta(120.7477.to_rad, @tle.argument_of_perigee, 1e-4.to_rad)
		assert_in_delta(239.3923.to_rad, @tle.mean_anomaly, 1e-4.to_rad)
		assert_in_delta(15.75924388, @tle.mean_motion, 1e-8)
	end

	def test_position
		@position = Satellite.new(@tle).position(@date)
		assert_in_delta(10.332345995772712.to_rad, @position.lon, 1e-4)
		assert_in_delta(-6.689590384858868.to_rad, @position.lat, 1e-4)
		assert_in_delta(344.04745938752063*1000, @position.alt, 1e-1)
	end

	def test_apparent_position
		mko = BesselEarth.geodetic('-155 28'.dms_to_rad, '+19 50'.dms_to_rad, 4205)
		hilo = BesselEarth.geodetic(-155.09.to_rad, 19.73.to_rad, 14)
		az, el, d = mko.apparent_from(hilo)
		assert_in_delta(70, az.to_deg, 20)
		assert_in_delta(10, el.to_deg, 10)
		assert_in_delta(50000, d, 10000)	# target taken from Google map by eyes
	end

	def no_test_iss_apparent_position
		# http://www.heavens-above.com/
		iss = Satellite.new(<<_ISS).position(Time.gm(2007, 11, 1, 15, 25, 49))
1 25544U 98067A   07300.90939573  .00014099  00000-0  92667-4 0  2412
2 25544 051.6371 139.4786 0002573 139.5015 001.9355 15.76020103511717
_ISS
		hilo = BesselEarth.geodetic(-155.09.to_rad, 19.73.to_rad, 14)
		az, el, d = iss.apparent_from(hilo)
		assert_in_delta(124, az.to_deg, 1, 'Sorry, this is a pending issue.')
		assert_in_delta(10, el.to_deg, 1)
		assert_in_delta(1265000, d, 1000)
	end

	def no_test_hst_apparent_position
		# http://www.heavens-above.com/
		hst = Satellite.new(<<_HST).position(Time.gm(2007, 10, 29, 14, 22, 46))
1 20580U 90037B   07301.58787426  .00000346  00000-0  13976-4 0  9928
2 20580 028.4678 040.1908 0003457 083.2577 276.8406 15.00295003760017
_HST
		hilo = BesselEarth.geodetic(-155.09.to_rad, 19.73.to_rad, 14)
		az, el, d = hst.apparent_from(hilo)
		assert_in_delta(35, az.to_deg, 1, 'Sorry, this is a pending issue.')
		assert_in_delta(23, el.to_deg, 1)
		assert_in_delta(1210000, d, 1000)
	end

	def no_test_geosynchronous_satellite 
		# http://www.tle.info/data/intelsat.txt
		intelsat707 = Satellite.new(<<_END).position(Time.gm(2007, 11, 6, 9, 42, 22))
1 23816U 96015A   07309.82775863 -.00000280  00000-0  10000-3 0  6303
2 23816 000.0048 295.5374 0003978 299.5631 054.5788 01.00270980 42663
_END
		# http://www.telesatellite.com/satellites/azimut_elevation.asp
		assert_in_delta(-1, intelsat707.lon.to_deg, 1, 'Sorry, this is a pending issue')
		paris = BesselEarth.geodetic(2.to_rad, 49.to_rad, 0)
		az, el, d = intelsat707.apparent_from(paris)
		assert_in_delta(184, az.to_deg, 1)
		assert_in_delta(34, el.to_deg, 1)
	end

	def test_googlesat2_again
		iss = Satellite.new(<<_ISS).position(Time.gm(2007, 10, 30, 9, 16, 25))
1 25544U 98067A   07302.53323267  .00014099  00000-0  92667-4 0  2410
2 25544 051.6340 131.1212 0002403 145.4878 214.6443 15.75905349511715
_ISS
		assert_in_delta(121.6, iss.lon.to_deg, 2)
		assert_in_delta(15.4, iss.lat.to_deg, 2)
		assert_in_delta(342720, iss.alt, 1)
	end
end
