#
# star.rb: a class of stars and plantes (hopefully in the future)
#
# $Id: star.rb,v 1.19 2006/07/03 04:52:09 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

require 'sphere/azel'

module Sphere
  class StellarBody
    attr_reader :name

    AZFORMAT = '%+9.4f'
    ELFORMAT = '%7.4f'
    SECFORMAT = '%6.4f'

    # RaDec at a given Time
    def radec( time )
      raise NotImplementedError
    end

    # Time of meridian transit on a given date
    def meridian_transit( date, lon )
      raise NotImplementedError
    end

    # Transit time of rising at a given el (rad)
    def rise_at( el, date, lon, lat )
      raise NotImplementedError
    end

    # Transit time of setting at a given el (rad)
    def set_at( el, date, lon, lat )
      raise NotImplementedError
    end

    # remarks for genric data to be stored in data files
    def cols_comment( timezone = 'local' )
      "#date-time(#{timezone}) LST Az(deg) El(deg) sec(z)"
    end

    # generic data line at a Time, lon(rad), lat(rad) to be stored in data files
    def cols( time, lon, lat )
      lst = time.to_lst( lon )
      azel = radec( time ).to_azel( lst, lat )
      timestr = time.localtime.strftime( col_time_format )
      lststr = Time.at( ( lst*12.0*3600.0/Math::PI ).round ).utc.strftime( '%H:%M:%S' )
      "#{timestr} #{lststr} #{AZFORMAT % azel.az.to_deg} #{ELFORMAT % azel.el.to_deg} #{SECFORMAT % (1.0 / Math::sin( Math::PI - azel.el ))}"
    end

    # column number for time
    def col_time; 1; end

    # time format
    def col_time_format; @timeformat || '%Y/%m/%d-%H:%M:%S'; end
    def col_time_format=(format); @timeformat = format; end

    # column number for LST
    def col_lst; 2; end

    # colmn number for Az(deg)
    def col_az; 3; end

    # colmn number for El(deg)
    def col_el; 4; end

    # colmn number for sec(z)
    def col_secz; 5; end

  end

  class Star < StellarBody
    attr_reader :ra, :dec, :name, :type

    # ra and dec in radian
    def initialize( ra, dec, name = nil, type = nil )
      @ra = ra
      @dec = dec
      @name = name
      @type = type
    end

    # RaDec
    def radec( time = nil )
      RaDec.new( @ra, @dec )
    end

    # Time of meridian transit on a given date
    def meridian_transit( date, lon )
      Sphere::lst_to_ut( date, @ra, lon )
    end

    # Transit time of rising at a given el (rad)
    def rise_at( el, date, lon, lat )
      dha = Sphere::ha_at_el( lat, el, @dec )
      if dha then
        Sphere::lst_to_ut( date, @ra - dha, lon )
      else
        nil
      end
    end

    # Transit time of setting at a given el (rad)
    def set_at( el, date, lon, lat )
      dha = Sphere::ha_at_el( lat, el, @dec )
      if dha then
        Sphere::lst_to_ut( date, @ra + dha, lon )
      else
        nil
      end
    end

  end

  class SolarSystemBody < StellarBody
    attr_reader :time

    # remarks for genric data to be stored in data files
    def cols_comment( time )
      super + " RA(hh:mm:ss.s) Dec(dd:mm:ss)"
    end

    # generic data line at a Time, lon(rad), lat(rad) to be stored in data files
    def cols( time, lon, lat )
      radec = radec( time )
      super + " #{Sphere::rad_to_dms( radec.ra / 15.0, 1 )} #{Sphere::rad_to_dms( radec.dec, 0 )}"
    end

    # RaDec at a given Time
    def radec( time = nil )
      lb = lambdabeta( time )
      lb.to_radec( @time )
    end

    # set time
    def time=( time )
      _update_pars( time )
    end

    # Time of meridian transit on a given date
    def meridian_transit( date, lon )
      time = date
      begin
        prev_time = time
        time = Sphere::lst_to_ut( prev_time, radec( prev_time ).ra, lon )
      end while( ( time - prev_time ).abs > 1 )
      time
    end

    # Transit time of rising at a given el (rad)
    def rise_at( el, date, lon, lat )
      time = date
      begin
        prev_time = time
        radec = radec( prev_time )
        dha = Sphere::ha_at_el( lat, el, radec.dec )
        if dha then
          time = Sphere::lst_to_ut( date, radec.ra - dha, lon )
        else
          time = nil
        end
      end while( time and ( time - prev_time ).abs > 1 )
      time
    end

    # Transit time of setting at a given el (rad)
    def set_at( el, date, lon, lat )
      time = date
      begin
        prev_time = time
        radec = radec( prev_time )
        dha = Sphere::ha_at_el( lat, el, radec.dec )
        if dha then
          time = Sphere::lst_to_ut( date, radec.ra + dha, lon )
        else
          time = nil
        end
      end while( time and ( time - prev_time ).abs > 1 )
      time
    end
  end

  class Sun < SolarSystemBody
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha

    def initialize( time = nil )
      _update_pars( time )
    end

    def name; 'Sun' end

    def c1900( time = nil )
      _update_pars( time )
      @c
    end

    # solar mean longitude (rad)
    def sml( time = nil )
      _update_pars( time )
      @sml
    end

    # solar longitude of perihelion (rad)
    def spl( time = nil )
      _update_pars( time )
      @spl
    end

    # solar eccentricity
    def sec( time = nil )
      _update_pars( time )
      @sec
    end

    # solar semi-major axis (AU)
    def sax
      @sax
    end

    # solar mean anomaly (rad)
    def sma
      _update_pars( time )
      @sma
    end

    # Sonnenmittelpunktsgleichung
    def smpg( time = nil )
      _update_pars( time )
      @smpg
    end

    # solar longitude (rad)
    def sl( time = nil )
      _update_pars( time )
      @sl
    end

    # solar true anomaly (rad)
    def sta( time = nil )
      _update_pars( time )
      @sta
    end

    # solar raidus vector (AU)
    def spr( time = nil )
      _update_pars( time )
      @spr
    end

    # solar semi-diameter (rad)
    def ss( time = nil )
      _update_pars( time )
      @ss
    end

    # light-disk diameter (rad)
    def diameter( time = nil )
      _update_pars( time )
      @ss * 2
    end

    # rectangular coordinate
    def xyz( time = nil )
      _update_pars( time )
      [ @spr * Math::cos( @sl ), @spr * Math::sin( @sl ), 0.0 ]
    end

    # LambdaBeta at a given Time
    def lambdabeta( time = nil )
      _update_pars( time )
      LambdaBeta.new( @sl, 0.0 )
    end

    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c1900( time )
      @sml = (( 280.6824 + 36000.769325*@c + 7.22222e-4*@c*@c ) % 360.0 ).to_rad 
      @spl = (( 281.2206 + 1.717697*@c + 4.83333e-4*@c*@c + 2.77777e-6*@c*@c*@c ) % 360.0 ).to_rad
      @sec = 0.0167498 - 4.258e-5*@c - 1.37e-7*@c*@c
      @sma = ( @sml - @spl )%( Math::PI*2 )
      @smpg = ( 1.91946*Math::sin(@sma) + 2.00939e-2*Math::sin(@sma*2) - 4.78889e-3*Math::sin(@sma)*@c - 1.44444e-5*Math::sin(@sma)*@c*@c ).to_rad
      @sl = @sml + @smpg
      @sta = @sl - @spl
      @sax = 1.00000129
      @spr = @sax*( 1 - @sec*@sec )/(1 + @sec*Math::cos( @sta ))
      @ss = ( 0.2667/@spr ).to_rad
    end
    private :_update_pars

  end

  class Planet < SolarSystemBody
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    attr_reader :time
    attr_reader :c

    def initialize( time = nil )
      _update_pars( time )
    end

    # mean longitude (rad)
    def ml( time = nil )
      _update_pars( time )
      @ml
    end

    # periherlion mean longitude (rad)
    def pnl( time = nil )
      _update_pars( time )
      @pnl
    end

    # longitude of ascending node (rad)
    def omg( time = nil )
      _update_pars( time )
      @omg
    end

    # inclination (rad)
    def inc( time = nil )
      _update_pars( time )
      @inc
    end

    # eccentricity (rad)
    def ec( time = nil )
      _update_pars( time )
      @ec
    end

    # semi-major axis (AU, earth radius for Moon)
    def ax( time = nil )
      _update_pars( time )
      @ax
    end

    # Mittelpunktsgleichung (euqation of center)
    def mpg( time = nil )
      _update_pars( time )
      @mpg
    end

    # oribital elements: [ ml, pnl, omg, inc, ec, ax ]
    def elements
      [ @ml, @pnl, @omg, @inc, @ec, @ax ]
    end

    # mean anomaly
    def ma( time = nil )
      _update_pars( time )
      ( @ml - @pnl ) % ( Math::PI * 2 )
    end

    # true anomaly
    def ta( time = nil )
      _update_pars( time )
      ( @ml - @pnl + @mpg ) % ( Math::PI * 2 )
    end

    def uu( time = nil )
      _update_pars( time )
      ta + @pnl - @omg
    end

    def cc( time = nil )
      uubuf = uu( time )
      t = ( uubuf * 2.0 / Math::PI ).truncate.to_f
      if t > 0 then
        offset = Math::PI * ( ( t + 1.0 ) / 2.0 ).truncate
      else
        offset = Math::PI * ( ( t - 1.0 ) / 2.0 ).truncate
      end
      Math::atan( Math::cos( @inc )*Math::tan( uubuf ) ) + offset
    end

    def ll( time = nil )
      cc( time ) + @omg
    end

    def tb( time = nil )
      Math::atan( Math::tan( @inc )*Math::sin( cc( time ) ) )
    end

    # oribital radius
    def rr( time = nil )
      _update_pars( time )
      @ax*(1.0 - @ec*@ec)/(1 + @ec*Math::cos( ta ))
    end

    # rectangular coordinate
    def xyz( time = nil )
      _update_pars( time )
      uubuf = uu
      cosuu = Math::cos( uubuf )
      sinuu = Math::sin( uubuf )
      cosomg = Math::cos( @omg )
      sinomg = Math::sin( @omg )
      cosinc = Math::cos( @inc )
      rrbuf = rr
      [ rrbuf*( cosuu*cosomg - sinuu*sinomg*cosinc ),\
        rrbuf*( cosuu*sinomg + sinuu*cosomg*cosinc ),\
        rrbuf*sinuu*Math::sin( @inc ) ]
    end

    # LambdaBeta at a given Time
    def lambdabeta( time = nil )
      _update_pars( time )
      s = Sun.new( @time ).xyz
      p = xyz
      ex, ey, ez = s[0] + p[0], s[1] + p[1], s[2] + p[2]
      LambdaBeta.new( Math::atan2( ey, ex ) % ( Math::PI*2 ), \
                     ez/Math::sqrt( ex*ex + ey*ey + ez*ez ) )
    end

    # sets orbital elements: from [ ml, pnl, omg, inc, ec, ax ]
    def set_elements( *elements )
      @ml, @pnl, @omg, @inc, @ec, @ax = elements
    end
    private :set_elements

    def _update_pars( time )
      raise NotImplementedError
    end
    private :_update_pars

    def _update_mpg
      ma_buf = ma
      ec2 = @ec*@ec
      ec3 = ec2*@ec
      @mpg = ( 2.0*@ec - 0.25*ec3)*Math::sin( ma_buf ) \
        + 1.25*ec2*Math::sin( 2.0*ma_buf ) \
        + 13.0/12.0*ec3*Math::sin( 3.0*ma_buf )
    end
    private :_update_mpg

  end

  class Venus < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Venus' end
    private
    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c1900( time )
      c2 = @c*@c
      set_elements( \
                   ( 344.36936 + 58519.2126*@c + 9.8055e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 130.14057 + 1.37230*@c - 1.6472e-3*c2 ).to_rad%( Math::PI * 2 ),
                   ( 75.7881 + 0.91403*@c + 4.189e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 3.3936 + 1.2522e-3*@c - 4.333e-6*c2 ).to_rad%( Math::PI * 2 ),
                   0.00681636 - 0.5834e-4*@c + 0.126e-6*c2,
                   0.72333015
                  )
      _update_mpg
    end
  end

  class Mercury < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Mercury' end
    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c1900( time )
      c2 = @c*@c
      set_elements( \
                   ( 182.27175 + 149474.07244*@c + 2.01944e-3*c2 ).to_rad%( Math::PI * 2 ),
                   ( 75.89717 + 1.553469*@c + 3.08639e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 47.144736 + 1.18476*@c + 2.23194e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 7.003014 + 1.73833e-3*@c - 1.55555e-5*c2 ).to_rad%( Math::PI * 2 ),
                   0.20561494 + 0.0203e-3*@c - 0.04e-6*c2,
                   0.3870984
                  )
      _update_mpg
    end
    private :_update_pars
  end

  class Mars < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Mars' end
    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c1900( time )
      c2 = @c*@c
      set_elements( \
                   ( 294.26478 + 19141.69625*@c + 3.15028e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 334.21833 + 1.840394*@c + 3.35917e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 48.78670 + 0.776944*@c - 6.02778e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 1.85030 - 6.49028e-4*@c + 2.625e-5*c2 ).to_rad%( Math::PI * 2 ),
                   0.0933088 + 0.095284e-3*@c + 0.122e-6*c2,
                   1.5236781
                  )
      _update_mpg
    end
    private :_update_pars
  end

  class Moon < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Moon' end

    # LambdaBeta at a given Time
    def lambdabeta( time = nil )
      _update_pars( time )
      LambdaBeta.new( ( @omg + cc( time ) ) % ( Math::PI * 2 ), tb( time ) + @h0 )
    end

    # Moon Phase in radian at a given Time
    def phase( time = nil )
      lb = lambdabeta( time )
      dl = lb.lambda - Sun.new( @time ).sl
      p = Math::acos( Math::cos( dl ) * Math::cos( lb.beta ) )
      t = ( dl / Math::PI ).floor
      sign = ( t % 2 == 0 ) ? +1 : -1
      offset = 2.0 * Math::PI * ( ( t.to_f / 2.0 ).ceil )
      offset + p * sign
    end

    # number of centuries from AD1800 Jan 1 12:00 UT
    def self::j1800( time )
      ( Sphere::fjd( time ) - 2378496.0 )/36525.0
    end
    attr_reader :j
    undef c
    # perturbations
    attr_reader :st, :a0, :b0, :c0, :d0, :e0, :h0
    def _update_pars( time )
      alias _cc cc
      return unless time
      return if @time == time
      @time = time
      @j = Sphere::Moon::j1800( time )
      j2 = @j*@j
      j3 = j2*@j
      aa = ( 1.2949 + 413335.4078*@j - 7.2201e-3*j2 - 0.72305e-5*j3 ).to_rad
      bb = ( 111.6209 + 890534.2514*@j + 6.9838e-3*j2 + 0.69778e-5*j3 ).to_rad
      cc = ( 180.40885 + 35999.0552*@j - 0.0001988*j2 ).to_rad
      dd = ( 0.88605 + 377336.3526*@j - 7.0213e-3*j2 - 0.72305e-5*j3 ).to_rad
      ee = ( 111.21205 + 854535.1962*@j + 7.1826e-3*j2 + 0.69778e-5*j3 ).to_rad
      hh = ( 169.1706 + 407332.2103*@j + 5.3354e-3*j2 + 0.53292e-5*j3 ).to_rad
      @a0 = 1.2408.to_rad*Math::sin( aa )
      @b0 = 0.5958.to_rad*Math::sin( bb )
      @c0 = 0.1828.to_rad*Math::sin( cc )
      @d0 = 0.0550.to_rad*Math::sin( dd )
      @e0 = 0.0431.to_rad*Math::sin( ee )
      @st = @a0 + @b0 + @c0 + @d0 + @e0
      @h0 = 0.1453.to_rad*Math::sin( hh )
      set_elements( \
                   ( ( 335.723436 + 481267.887361*@j + 3.38888e-3*j2 + 1.83333e-6*j3 ).to_rad + @st )%( Math::PI * 2 ),
                   ( 225.397325 + 4069.053805*@j - 1.02869e-2*j2 - 1.22222e-5*j3 ).to_rad%( Math::PI * 2 ),
                   ( 33.272936 - 1934.144694*@j + 2.08028e-3*j2 + 2.08333e-6*j3 ).to_rad%( Math::PI * 2 ),
                   5.144433.to_rad,
                   0.05490897,
                   60.2682	# times Earth radius
                  )
      _update_mpg
    end
    private :_update_pars

  end

  # Sunset/rise with defnition at
  # http://aa.usno.navy.mil/faq/docs/RST_defs.html

  # Time of sunrise near Time from ( +time+, +lon+, +lat+ )
  def self::sunrise( *args )
    time, lon, lat = MethodArgs::args_to_time_lon_lat( *args )
    Sun.new.rise_at( -0.8333.to_rad, time, lon, lat )
  end
  # Time of sunset near Time from ( +time+, +lon+, +lat+ )
  def self::sunset( *args )
    time, lon, lat = MethodArgs::args_to_time_lon_lat( *args )
    Sun.new.set_at( -0.8333.to_rad, time, lon, lat )
  end

  # Time of civil twilight begins before sunrise near Time
  # from ( +time+, +lon+, +lat+ )
  def self::civil_twilight_begin( *args )
    time, lon, lat = MethodArgs::args_to_time_lon_lat( *args )
    Sun.new.rise_at( -6.to_rad, time, lon, lat )
  end
  # Time of civil twilight ends after sunset near Time
  # from ( +time+, +lon+, +lat+ )
  def self::civil_twilight_end( *args )
    time, lon, lat = MethodArgs::args_to_time_lon_lat( *args )
    Sun.new.set_at( -6.to_rad, time, lon, lat )
  end

  # Time of nautical twilight begins before sunrise near Time
  # from ( +time+, +lon+, +lat+ )
  def self::nautical_twilight_begin( *args )
    time, lon, lat = MethodArgs::args_to_time_lon_lat( *args )
    Sun.new.rise_at( -12.to_rad, time, lon, lat )
  end
  # Time of nautical twilight ends after sunset near Time
  # from ( +time+, +lon+, +lat+ )
  def self::nautical_twilight_end( *args )
    time, lon, lat = MethodArgs::args_to_time_lon_lat( *args )
    Sun.new.set_at( -12.to_rad, time, lon, lat )
  end

  # Time of astronomical twilight begins before sunrise near Time
  # from ( +time+, +lon+, +lat+ )
  def self::astronomical_twilight_begin( *args )
    time, lon, lat = MethodArgs::args_to_time_lon_lat( *args )
    Sun.new.rise_at( -18.to_rad, time, lon, lat )
  end
  # Time of astronomical twilight ends after sunset near Time
  # from ( +time+, +lon+, +lat+ )
  def self::astronomical_twilight_end( *args )
    time, lon, lat = MethodArgs::args_to_time_lon_lat( *args )
    Sun.new.set_at( -18.to_rad, time, lon, lat )
  end

end
