# testobservatory.rb: testcases for observatory.rb
# $Id: testobservatory.rb,v 1.6 2006/07/19 08:37:25 tomono Exp $
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

class TestObservatory < Test::Unit::TestCase
	include Sphere

	def test_subaru
		t1 = Observatory::of( 'Mauna Kea' )
		assert_in_delta( -2.71364179951023, t1.lon, '00 01'.dms_to_rad )
		assert_in_delta( 0.346072610731696, t1.lat, '00 01'.dms_to_rad )
		assert_equal( 'Mauna Kea', t1.comment )
		t2 = Observatory.new( -2.71364179951023, 0.346072610731696 )
		assert_equal( '155:28:49W,19:49:43N', t2.coord( 0 ) )
	end

	def test_at
		t1 = Observatory::at( 'Mauna Kea' )
		assert_in_delta( -2.71364179951023, t1.lon, '00 01'.dms_to_rad )
		assert_in_delta( 0.346072610731696, t1.lat, '00 01'.dms_to_rad )
		assert_equal( 'Mauna Kea', t1.comment )
	end

	def test_nolocation
		assert_raise( RuntimeError ){ Observatory::of( 'nowhere' ) }
	end

	def test_methodargs
		time = Time.parse( '2006-07-18 22:19:09 HST' )
		obs = Observatory::of( 'Mauna Kea' )
		withcoord = MethodArgs::args_to_lst_and_lat( time, obs.lon, obs.lat )
		withobs = MethodArgs::args_to_lst_and_lat( time, obs )
		assert_equal( withcoord, withobs )
	end

	def test_methodargs_times
		time = Time.parse( '2006-07-18 22:19:09 HST' )
		obs = Observatory::of( 'Mauna Kea' )
		withcoord = Sphere::sunrise( time, obs.lon, obs.lat )
		withobs = Sphere::sunrise( time, obs )
		assert_equal( withcoord, withobs )
	end

	def test_suntimes
		time = Time.parse( '2006-07-18 22:19:09 HST' )
		obs = Observatory::of( 'Mauna Kea' )
		assert_equal(Sphere::sunrise( time, obs ), obs.sunrise( time ))
		assert_equal(Sphere::sunset( time, obs ), obs.sunset( time ))
		assert_equal(Sphere::civil_twilight_begin( time, obs ), obs.civil_twilight_begin( time ))
		assert_equal(Sphere::civil_twilight_end( time, obs ), obs.civil_twilight_end( time ))
		assert_equal(Sphere::nautical_twilight_begin( time, obs ), obs.nautical_twilight_begin( time ))
		assert_equal(Sphere::nautical_twilight_end( time, obs ), obs.nautical_twilight_end( time ))
		assert_equal(Sphere::astronomical_twilight_begin( time, obs ), obs.astronomical_twilight_begin( time ))
		assert_equal(Sphere::astronomical_twilight_end( time, obs ), obs.astronomical_twilight_end( time ))
	end

end
