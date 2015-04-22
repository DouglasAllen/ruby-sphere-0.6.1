require_relative 'sphere'
require_relative 'stellar_body'

module Sphere

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
end