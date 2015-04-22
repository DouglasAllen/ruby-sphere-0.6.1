require_relative 'sphere'
require_relative 'ra_dec'

module Sphere
  # ecliptic coordinate sytem
  class LambdaBeta
    include Math

    # in radians
    attr_reader :lambda, :beta

    def initialize( lambda, beta )
      @lambda = lambda
      @beta = beta
    end

    # correction for perturbations
    def shift!( dlambda, dbeta )
      @lambda = @lambda + dlambda
      @beta = @beta + dbeta
      self
    end

    # RaDec at Time or Date
    def to_radec( time = Time.utc( 2000, 1, 1 ) )
      obl = Sphere::obliquity( time )
      RaDec.new( \
                atan2( -sin( obl )*sin( @beta ) + cos( obl )*cos( @beta )*sin( @lambda ), cos( @beta )*cos( @lambda ) ) % (2*Math::PI),
                asin( cos( obl )*sin( @beta ) + sin( obl )*cos( @beta )*sin( @lambda ) ) \
               )
    end
  end
end