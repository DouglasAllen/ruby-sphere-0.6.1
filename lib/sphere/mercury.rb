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
      c3 = c2*@c
      set_elements( \
                   ( 252.250906 + 149474.0722491*@c + 3.0350e-4*c2 + 18.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   ( 77.456119 + 1.5564776*@c + 295.44e-6*c2 + 9.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   ( 48.330893 + 1.1861883*@c + 175.42e-6*c2 + 215.0e-9).to_rad%( Math::PI * 2 ),
                   ( 7.004986 + 1.8215e-3*@c - 18.1e-6*c2 + 56.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   0.20563175 + 20.407e-6*@c - 28.3e-9*c2 - 0.18e-9*c3,
                   0.387098310
                  )
      _update_mpg
    end
    private :_update_pars
  end

end