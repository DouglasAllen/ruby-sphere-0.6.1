require_relative 'az_el'

module Sphere
  # equatorial coordinate system
  #
  # TODO: epoch
  class RaDec
    include Math
    include MethodArgs

    # in radians
    attr_reader :ra, :dec

    # ra and dec in radians
    def initialize( ra, dec )
      @ra = ra
      @dec = dec
    end

    # an AzEl from ( +lst+, +lat+ ) or ( +time+, +lon+, +lat+ )
    def to_azel( *args )
      begin
        lst, lat = MethodArgs::args_to_lst_and_lat( *args )
      rescue ArgumentError
        raise $!
      end
      ha = Sphere::ra_to_ha( @ra, lst )
      AzEl.new( _azimuth( ha, @dec, lat ), _elevation( ha, @dec, lat ) )
    end

    # position angle (angle from north to east) of zenith
    # from ( +lst+, +lat+ ) or ( +time+, +lon+, +lat+ )
    def pa( *args )
      begin
        lst, lat = MethodArgs::args_to_lst_and_lat( *args )
      rescue ArgumentError
        raise $!
      end
      ha = Sphere::ra_to_ha( @ra, lst )
      _pa( ha, @dec, lat )
    end

    # Array of longitude and latitude
    def long_and_lat
      [ @ra, @dec ]
    end

    # String presentation
    def coord( prec = 0 )
      "#{Sphere::rad_to_dms( @ra / 15.0, prec, [] )},#{Sphere::rad_to_dms( @dec, prec )}"
    end
    alias to_s coord

    # LambdaBeta at Time or Date
    def to_lambdabeta( time = Time.new( 2000, 1, 1 ) )
      obl = Sphere::obliquity( time )
      LambdaBeta.new( \
                     atan2( sin( obl )*sin( @dec ) + cos( obl )*cos( @dec )*sin( @ra ), cos( @dec )*cos( @ra ) ),
                     asin( cos( obl )*sin( @dec ) - sin( obl )*cos( @dec )*sin( @ra ) ) \
                    )
    end

    private

    # azimuth from hour angle, declination, and latitude (rad)
    def _azimuth( ha, dec, lat )
      -atan2( \
             -cos( dec )*sin( ha ), \
             sin( dec )*cos( lat ) - cos( dec )*cos( ha )*sin( lat ) \
            )
    end

    # elevation from hour angle, declination, and latitude (rad)
    def _elevation( ha, dec, lat )
      asin( sin( dec )*sin( lat ) + cos( dec )*cos( ha )*cos( lat ) )
    end

    # position angle
    def _pa( ha, dec, lat )
      atan2( \
            cos( lat )*sin( ha ), \
            cos( dec )*sin( lat ) - sin( dec )*cos( lat )*cos( ha ) \
           )
    end

  end
end