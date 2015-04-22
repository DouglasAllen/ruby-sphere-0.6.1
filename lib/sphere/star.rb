require_relative 'ra_dec'
require_relative 'stellar_body'

module Sphere
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
end