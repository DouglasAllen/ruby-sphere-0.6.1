require_relative 'planet'

module Sphere
  class Neptune < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Neptune' end
    private
    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c2000( time )
      c2 = @c*@c
      c3 = c2*@c
      set_elements( \
                   ( 304.348665 + 219.8833092*@c + 308.82e-6*c2 + 18.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   ( 48.120276 + 1.4262957*@c + 384.34e-6*c2 + 20.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   ( 131.784057 + 1.1022039*@c - 259.52e-6*c2 - 637.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   ( 1.769953 - 9.3082e-3*@c - 7.08e-6*c2 + 27.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                    9.45575e-3 + 6.033e-6*@c + 0*c2 - 0.05e-9*c3,
                   30.110386869 - 166.3e-9*@c + 0.69e-9*c2
                  )
      _update_mpg
    end
  end

end