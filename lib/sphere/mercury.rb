require_relative 'planet'
require_relative 'sphere'

module Sphere
  class Mercury < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Mercury' end
    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c1900( time )
      c2 = @c*@c
      set_elements( \
                   ( 182.27175 + 149474.07244*@c + 2.01944e-3*c2 ).to_rad%( Math::PI * 2 ),
                   ( 75.89717 + 1.553469*@c + 3.08639e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 47.144736 + 1.18476*@c + 2.23194e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 7.003014 + 1.73833e-3*@c - 1.55555e-5*c2 ).to_rad%( Math::PI * 2 ),
                   0.20561494 + 0.0203e-3*@c - 0.04e-6*c2,
                   0.3870984
                  )
      _update_mpg
    end
    private :_update_pars
  end

end