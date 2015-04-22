#
# satellite.rb: a class of satellites
#
# Copyright:: Copyright (C) 2007 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

require_relative 'star'

module Sphere
  # Earth as a spheroid
  class Earth
    attr_reader :lon	# radian
    attr_reader :lat	# radian
    attr_reader :alt	# m
    attr_reader :u	# m
    attr_reader :v	# m
    attr_reader :w	# m

    def self::geodetic(lon, lat, alt = 0)
      r = self::new
      r.geodetic = [lon, lat, alt]
      return r
    end

    def self::cartesian(u, v, w)
      r = self::new
      r.cartesian = [u, v, w]
      return r
    end

    def eccentricity2	# square of eccentricity
      1.0-(1.0-oblateness)**2
    end

    def geodetic=(args)	# lon, lat in radian, alt in meter
      unless args.respond_to?(:size) and 3 == args.size
        raise ArgumentError, "wrong number of arguments (expecting 3)"
      end
      @lon, @lat, @alt = *args

      # http://wwwsoc.nii.ac.jp/geod-soc/web-text/part2/2-1/2-1-6.html
      n = semimajor_axis/Math::sqrt(1-eccentricity2*Math::sin(@lat)**2)

      @u = (n + @alt)*Math::cos(@lat)*Math::cos(@lon)
      @v = (n + @alt)*Math::cos(@lat)*Math::sin(@lon)
      @w = (n + @alt - eccentricity2*n)*Math::sin(@lat)

      return self
    end

    def cartesian=(args)	# u, v, w in meter
      unless args.respond_to?(:size) and 3 == args.size
        raise ArgumentError, "wrong number of arguments (expecting 3)"
      end
      @u, @v, @w = *args

      @lon = Math::atan2(v, u)
      uv = Math::sqrt(u*u + v*v)
      t_lat1 = w/uv
      t_lat2 = (semimajor_axis*eccentricity2)/uv
      t_lat = 0.0
      begin
        p_lat = t_lat
        t_lat = t_lat1 + t_lat2*(t_lat/Math::sqrt(1 + (1-eccentricity2)*t_lat**2))
      end while (t_lat - p_lat).abs > 1e-8
      @lat = Math::atan(t_lat)

      @alt = Math::sqrt(1 + t_lat**2) * (w/t_lat - semimajor_axis*(1-eccentricity2)/(Math::sqrt(1+(1-eccentricity2)*t_lat**2)))
      return self
    end

    # azimuth, elevation, distance of self seen from ((+observatory+))
    def apparent_from(observatory)
      du = self.u - observatory.u
      dv = self.v - observatory.v
      dw = self.w - observatory.w
      d = Math::sqrt(du*du + dv*dv + dw*dw)

      # rotation by lon around w
      dx =  du*Math::cos(observatory.lon) + dv*Math::sin(observatory.lon)
      dy = -du*Math::sin(observatory.lon) + dv*Math::cos(observatory.lon)
      dz =  dw

      # rotation by lat around y
      x = dx*Math::sin(observatory.lat) - dz*Math::cos(observatory.lat)
      y = dy
      z = dx*Math::cos(observatory.lat) + dz*Math::sin(observatory.lat)

      az = Math::atan2(-y, -x)
      el = Math::atan2(z, Math::sqrt(x*x + y*y))

      return az, el, d
    end
  end
end
