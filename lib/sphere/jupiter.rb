require_relative 'planet'

module Sphere
  class Jupiter < Planet
    # table 31.b JM page 215
    def name; 'Jupiter' end
    private
    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c2000( time )
      c2 = @c*@c
      set_elements( \
                   ( 34.351519 + 3034.9056606*@c - 0.00008501*c2 ).to_rad%( Math::PI * 2 ),
                   ( 14.331207 + 0.2155209*@c + 0.00072211*c2 ).to_rad%( Math::PI * 2 ),
                   ( 100.464407 + 0.1767232*@c + 0.000907*c2 ).to_rad%( Math::PI * 2 ),
                   ( 1.303267 - 0.0019877*@c + 0.0000332*c2 ).to_rad%( Math::PI * 2 ),
                   0.04849793 + 0.000163225*@c + 0.0000004714*c2,
                   5.202603209 + 0.0000001913*@c
                  )
      _update_mpg
    end
  end

end