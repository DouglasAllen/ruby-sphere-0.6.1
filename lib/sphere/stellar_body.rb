#
# star.rb: a class of stars and plantes (hopefully in the future)
#
# $Id: star.rb,v 1.19 2006/07/03 04:52:09 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

require_relative 'az_el'

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
