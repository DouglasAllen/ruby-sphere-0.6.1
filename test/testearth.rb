# testearth.rb: testcases for satellite.rb
#
# Copyright (C) 2007 Daigo Tomono <dtomono at freeshell.org>
#
# Permission is granted for use, copying, modification, distribution, and
# distribution of modified versions of this work under the terms of GPL
# version 2 or later.
#

require 'test/unit'
$:.unshift(File.join(File.expand_path(".."), "lib"))
require 'sphere'

class TestBesselEarth < Test::Unit::TestCase
	include Sphere

	def test_rounttrip
		@geo = BesselEarth.new
		@geo.geodetic = ['-155 28'.dms_to_rad, '+19 50'.dms_to_rad, 4205]
		@car = BesselEarth.new
		@car.cartesian = [@geo.u, @geo.v, @geo.w]
		assert_in_delta(@geo.lon, @car.lon, 1e-4)
		assert_in_delta(@geo.lat, @car.lat, 1e-4)
		assert_in_delta(@geo.alt, @car.alt, 1e-4)
	end

	def test_shortcuts
		@geo = BesselEarth.geodetic('-155 28'.dms_to_rad, '+19 50'.dms_to_rad, 4205)
		@car = BesselEarth.cartesian(@geo.u, @geo.v, @geo.w)
		assert_in_delta(@geo.lon, @car.lon, 1e-4)
		assert_in_delta(@geo.lat, @car.lat, 1e-4)
		assert_in_delta(@geo.alt, @car.alt, 1e-4)
	end

	def test_south
		org = BesselEarth.geodetic('-155 28'.dms_to_rad, '+19 50'.dms_to_rad, 4205)
		s = BesselEarth.geodetic('-155 28'.dms_to_rad, '+18 50'.dms_to_rad, 4205)
		az, el, d = s.apparent_from(org)
		assert_in_delta(180, (az.to_deg) % 360, 1)
		assert_in_delta(0, el.to_deg, 1)
	end

	def test_north
		org = BesselEarth.geodetic('-155 28'.dms_to_rad, '+19 50'.dms_to_rad, 4205)
		n = BesselEarth.geodetic('-155 28'.dms_to_rad, '+20 50'.dms_to_rad, 4205)
		az, el, d = n.apparent_from(org)
		assert_in_delta(0, az.to_deg, 1)
		assert_in_delta(0, el.to_deg, 1)
	end

	def test_west
		org = BesselEarth.geodetic('-155 28'.dms_to_rad, '+19 50'.dms_to_rad, 4205)
		w = BesselEarth.geodetic('-154 28'.dms_to_rad, '+19 50'.dms_to_rad, 4205)
		az, el, d = w.apparent_from(org)
		assert_in_delta(-90, az.to_deg, 1)
		assert_in_delta(0, el.to_deg, 1)
	end

	def test_east
		org = BesselEarth.geodetic('-155 28'.dms_to_rad, '+19 50'.dms_to_rad, 4205)
		w = BesselEarth.geodetic('-156 28'.dms_to_rad, '+19 50'.dms_to_rad, 4205)
		az, el, d = w.apparent_from(org)
		assert_in_delta(90, az.to_deg, 1)
		assert_in_delta(0, el.to_deg, 1)
	end

	def test_above
		org = BesselEarth.geodetic('-155 28'.dms_to_rad, '+19 50'.dms_to_rad, 0)
		u = BesselEarth.geodetic('-155 28'.dms_to_rad, '+19 50'.dms_to_rad, 4205)
		az, el, d = u.apparent_from(org)
		assert_in_delta(90, el.to_deg, 1)
		assert_in_delta(4205, d, 1e-6)
	end

	def test_below
		org = BesselEarth.geodetic('-155 28'.dms_to_rad, '+19 50'.dms_to_rad, 0)
		d = BesselEarth.geodetic('-155 28'.dms_to_rad, '+19 50'.dms_to_rad, -4205)
		az, el, d = d.apparent_from(org)
		assert_in_delta(-90, el.to_deg, 1)
		assert_in_delta(4205, d, 1e-6)
	end

end
