require_relative 'planet'

module Sphere
  class Saturn < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Saturn' end
    private
    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c2000( time )
      c2 = @c*@c
      c3 = c2*@c
      set_elements( \
                   ( 50.077444 + 1223.5110686*@c + 519.08e-6*c2 + 30.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   ( 93.057237 + 1963.7613*@c + 837.53e-6*c2 + 4.928e-9*c3 ).to_rad%( Math::PI * 2 ),
                   ( 113.665503 + 877.088e-3*@c - 121.76e-6*c2 - 2.249e-6*c3 ).to_rad%( Math::PI * 2 ),
                   ( 2.488879 - 3.7362e-3*@c - 15.19e-6*c2 + 87.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                    55.54814e-3 - 346.641e-6*@c + 643.6e-9*c2 + 3.4e-9*c3,
                   9554.909192e-3 - 2139.0e-9*@c + 4.0e-9*c2
                  )
      _update_mpg
    end
  end

end