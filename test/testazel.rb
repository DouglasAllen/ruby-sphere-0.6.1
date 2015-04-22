# testazel.rb: testcases for azel.rb
# $Id: testazel.rb,v 1.20 2007/03/01 05:25:55 tomono Exp $
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

require 'date'
require_relative '../lib/sphere/az_el'

class TestSphere < Test::Unit::TestCase
  include Sphere

  def test_jd
    [
      # Japanese ephemeris, 2005
      [ 2432409.5, 1947, 8, 12 ],
      [ 2452000.5, 2001, 4, 1 ],
      [ 2453404.5, 2005, 2, 3 ],
      # Astronomical Almanac, 2004
      [ 2453012.5, 2004, 1, 8 ],
    ].each do |a|
      assert_in_delta( a[0], Sphere::jd( Time.utc( a[1], a[2], a[3], 0, 0, 0 ) ), 1e-5 )
      assert_in_delta( a[0], Sphere::jd( Date.new( a[1], a[2], a[3] ) ), 1e-5 )
      assert_in_delta( a[0] + 0.5, Sphere::fjd( Time.utc( a[1], a[2], a[3], 12, 0, 0 ) ), 1e-5 )
      assert_in_delta( a[0] + 0.5, Sphere::fjd( DateTime.new( a[1], a[2], a[3], 12, 0, 0 ) ), 1e-5 )
    end
    assert_raise( ArgumentError ) do
      Sphere::jd( [ -600, 5, 7, 19, 0, 0, 45.0.to_rad ] )
    end
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha, p. 23-
    assert_in_delta( 2415021.0, Sphere::jd( Date.new( 1900, 1, 1 ) ) + 0.5, 1e-5 )
    assert_in_delta( 0.0, Sphere::jd( Date.new( -4712, 1, 1 ) ) + 0.5, 1e-5 )
    # strange bug
    t = Time.utc( 2004, 7, 8, 9, 10, 11 )
    torig = t.dup
    Sphere::fjd( t )
    assert_equal( t, torig )
  end

  def test_teph
    # Astronomical Almanac, 2004, p.B27
    time = Time.utc( 2004, 7, 8, 0, 0, 0 )
    assert_in_delta( -1.76e-9, Sphere::dteph( time ), 0.1e-9 )
    # TODO: Astronomical Almanac, 2004, p.B27 shows the difference to be
    # -1.1e-9 but a calculator shows 0.001658/3600/15 * sin( 183.28 deg )
    # to be -1.76e-9. Whats happening here?
  end

  def test_gmst
    # Astronomical Almanac, 2004
    assert_in_delta( \
                    ( ( 19.0 + 5.0/60.0 + 8.6280/3600 )*15.0 ).to_rad, \
                    Sphere::gmst( Time.utc( 2004, 7, 8, 0, 0, 0 ) ), \
                    1e-5, 'UT0h' )
    # Astronomical Almanac, 2004
    assert_in_delta( \
                    ( ( 4.0 + 51.0/60.0 + 14.6465/3600 )*15.0 ).to_rad, \
                    Sphere::gmst( Time.utc( 2004, 7, 8, 9, 44, 30 ) ), \
                    1e-5, 'UT9:44:30' )
  end

  def test_lst_to_ut
    # Astronomical Almanac, 2004, p. B7
    assert_in_delta( Time.utc( 2004, 7, 8, 9, 44, 30 ), \
                    Sphere::lst_to_ut( Time.utc( 2004, 7, 8 ), Sphere::hms_to_rad( '23:29:42.3443' ), Sphere::dms_to_rad( '-80:22:55.79' ) ),\
                    1 )
    # "Tentai-no Keisan Kyoushitsu" 1998, Saida, Hiroshi, Chijin-shokan, p. 46
    tzorig = ENV['TZ']
    ENV['TZ'] = 'Japan'
    assert_in_delta( Time.local( 1976, 8, 15, 19, 9, 17 ), \
                    Sphere::lst_to_ut( Time.local( 1976, 8, 15, 19, 0, 0 ), Sphere::hms_to_rad( '16 27 56' ), Sphere::dms_to_rad( '130 43' ) ).localtime, \
                    1 )
    assert_in_delta( Sphere::hms_to_rad( '21 34 7' ), \
                    Sphere::lst( Time.utc( 1976, 8, 15 ), 0 ), \
                    Sphere::hms_to_rad( '0 0 2' ) )
    # TODO: isn't 2 sec too much?
    assert_in_delta( Time.local( 1976, 7, 20, 22, 31, 26 ), \
                    Sphere::lst_to_ut( Time.local( 1976, 7, 20, 22, 0, 0 ), Sphere::hms_to_rad( '18 36 8' ), Sphere::dms_to_rad( '137 43' ) ).localtime, \
                    2 )
    ENV['TZ'] = tzorig
  end

  def test_lst
    # Astronomical Almanac, 2004
    assert_in_delta(
      ( ( 23.0 + 29.0/60.0 + 42.3443/3600 )*15.0 ).to_rad, \
      Sphere::lst( Time.utc( 2004, 7, 8, 9, 44, 30 ), \
                  -( 80.0 + 22.0/60.0 + 55.79/3600 ).to_rad ), \
      1.0/3600.0/24.0 * 2*PI )
    # we have mean sidereal time but the goal value above is an apparent one
    # "Tentai-no Keisan Kyoushitsu" 1998, Saida, Hiroshi, Chijin-shokan, p. 45
    tzorig = ENV['TZ']
    ENV['TZ'] = 'Japan'
    assert_in_delta( Sphere::hms_to_rad( '13:27:01' ), \
                    Sphere::lst( Time.local( 1976, 4, 20, 23, 31, 0 ), Sphere::dms_to_rad( '135 12' ) ), \
                    Sphere::dms_to_rad( '0 1' ) )
    # Fraction of seconds
    lst1 = Sphere::lst(Time.utc(2008, 12, 2, 9, 41, 0), 0.0)
    lst2 = Sphere::lst(Time.utc(2008, 12, 2, 9, 41, 0) + 0.5, 0.0)
    assert_in_delta(0.5, (lst2 - lst1)/Math::PI*12*3600, 0.1)
    ENV['TZ'] = tzorig
  end

  def test_rad_to_dms
    assert_equal( '+00:00:00', Sphere::rad_to_dms( 0, 0 ) )
    assert_equal( '+00:00:00.00', Sphere::rad_to_dms( 0, 2 ) )
    assert_equal( '+90:00:00.0', Sphere::rad_to_dms( Math::PI/2.0, 1 ) )
    assert_equal( '-45:00:00.0', Sphere::rad_to_dms( -Math::PI/4.0, 1 ) )
    assert_equal( '-01:30:00.0', Sphere::rad_to_dms( -2.617993878e-2, 1 ) )
    assert_equal( '+01:30:00.0', Sphere::rad_to_dms( 2.617993878e-2, 1 ) )
    assert_equal( '+01:30', Sphere::rad_to_dms( 2.617993878e-2, -1 ) )
    assert_equal( '-07:55:22.173', -0.13827939685373.rad_to_dms(3) )
    assert_equal( '-07:55:22', -0.13827939685373.rad_to_dms(0) )
    assert_equal( '+07:55:22', 0.13827939685373.rad_to_dms(0) )
  end

  def test_dms_to_rad
    assert_in_delta( -0.13827939685373, Sphere::dms_to_rad( '-07 55 22.173' ), 1e-6 )
    assert_in_delta( -0.13827939685373, Sphere::dms_to_rad( '-07:55:22.173' ), 1e-6 )
    assert_in_delta( -0.13827939685373, Sphere::dms_to_rad( '-07d55m22s173' ), 1e-6 )
    assert_in_delta( -0.138278558126062, Sphere::dms_to_rad( '-07d55m22' ), 1e-6 )
    assert_in_delta( -0.138171899116218, Sphere::dms_to_rad( '-07d55m' ), 1e-6 )
    assert_in_delta( -0.139626340159546, Sphere::dms_to_rad( '-08d' ), 1e-6 )
    assert_in_delta( 0.13827939685373, Sphere::dms_to_rad( '+07 55 22.173' ), 1e-6 )
    assert_in_delta( 0.13827939685373, Sphere::dms_to_rad( '07 55 22.173' ), 1e-6 )
    assert_in_delta( -0.13827939685373, '-07 55 22.173'.dms_to_rad, 1e-6 )
    assert_raise( RuntimeError ) { 'xx'.dms_to_rad }
    assert_raise( RuntimeError ) { '+xx'.dms_to_rad }
    assert_raise( RuntimeError ) { '-xx'.dms_to_rad }
  end

  def test_hms_to_rad
    assert_in_delta( 0.324634135208622, Sphere::hms_to_rad( '01 14 24.0398' ), 1e-6 )
    assert_in_delta( 0.324634135208622, '01 14 24.0398'.hms_to_rad, 1e-6 )
    assert_in_delta( -0.324634135208622, '-01 14 24.0398'.hms_to_rad, 1e-6 )
    assert_in_delta( 0.324634135208622, '+01 14 24.0398'.hms_to_rad, 1e-6 )
  end

  def test_rad_to_hms
    assert_equal( '01:14:24.0398', 0.324634135208622.rad_to_hms(4) )
    assert_equal( '-01:14:24.0398', -0.324634135208622.rad_to_hms(4) )
    assert_equal( '01:14:24.040', 0.324634135208622.rad_to_hms(3) )
    assert_equal( '01:14:24', 0.324634135208622.rad_to_hms(0) )
    assert_equal( '01:14:24', 0.324634135208622.rad_to_hms )
  end

  def test_obliquity
    assert_in_delta( 23.6995.to_rad, Sphere::obliquity( Date.new( 0, 1, 1 ) ), 0.0003.to_rad )
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha, p. 86
  end

  def test_distance
    # aCMa nad bCMa
    # from "Tentai-no Keisan Kyoushitsu" 1998, Saida, Hiroshi, Chijin-shokan
    cal = Sphere::distance( \
                           Sphere::hms_to_rad( '11:02' ), Sphere::dms_to_rad( '+61:53' ), \
                           Sphere::hms_to_rad( '11:00' ), Sphere::dms_to_rad( '+56:31' ) )
    ans = Sphere::dms_to_rad( '05:22' )
    delta = Sphere::dms_to_rad( '00:01' )
    assert_in_delta( ans, cal, delta )
    # zero
    cal = Sphere::distance( \
                           Sphere::hms_to_rad( '11:02' ), Sphere::dms_to_rad( '+61:53' ), \
                           Sphere::hms_to_rad( '11:02' ), Sphere::dms_to_rad( '+61:53' ) )
    assert_in_delta( 0, cal, 1e-6 )
    # poles
    cal = Sphere::distance( Math::PI, -Math::PI/2, Math::PI, Math::PI/2 )
    assert_in_delta( Math::PI, cal, 1e-6 )
    # more use
    assert_raise( ArgumentError ) do
      Sphere::distance( \
                       RaDec.new( Sphere::hms_to_rad( '11:02' ), Sphere::dms_to_rad( '+61:53' ) ),\
                       AzEl.new( Sphere::hms_to_rad( '11:00' ), Sphere::dms_to_rad( '+56:31' ) )\
                      )
    end
    cal = Sphere::distance( \
                           RaDec.new( Sphere::hms_to_rad( '11:02' ), Sphere::dms_to_rad( '+61:53' ) ), \
                           RaDec.new( Sphere::hms_to_rad( '11:00' ), Sphere::dms_to_rad( '+56:31' ) )\
                          )
    ans = Sphere::dms_to_rad( '05:22' )
    delta = Sphere::dms_to_rad( '00:01' )
    assert_in_delta( ans, cal, delta )
    cal = Sphere::distance( \
                           AzEl.new( Sphere::hms_to_rad( '11:02' ), Sphere::dms_to_rad( '+61:53' ) ), \
                           AzEl.new( Sphere::hms_to_rad( '11:00' ), Sphere::dms_to_rad( '+56:31' ) )\
                          )
    ans = Sphere::dms_to_rad( '05:22' )
    delta = Sphere::dms_to_rad( '00:01' )
    assert_in_delta( ans, cal, delta )
  end

  def test_pa
    # "Tentai-no Keisan Kyoushitsu" 1998, Saida, Hiroshi, Chijin-shokan, p. 214
    radec0 = RaDec.new(Sphere::hms_to_rad('11:36:48'), Sphere::dms_to_rad('27:20:00'))
    radec1 = RaDec.new(Sphere::hms_to_rad('11:36:48') + (0.0465*15/3600).to_rad, Sphere::dms_to_rad('27:20:00') - (0.795/3600).to_rad)
    assert_in_delta((1.01/3600).to_rad, Sphere.distance(radec0, radec1), (0.01/3600).to_rad)
    assert_in_delta(142.0, Sphere.pa(radec0, radec1).to_deg, 1.0)

    # "Tentai-no Keisan Kyoushitsu" 1998, Saida, Hiroshi, Chijin-shokan, p. 214
    radec0 = RaDec.new(0, Sphere::dms_to_rad('-16:40:54'))
    radec1 = RaDec.new(0 - (0.537/3600).to_rad, Sphere::dms_to_rad('-16:40:54') - (1.21/3600).to_rad)
    assert_in_delta((1.32/3600).to_rad, Sphere.distance(radec0, radec1), (0.01/3600).to_rad)
    assert_in_delta(204.0-360.0, Sphere.pa(radec0, radec1).to_deg, 1.0)

    # Extreme cases
    # on the celestial equator
    radec0 = RaDec.new(0, 0)
    radec1 = RaDec.new(0.1, 0)
    assert_in_delta(90.0, Sphere.pa(radec0, radec1).to_deg, 1e-6)
    radec1 = RaDec.new(-0.1, 0)
    assert_in_delta(-90.0, Sphere.pa(radec0, radec1).to_deg, 1e-6)
    radec1 = RaDec.new(0, 0.1)
    assert_in_delta(0.0, Sphere.pa(radec0, radec1).to_deg, 1e-6)
    radec1 = RaDec.new(0, -0.1)
    assert_in_delta(180.0, Sphere.pa(radec0, radec1).to_deg.abs, 1e-6)

    # at the north pole
    radec0 = RaDec.new(0, Math::PI/2)
    radec1 = RaDec.new(0, Math::PI/2-0.1)
    assert_in_delta(180.0, Sphere.pa(radec0, radec1).to_deg.abs, 1e-6)
    radec1 = RaDec.new(Math::PI/2, Math::PI/2-0.1)
    assert_in_delta(180.0, Sphere.pa(radec0, radec1).to_deg.abs, 1e-6)
    radec1 = RaDec.new(Math::PI, Math::PI/2-0.1)
    assert_in_delta(180.0, Sphere.pa(radec0, radec1).to_deg.abs, 1e-6)

    # at the south pole
    radec0 = RaDec.new(0, -Math::PI/2)
    radec1 = RaDec.new(0, -Math::PI/2+0.1)
    assert_in_delta(0.0, Sphere.pa(radec0, radec1).to_deg, 1e-6)
    radec1 = RaDec.new(Math::PI/2, -Math::PI/2+0.1)
    assert_in_delta(0.0, Sphere.pa(radec0, radec1).to_deg, 1e-6)
    radec1 = RaDec.new(Math::PI, -Math::PI/2+0.1)
    assert_in_delta(0.0, Sphere.pa(radec0, radec1).to_deg, 1e-6)
  end

  def test_ha_at_el
    assert_in_delta( Sphere::dms_to_rad( '77:15' ), \
                    Sphere::ha_at_el( Sphere::dms_to_rad( '36:23' ), 0, Sphere::dms_to_rad( '-16:41' ) ), \
                    Sphere::dms_to_rad( '00:01' ) )
    # from "Tentai-no Keisan Kyoushitsu" 1998, Saida, Hiroshi, Chijin-shokan
    assert_equal( nil, \
                 Sphere::ha_at_el( Sphere::dms_to_rad( '36:23' ), 0, Sphere::dms_to_rad( '80:00' ) ) \
                )
    assert_equal( nil, \
                 Sphere::ha_at_el( Sphere::dms_to_rad( '36:23' ), 0, Sphere::dms_to_rad( '-80:00' ) ) \
                )
  end

  def test_az_at_el
    assert_in_delta( Sphere::dms_to_rad( '27:33' ), \
                    Sphere::az_at_el( Sphere::dms_to_rad( '26:14' ), 0, Sphere::dms_to_rad( '-52:41' ) ), \
                    Sphere::dms_to_rad( '00:01' ) )
    # from "Tentai-no Keisan Kyoushitsu" 1998, Saida, Hiroshi, Chijin-shokan
    assert_equal( nil, \
                 Sphere::az_at_el( Sphere::dms_to_rad( '36:23' ), 0, Sphere::dms_to_rad( '80:00' ) ) \
                )
    assert_equal( nil, \
                 Sphere::az_at_el( Sphere::dms_to_rad( '36:23' ), 0, Sphere::dms_to_rad( '-80:00' ) ) \
                )
  end

  # class RaDec
  def setup
    # HD94264 from comics-standard-star-work-tomono.xls
    @star = RaDec.new( ( 10.8885 * 15 ).to_rad, 34.215.to_rad )
    @lst = ( 19.0 * 15 ).to_rad
    @lat = 19.5.to_rad
  end

  def test_RaDec_to_azel
    azel = @star.to_azel( @lst, @lat )
    assert_in_delta( (133.80 - 180).to_rad, azel.az, 1e-2 )
    assert_in_delta( -12.80.to_rad, azel.el, 1e-2 )
  end

  def test_RaDec_pa
    assert_in_delta( -55.36.to_rad, @star.pa( @lst, @lat ), 1e-2 )
    # in the south
    assert_in_delta( 0, RaDec.new( 0, 0 ).pa( 0, 30.0.to_rad ), 1e-6 )
    # in the north (lower than north pole)
    assert_in_delta( 0, RaDec.new( 0, 0 ).pa( Math::PI, 30.0.to_rad ), 1e-6 )
    # in the north (higher than north pole)
    assert_in_delta( Math::PI, RaDec.new( 0, 80.0.to_rad ).pa( 0, 30.0.to_rad ), 1e-6 )
  end

  def test_coord
    assert_equal( '10:53:19,+34:12:54',\
                 RaDec.new( ( 10.8885 * 15 ).to_rad, 34.215.to_rad ).coord )
    assert_equal( '10:53:19,+34:12:54',\
                 RaDec.new( ( 10.8885 * 15 ).to_rad, 34.215.to_rad ).to_s )
    assert_equal( '10:53:18.60,+34:12:54.00', \
                 RaDec.new( ( 10.8885 * 15 ).to_rad, 34.215.to_rad ).coord( 2 ) )
    assert_equal( '10:53,+34:13', \
                 RaDec.new( ( 10.8885 * 15 ).to_rad, 34.215.to_rad ).coord( -1 ) )
    assert_equal( '10:00,+56:49', \
                 RaDec.new( Sphere::hms_to_rad( '09:59:52' ), Sphere::dms_to_rad( '+56:48:43' ) ).coord( -1 ) )
    assert_equal( '24:00:00,+90:00:00', \
                 RaDec.new( Sphere::hms_to_rad( '23:59:59.99' ), Sphere::dms_to_rad( '+89:59:59.99' ) ).coord( 0 ) )
  end

  # class AzEl
  def test_AzEl_to_radec
    radec = @star.to_azel( @lst, @lat ).to_radec( @lst, @lat )
    assert_in_delta( @star.ra, radec.ra, 1e-5 )
    assert_in_delta( @star.dec, radec.dec, 1e-5 )
  end

  # position angle of the zenith in radian
  def test_AzEl_pa
    # north
    assert_in_delta( 0, AzEl.new( 0, 0 ).pa( 15.0.to_rad ), 1e-6 )
    assert_in_delta( Math::PI, AzEl.new( 0, 30.0.to_rad ).pa( 15.0.to_rad ), 1e-6 )
    # south
    assert_in_delta( 0, AzEl.new( Math::PI, 0 ).pa( 15.0.to_rad ), 1e-6 )
    # east: looking at east on the equator, zenith should be at -90 deg P.A.
    # with P.A. counted from North to East proejcted on the sky
    assert_in_delta( -Math::PI/2, AzEl.new( -Math::PI/2, 0 ).pa( 0 ), 1e-6 )
    # west
    assert_in_delta( Math::PI/2, AzEl.new( Math::PI/2, 0 ).pa( 0 ), 1e-6 )
  end

  # class LambdaBeta
  def test_RaDec_tolambdabeta
    radec = LambdaBeta.new( 41.952.to_rad, -5.607.to_rad ).to_radec( Date.new( 0, 1, 1 ) )
    assert_in_delta( 41.2229.to_rad, radec.ra, 0.0001.to_rad )
    assert_in_delta( 10.2504.to_rad, radec.dec, 0.0003.to_rad )
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha, p. 86
  end

  def test_LambdaBeta_to_radec
    # no appropriate test found so we just inverse the above
    l = 41.952.to_rad
    b = -5.607.to_rad
    t = Date.new( 0, 1, 1 )
    lb = LambdaBeta.new( l, b ).to_radec( t ).to_lambdabeta( t )
    assert_in_delta( l, lb.lambda, 0.0001.to_rad )
    assert_in_delta( b, lb.beta, 0.0001.to_rad )
  end

end
