require_relative 'planet'

module Sphere
  class Uranus < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Uranus' end
    private
    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c2000( time )
      c2 = @c*@c
      c3 = c2*@c
      set_elements( \
                   ( 314.055005 + 429.8640561*@c + 303.9e-6*c2 + 26.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   ( 173.005291 + 1.486379*@c + 214.06e-6*c2 + 434.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   ( 74.005957 + 521.1278e-3*@c + 1339.47e-6*c2 + 18.484e-6*c3 ).to_rad%( Math::PI * 2 ),
                   ( 0.773197 + 774.4e-6*@c + 37.49e-6*c2 - 92.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                    46.38122e-3 - 27.293e-6*@c + 78.9e-9*c2 + 0.24e-9*c3,
                   19.218446062 - 37.2e-9*@c + 0.98e-9*c2
                  )
      _update_mpg
    end
  end

end