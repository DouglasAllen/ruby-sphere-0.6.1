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
      @c = Sphere::c2000( time )
      c2 = @c*@c
      set_elements( \
                   ( 181.979801 + 58517.815676*@c + 0.00000165*c2 ).to_rad%( Math::PI * 2 ),
                   ( 131.563703 + 0.0048746*@c - 0.00138467*c2 ).to_rad%( Math::PI * 2 ),
                   ( 76.67992 - 0.2780134*@c - 0.00014257*c2 ).to_rad%( Math::PI * 2 ),
                   ( 3.394662 - 0.0008568*@c - 0.00003244*c2 ).to_rad%( Math::PI * 2 ),
                   0.00677192 - 0.000047765*@c + 0.00000088*c2,
                   0.72332982
                  )
      _update_mpg
    end
  end

end