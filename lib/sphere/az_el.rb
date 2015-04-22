require_relative 'method_args'
require_relative 'numeric'
require_relative 'sphere'
require_relative 'string'
require_relative 'time'

module Sphere
  # azimuth and elevation
  class AzEl
    include Math
    include MethodArgs

    # as defined in FITS: 0 to the north, plus to the east, in radians
    attr_reader :az

    # in radians
    attr_reader :el

    def initialize( az, el )
      @az = az
      @el = el
    end

    # a RaDec from ( +lst+, +lat+ ) or ( +time+, +lon+, +lat+ )
    def to_radec( *args )
      begin
        lst, lat = MethodArgs::args_to_lst_and_lat( *args )
      rescue ArgumentError
        raise $!
      end
      RaDec.new( Sphere::ha_to_ra( _ha( @az, @el, lat ), lst ), _dec( @az, @el, lat ) )
    end

    # position angle (angle from north to east) of zenith
    def pa( lat )
      RaDec.new( Sphere::ha_to_ra( _ha( @az, @el, lat ), 0 ), _dec( @az, @el, lat ) ).pa( 0, lat )
    end

    # String presentation
    def coord( prec = 0 )
      "#{Sphere::rad_to_dms( @az, prec )},#{Sphere::rad_to_dms( @el, prec )}"
    end
    alias to_s coord

    def to_s
      coord
    end

    # Array of longitude and latitude
    def long_and_lat
      [ @az, @el ]
    end

    private
    # hour angle from azimuth, elevation, and latitude (rad)
    def _ha( az, el, lat )
			  top = -cos( el )*sin( -az )
				bottom = -sin( lat )*cos( el )*cos( -az ) + cos( lat )*sin( el )
      atan2( top, bottom )
    end

    # declination from azimuth, elevation, and latitude (rad)
    def _dec( az, el, lat )
      asin( cos( lat )*cos( el )*cos( -az ) + sin( lat )*sin( el ) )
    end
  end
end