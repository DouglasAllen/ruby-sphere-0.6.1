module Sphere
  # Local pixel coordinate (relative to the reference point) on a point of sky
  class XY
    attr_reader :x, :y
    def initialize( x, y )
      @x = x
      @y = y
    end

    # conversion to a Celestial coordinate
    def to_radec( wcs )
      wcs.xy_to_radec( self )
    end

    def +(other)
      self.class.new( @x + other.x, @y + other.y )
    end

    def -(other)
      self.class.new( @x - other.x, @y - other.y )
    end

    def ==(other)
      self.class == other.class and\
        self.x == other.x and\
        self.y == other.y
    end

    def to_s
      "(#{@x},#{@y})"
    end
  end

end