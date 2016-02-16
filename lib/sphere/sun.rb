require_relative 'solarsystem_body'

module Sphere
	class Sun < SolarSystemBody
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha

    def initialize( time = nil )
      _update_pars( time )
    end

    def name; 'Sun' end

    def time( time = nil )
      _update_pars( time )
      @time
    end

    def c1900( time = nil )
      _update_pars( time )
      @c
    end

    def c2000( time = nil )
      _update_pars( time )
      @c
    end

    # solar mean longitude (rad)
    def sml( time = nil )
      _update_pars( time )
      @sml
    end

    # solar longitude of perihelion (rad)
    def spl( time = nil )
      _update_pars( time )
      @spl
    end

    # solar eccentricity
    def sec( time = nil )
      _update_pars( time )
      @sec
    end

    # solar semi-major axis (AU)
    def sax
      @sax
    end

    # solar mean anomaly (rad)
    def sma
      _update_pars( time )
      @sma
    end

    # Sonnenmittelpunktsgleichung
    def smpg( time = nil )
      _update_pars( time )
      @smpg
    end

    # solar longitude (rad)
    def sl( time = nil )
      _update_pars( time )
      @sl
    end

    # solar true anomaly (rad)
    def sta( time = nil )
      _update_pars( time )
      @sta
    end

    # solar raidus vector (AU)
    def spr( time = nil )
      _update_pars( time )
      @spr
    end

    # solar semi-diameter (rad)
    def ss( time = nil )
      _update_pars( time )
      @ss
    end

    # light-disk diameter (rad)
    def diameter( time = nil )
      _update_pars( time )
      @ss * 2
    end

    # rectangular coordinate
    def xyz( time = nil )
      _update_pars( time )
      [ @spr * Math::cos( @sl ), @spr * Math::sin( @sl ), 0.0 ]
    end

    # LambdaBeta at a given Time
    def lambdabeta( time = nil )
      _update_pars( time )
      LambdaBeta.new( @sl, 0.0 )
    end

    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c2000( time )
      @sml = (( 280.6824 + 36000.769325*@c + 7.22222e-4*@c*@c ) % 360.0 ).to_rad 
      @spl = (( 281.2206 + 1.717697*@c + 4.83333e-4*@c*@c + 2.77777e-6*@c*@c*@c ) % 360.0 ).to_rad
      @sec = 0.0167498 - 4.258e-5*@c - 1.37e-7*@c*@c
      @sma = ( @sml - @spl )%( Math::PI*2 )
      @smpg = ( 1.91946*Math::sin(@sma) + 2.00939e-2*Math::sin(@sma*2) - 4.78889e-3*Math::sin(@sma)*@c - 1.44444e-5*Math::sin(@sma)*@c*@c ).to_rad
      @sl = @sml + @smpg
      @sta = @sl - @spl
      @sax = 1.00000129
      @spr = @sax*( 1 - @sec*@sec )/(1 + @sec*Math::cos( @sta ))
      @ss = ( 0.2667/@spr ).to_rad
    end
    private :_update_pars

  end

end

if $0 == __FILE__
  require_relative 'sphere'	
end