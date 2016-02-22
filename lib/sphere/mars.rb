require_relative 'planet'
#require_relative 'sphere'

module Sphere
  class Mars < Planet
    # from "Ko-tenmongaku" 1989, Saito, Kuniji, Kousei-sha
    def name; 'Mars' end
    def _update_pars( time )
      return unless time
      return if @time == time
      @time = time
      @c = Sphere::c2000( time )
      c2 = @c*@c
      set_elements( \
                   ( 355.433 + 19140.2993039*@c + 0.00000262*c2 ).to_rad%( Math::PI * 2 ),
                   ( 336.060234 + 0.4439016*@c - 0.00017313*c2 ).to_rad%( Math::PI * 2 ),
                   ( 49.558093 - 0.295025*@c - 0.00064048*c2 ).to_rad%( Math::PI * 2 ),
                   ( 1.849726 - 0.0081477*@c - 0.00002255*c2 ).to_rad%( Math::PI * 2 ),
                   0.09340065 + 0.000090484*@c + 0.0000000806*c2,
                   1.523679342
                  )
      _update_mpg
    end
    private :_update_pars
  end

end