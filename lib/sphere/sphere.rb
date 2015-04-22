#
# az el.rb: Ra/Dec and Az/El conversions
#
# $Id: azel.rb,v 1.32 2007/03/01 05:25:55 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

module Sphere
  include Math

  # azimuth (only plus) in radian from elevation and declination
  def self::az_at_el( lat, el, dec )
    denom = -Math::cos( lat )*Math::cos( el )
    return nil if 0.0 == denom
    f = ( Math::sin( dec ) - Math::sin( lat )*Math::sin( el ) ) / denom
    return nil if 1 < f.abs
    Math::acos( f )
    # from "Tentai-no Keisan Kyoushitsu" 1998, Saida, Hiroshi, Chijin-shokan
  end

  # number of centuries from AD1900 Jan 1 12:00 UT
  def self::c1900( time )
    ( fjd( time ) - 2415021.0 )/36525.0
  end

  # distance on the sphere between two points in radias
  # from ( az1, el1, az2, el2 )
  # or two instances of same coordinate system
  def self::distance( *args )
    if 4 == args.size then
      az1, el1, az2, el2 = *args
    elsif 2 == args.size then
      raise ArgumentError, 'instances of different class' if args[0].class != args[1].class
      az1, el1 = args[0].long_and_lat
      az2, el2 = args[1].long_and_lat
    else
      raise ArgumentError, "wrong number of arguments(#{args.size} for 2 or 4)"
    end

    del1 = Math::PI/2 - el1
    del2 = Math::PI/2 - el2
    daz = az2 - az1
    Math::acos(\
               Math::cos( del1 )*Math::cos( del2 ) + \
               Math::sin( del1 )*Math::sin( del2 )*Math::cos( daz ) )
    # from "Tentai-no Keisan Kyoushitsu" 1998, Saida, Hiroshi, Chijin-shokan
  end

  # returns radians converted from DD:MM:SS,
  # throws a RuntimeError when +str+ can not be converted.
  def self::dms_to_rad( str )
    a = str.gsub( /s/, '.' ).scan( /([\+\-])?([\d\.]+)/ ).flatten.compact
    case a[0]
    when '-'
      sign = -1
      a.shift
    when '+'
      sign = +1
      a.shift
    else
      sign = 1
    end
    if a.size < 1 then
      raise RuntimeError, "`#{str}' can not be parsed"
    end
    num = ( a[0]?( a[0].to_f ):0.0 )+ \
      ( a[1]?( a[1].to_f ):0.0 )/60.0+ \
      ( a[2]?( a[2].to_f ):0.0 )/3600.0
    sign * num.to_rad
  end

	# Teph - TT (days) for a given Time
  # from Astronomical Almanac 2004
  def self::dteph( time )
    g = 357.53.to_rad + 0.9856003.to_rad*( fjd(time) - 2451545.0 )
    0.001658/3600/15 * Math::sin( g )
  end
	
  # Julian date for Time or Date including time within a day
  def self::fjd( time )
    if time.respond_to?( 'utc' ) then	# Time
      # from Japanese ephemeris 2005
      utc = time.dup.utc
      y = utc.year.to_f
      m = utc.month.to_f
      d = utc.day.to_f
      tmonth = ( (14.0 - m) / 12.0 ).floor
      ( ( -tmonth + y + 4800.0 )*1461.0/4.0 ).floor \
        + ( ( tmonth*12 + m - 2 )*367.0/12.0 ).floor \
        - ( ( ( -tmonth + y + 4900.0 )/100 ).floor*3.0/4.0 ).floor \
        + d \
        + utc.hour / 24.0 \
        + utc.min / (24.0*60.0) \
        + utc.sec / (24.0*3600.0) - 32075.5
    elsif time.respond_to?( 'ajd' ) then	# Date
      time.ajd.to_f
    else
      raise ArgumentError, "#{time.inspect} cannot be converted to Julian day"
    end
  end

  # Greenwith mean sidereal time in radians for a Time
  # from Astronomical Almanac 2004 for J2000.0
  def self::gmst( time )
    tu = ( jd( time ) - 2451545.0 ) / 36525.0
    ut0h = 24110.54841 \
      + 8640184.812866 * tu \
      + 0.093104 * tu**2 \
      + 0.0000062 * tu**3	# seconds
    sti = ( time.to_f % (3600*24) ) * 1.0027379094	# seconds
    # equivalent mean sidereal time interval
    ( ( ( ut0h + sti ) / 3600.0 / 24.0 ) % 1.0 ) * 2.0 * Math::PI
  end

  # hour angle (only plus) in radian from elevation and declination
  def self::ha_at_el( lat, el, dec )
    denom = Math::cos( lat )*Math::cos( dec )
    return nil if 0.0 == denom
    f = ( Math::sin( el ) - Math::sin( lat )*Math::sin( dec ) ) / denom
    return nil if 1 < f.abs
    Math::acos( f )
    # from "Tentai-no Keisan Kyoushitsu" 1998, Saida, Hiroshi, Chijin-shokan
  end

	# right accension in radians
  # from hour angle and local sidereal time (rad)
  def self::ha_to_ra( ha, lst )
    ( ha + lst ) % ( 2.0 * Math::PI )
  end
	
	  # returns radians converted from HH:MM:SS
  def self::hms_to_rad( str )
    Sphere::dms_to_rad( str ) * 15.0
  end
	
  # Julian date for Time or Date at UT 0h
  def self::jd( time )
    if time.respond_to?( 'utc' ) then	# Time
      # from Japanese ephemeris 2005
      y = time.utc.year.to_f
      m = time.utc.month.to_f
      d = time.utc.day.to_f
      tmonth = ( (14.0 - m) / 12.0 ).floor
      ( ( -tmonth + y + 4800.0 )*1461.0/4.0 ).floor \
        + ( ( tmonth*12 + m - 2 )*367.0/12.0 ).floor \
        - ( ( ( -tmonth + y + 4900.0 )/100 ).floor*3.0/4.0 ).floor \
        + d - 32075.5
    elsif time.respond_to?( 'jd' ) then	# Date
      time.jd.to_f - 0.5	# Date::jd is for noon UT
    else
      raise ArgumentError, "#{time.inspect} cannot be converted to Julian day"
    end
  end

  # local sidereal time in radians for Time and longitude (rad)
  def self::lst( time, lon )
    ( gmst( time ) + lon ) % ( 2.0 * Math::PI )
  end

  # UT at a given LST near Time at londitude (rad)
  def self::lst_to_ut( time, lst, lon )
    Time.at( time + ( lst - self::lst( time, lon ) ).to_f * self::sidereal_day * 3600.0 * 12.0 / Math::PI )
  end

  # modified Julian date for Time or Date including time within a day
  def self::mfjd( time )
    fjd( time ) - 2400000.5
  end
	
	# modified Julian date for Time or Date at UT 0h
  def self::mjd( time )
    jd( time ) - 2400000.5
  end

  # obliquity of the ecliptic
  # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
  def self::obliquity( time )
    ( 23.452  - 0.013012 * c1900( time ) ).to_rad
  end

  # position angle (angle from north/zenith to east/right)
  # of point1 seen from point0 in radius
  # from ( az0, el0, az1, el1 )
  # or two instances of same coordiante system
  def self::pa( *args )
    if 4 == args.size then
      ra1, dec1, ra2, dec2 = *args
    elsif 2 == args.size then
      raise ArgumentError, 'instances of different class' if args[0].class != args[1].class
      ra0, dec0 = args[0].long_and_lat
      ra1, dec1 = args[1].long_and_lat
    else
      raise ArgumentError, "wrong number of arguments(#{args.size} for 2 or 4)"
    end

    if dec0.abs == Math::PI/2 then
      ra0, ra1 = ra1, ra0
      dec0, dec1 = dec1, dec0
      swapped = true
    else
      swapped = false
    end

    ddec0 = Math::PI/2 - dec0
    ddec1 = Math::PI/2 - dec1
    dra = ra1 - ra0
    d = Math::acos(\
                   Math::cos( ddec0 )*Math::cos( ddec1 ) + \
                   Math::sin( ddec0 )*Math::sin( ddec1 )*Math::cos( dra ) )	# distance
    raise ArgumentError, "cannot calculate PA of the same poision" if d == 0

    r = Math::atan2(\
                    Math::sin(ddec1)*Math::sin(dra)/Math::sin(d),\
                    (Math::cos(ddec1) - Math::cos(ddec0)*Math::cos(d))/(Math::sin(ddec0)*Math::sin(d))\
                   )

    if swapped	# turn around 180 degrees
      if r < 0
        r += Math::PI
      else
        r -= Math::PI
      end
    end
    r
  end
	
  # returns DD:MM:SS from radians with prec: number of figures in fraction,
  # postfix: [0] for plus and [1] for minus when supplied,
  # and prefix: [0] for plus ad [1] for minus, which are usually sign (+ or -).
  def self::rad_to_dms( rad, prec = 0, postfix = nil, prefix = ['+', '-'] )
    deg = rad*180.0/Math::PI
    if deg >= 0 then
      unless postfix
        sign = prefix[0]
        post = ''
      else
        sign = ''
        post = postfix[0]
      end
    else
      unless postfix
        sign = prefix[1]
        post = ''
      else
        sign = ''
        post = postfix[1]
      end
      deg *= -1
    end
    d, deg = deg.divmod( 1.0 )
    deg *= 60
    if prec >= 0 then
      m, deg = deg.divmod( 1.0 )
      deg *= 60
      s = deg
      format = prec < 1 ? '%02.0f' : "%0#{prec + 3}.#{prec}f"
      sstr = format % s
      if sstr.to_f >= 60 then
        s = 0
        sstr = format % s
        m += 1
      end
      sstr = ':' + sstr
    else
      m = deg
      sstr = ''
    end
    mstr = '%02.0f' % m
    if mstr.to_i >= 60 then
      m = 0
      mstr = '%02.0f' % m
      d += 1
    end
    dstr = '%02.0f' % d
    "#{sign}#{dstr}:#{mstr}#{sstr}#{post}"
  end
	
  # hour angle in radians
  # from right accension (rad) and local sidereal time (rad)
  def self::ra_to_ha( ra, lst )
    ( ra - lst ) % ( 2.0 * Math::PI )
  end
	
  # 1 sidereal day in unit of UT day
  def self::sidereal_day
    0.9972695663
  end

end
