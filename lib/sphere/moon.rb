require_relative 'lambda_beta'
require_relative 'sphere'

module Sphere
  class Moon < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Moon' end

    # LambdaBeta at a given Time
    def lambdabeta( time = nil )
      _update_pars( time )
      LambdaBeta.new( ( @omg + cc( time ) ) % ( Math::PI * 2 ), tb( time ) + @h0 )
    end

    # Moon Phase in radian at a given Time
    def phase( time = nil )
      lb = lambdabeta( time )
      dl = lb.lambda - Sun.new( @time ).sl
      p = Math::acos( Math::cos( dl ) * Math::cos( lb.beta ) )
      t = ( dl / Math::PI ).floor
      sign = ( t % 2 == 0 ) ? +1 : -1
      offset = 2.0 * Math::PI * ( ( t.to_f / 2.0 ).ceil )
      offset + p * sign
    end

    # number of centuries from AD1800 Jan 1 12:00 UT
    def self::j1800( time )
      ( Sphere::fjd( time ) - 2378496.0 )/36525.0
    end
    attr_reader :j
    undef c
    # perturbations
    attr_reader :st, :a0, :b0, :c0, :d0, :e0, :h0
    def _update_pars( time )
      alias _cc cc
      return unless time
      return if @time == time
      @time = time
      @j = Sphere::Moon::j1800( time )
      j2 = @j*@j
      j3 = j2*@j
      aa = ( 1.2949 + 413335.4078*@j - 7.2201e-3*j2 - 0.72305e-5*j3 ).to_rad
      bb = ( 111.6209 + 890534.2514*@j + 6.9838e-3*j2 + 0.69778e-5*j3 ).to_rad
      cc = ( 180.40885 + 35999.0552*@j - 0.0001988*j2 ).to_rad
      dd = ( 0.88605 + 377336.3526*@j - 7.0213e-3*j2 - 0.72305e-5*j3 ).to_rad
      ee = ( 111.21205 + 854535.1962*@j + 7.1826e-3*j2 + 0.69778e-5*j3 ).to_rad
      hh = ( 169.1706 + 407332.2103*@j + 5.3354e-3*j2 + 0.53292e-5*j3 ).to_rad
      @a0 = 1.2408.to_rad*Math::sin( aa )
      @b0 = 0.5958.to_rad*Math::sin( bb )
      @c0 = 0.1828.to_rad*Math::sin( cc )
      @d0 = 0.0550.to_rad*Math::sin( dd )
      @e0 = 0.0431.to_rad*Math::sin( ee )
      @st = @a0 + @b0 + @c0 + @d0 + @e0
      @h0 = 0.1453.to_rad*Math::sin( hh )
      set_elements( \
                   ( ( 335.723436 + 481267.887361*@j + 3.38888e-3*j2 + 1.83333e-6*j3 ).to_rad + @st )%( Math::PI * 2 ),
                   ( 225.397325 + 4069.053805*@j - 1.02869e-2*j2 - 1.22222e-5*j3 ).to_rad%( Math::PI * 2 ),
                   ( 33.272936 - 1934.144694*@j + 2.08028e-3*j2 + 2.08333e-6*j3 ).to_rad%( Math::PI * 2 ),
                   5.144433.to_rad,
                   0.05490897,
                   60.2682	# times Earth radius
                  )
      _update_mpg
    end
    private :_update_pars

  end

end