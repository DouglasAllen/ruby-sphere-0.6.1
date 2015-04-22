# observatory.rb: a class of observatories
#
# $Id: observatory.rb,v 1.8 2006/07/19 08:37:25 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

require_relative 'az_el'
require_relative 'sphere'

module Sphere
  class Observatory
    attr_reader :lon, :lat, :comment

    # Hash of Arrays of lontitude(rad), latitude(rad), elevation(m), and additional info (or nil)
    Locations = {
      # from Rika Nenpyo (Chronological Scientific Tables 2003), ed. National Astronomical Observatory of Japan
      'La Palma' => [ '-17 43'.dms_to_rad, '28 46'.dms_to_rad, 2426, 'Observatorio del Roque de Los Muchachos' ],
      'Chajnantor' => [ 67.5.to_rad, -23.to_rad, 5000 ],
      'NIU' => ['-88.75'.dms_to_rad, '41.93'.dms_to_rad, 914], 
      'Las Campanas' => [ '-70 42'.dms_to_rad, '-29 1'.dms_to_rad, 2300 ],
      'La Silla' => [ '-70 44'.dms_to_rad, '-29 15'.dms_to_rad, 2400 ],
      'Paranal' => [ '-70 24'.dms_to_rad, '-24 38'.dms_to_rad, 2635 ],
      'Cerro Tololo' => [ '-70 49'.dms_to_rad, '-30 10'.dms_to_rad, 2200 ],
      'Cerro Pachon' => [ '-70 43'.dms_to_rad, '-30 14'.dms_to_rad, 2715 ],
      'Mauna Kea' => [ '-155 28'.dms_to_rad, '+19 50'.dms_to_rad, 4205 ],
      # TODO: more observatories to be listed here
    }

    # lon and lat: location of observatory in radians
    def initialize( lon, lat, comment = nil )
      @lon = lon	# longitude in radian
      @lat = lat	# latitude in radian
      @comment = comment
    end

    # observatory from a name (should be in Locations).
    # Sphere::Observatory::Locations.keys has the list of the names.
    def self::of( name )
      unless Locations.has_key?( name ) then
        raise RuntimeError, %Q|No location with the name "#{name}" found.|
      end
      new( Locations[name][0], Locations[name][1], name )
    end
    class << Observatory
      alias at of
    end

    # location of observatory as a String,
    # prec: number of figrues below seconds
    def coord( prec = -1 )
      "#{Sphere::rad_to_dms( @lon, prec, ['E', 'W'] )},#{Sphere::rad_to_dms( @lat, prec, ['N', 'S'] )}"
    end

    # Time of sunrise near Time
    def sunrise( time )
      Sphere::sunrise( time, self )
    end
    # Time of sunset near Time
    def sunset( time )
      Sphere::sunset( time, self )
    end

    # Time of civil twilight begins before near Time
    def civil_twilight_begin( time )
      Sphere::civil_twilight_begin( time, self )
    end
    # Time of civil twilight ends after sunset near Time
    def civil_twilight_end( time )
      Sphere::civil_twilight_end( time, self )
    end

    # Time of nautical twilight begins before near Time
    def nautical_twilight_begin( time )
      Sphere::nautical_twilight_begin( time, self )
    end
    # Time of nautical twilight ends after sunset near Time
    def nautical_twilight_end( time )
      Sphere::nautical_twilight_end( time, self )
    end

    # Time of astronomical twilight begins before near Time
    def astronomical_twilight_begin( time )
      Sphere::astronomical_twilight_begin( time, self )
    end
    # Time of astronomical twilight ends after sunset near Time
    def astronomical_twilight_end( time )
      Sphere::astronomical_twilight_end( time, self )
    end

  end
end
