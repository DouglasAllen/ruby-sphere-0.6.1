require_relative 'earth'

module Sphere
  class BesselEarth < Earth
    def semimajor_axis	# radius at equator (m)
      6377397.155
    end

    def oblateness
      1.0/299.1528
    end
  end
end