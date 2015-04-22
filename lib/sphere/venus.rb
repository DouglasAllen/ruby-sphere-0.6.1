require_relative 'planet'

module Sphere
  class Venus < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Venus' end
    private
    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c1900( time )
      c2 = @c*@c
      set_elements( \
                   ( 344.36936 + 58519.2126*@c + 9.8055e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 130.14057 + 1.37230*@c - 1.6472e-3*c2 ).to_rad%( Math::PI * 2 ),
                   ( 75.7881 + 0.91403*@c + 4.189e-4*c2 ).to_rad%( Math::PI * 2 ),
                   ( 3.3936 + 1.2522e-3*@c - 4.333e-6*c2 ).to_rad%( Math::PI * 2 ),
                   0.00681636 - 0.5834e-4*@c + 0.126e-6*c2,
                   0.72333015
                  )
      _update_mpg
    end
  end

end