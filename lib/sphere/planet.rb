require_relative 'solarsystem_body'

module Sphere
  class Planet < SolarSystemBody
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    attr_reader :time
    attr_reader :c

    def initialize( time = nil )
      _update_pars( time )
    end

    # mean longitude (rad)
    def ml( time = nil )
      _update_pars( time )
      @ml
    end

    # periherlion mean longitude (rad)
    def pnl( time = nil )
      _update_pars( time )
      @pnl
    end

    # longitude of ascending node (rad)
    def omg( time = nil )
      _update_pars( time )
      @omg
    end

    # inclination (rad)
    def inc( time = nil )
      _update_pars( time )
      @inc
    end

    # eccentricity (rad)
    def ec( time = nil )
      _update_pars( time )
      @ec
    end

    # semi-major axis (AU, earth radius for Moon)
    def ax( time = nil )
      _update_pars( time )
      @ax
    end

    # Mittelpunktsgleichung (euqation of center)
    def mpg( time = nil )
      _update_pars( time )
      @mpg
    end

    # oribital elements: [ ml, pnl, omg, inc, ec, ax ]
    def elements
      [ @ml, @pnl, @omg, @inc, @ec, @ax ]
    end

    # mean anomaly
    def ma( time = nil )
      _update_pars( time )
      ( @ml - @pnl ) % ( Math::PI * 2 )
    end

    # true anomaly
    def ta( time = nil )
      _update_pars( time )
      ( @ml - @pnl + @mpg ) % ( Math::PI * 2 )
    end

    def uu( time = nil )
      _update_pars( time )
      ta + @pnl - @omg
    end

    def cc( time = nil )
      uubuf = uu( time )
      t = ( uubuf * 2.0 / Math::PI ).truncate.to_f
      if t > 0 then
        offset = Math::PI * ( ( t + 1.0 ) / 2.0 ).truncate
      else
        offset = Math::PI * ( ( t - 1.0 ) / 2.0 ).truncate
      end
      Math::atan( Math::cos( @inc )*Math::tan( uubuf ) ) + offset
    end

    def ll( time = nil )
      cc( time ) + @omg
    end

    def tb( time = nil )
      Math::atan( Math::tan( @inc )*Math::sin( cc( time ) ) )
    end

    # oribital radius
    def rr( time = nil )
      _update_pars( time )
      @ax*(1.0 - @ec*@ec)/(1 + @ec*Math::cos( ta ))
    end

    # rectangular coordinate
    def xyz( time = nil )
      _update_pars( time )
      uubuf = uu
      cosuu = Math::cos( uubuf )
      sinuu = Math::sin( uubuf )
      cosomg = Math::cos( @omg )
      sinomg = Math::sin( @omg )
      cosinc = Math::cos( @inc )
      rrbuf = rr
      [ rrbuf*( cosuu*cosomg - sinuu*sinomg*cosinc ),\
        rrbuf*( cosuu*sinomg + sinuu*cosomg*cosinc ),\
        rrbuf*sinuu*Math::sin( @inc ) ]
    end

    # LambdaBeta at a given Time
    def lambdabeta( time = nil )
      _update_pars( time )
      s = Sun.new( @time ).xyz
      p = xyz
      ex, ey, ez = s[0] + p[0], s[1] + p[1], s[2] + p[2]
      LambdaBeta.new( Math::atan2( ey, ex ) % ( Math::PI*2 ), \
                     ez/Math::sqrt( ex*ex + ey*ey + ez*ez ) )
    end

    # sets orbital elements: from [ ml, pnl, omg, inc, ec, ax ]
    def set_elements( *elements )
      @ml, @pnl, @omg, @inc, @ec, @ax = elements
    end
    private :set_elements

    def _update_pars( time )
      raise NotImplementedError
    end
    private :_update_pars

    def _update_mpg
      ma_buf = ma
      ec2 = @ec*@ec
      ec3 = ec2*@ec
      @mpg = ( 2.0*@ec - 0.25*ec3)*Math::sin( ma_buf ) \
        + 1.25*ec2*Math::sin( 2.0*ma_buf ) \
        + 13.0/12.0*ec3*Math::sin( 3.0*ma_buf )
    end
    private :_update_mpg

  end
end