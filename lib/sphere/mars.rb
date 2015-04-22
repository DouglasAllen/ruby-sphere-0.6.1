require_relative 'planet'
require_relative 'sphere'

module Sphere
  class Mars < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Mars' end
    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c1900( time )
      c2 = @c*@c
      set_elements( \
                   ( 294.26478 + 19141.69625*@c + 3.15028e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 334.21833 + 1.840394*@c + 3.35917e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 48.78670 + 0.776944*@c - 6.02778e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 1.85030 - 6.49028e-4*@c + 2.625e-5*c2 ).to_rad%( Math::PI * 2 ),
                   0.0933088 + 0.095284e-3*@c + 0.122e-6*c2,
                   1.5236781
                  )
      _update_mpg
    end
    private :_update_pars
  end

end