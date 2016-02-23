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
      c3 = c2*@c
      set_elements( \
                   ( 181.979801 + 58519.2130302*@c + 310.14e-6*c2 + 15.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   ( 131.563703 + 1.4022288*@c - 1.07618e-3*c2 - 5.678e-6*c3 ).to_rad%( Math::PI * 2 ),
                   ( 76.67992 + 901.1206e-3*@c + 406.18e-6*c2 - 93.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   ( 3.394662 - 1.0037*@c - 88.0e-9*c2 - 7.0e-9*c3 ).to_rad%( Math::PI * 2 ),
                   0.00677192 - 47.765e-6*@c + 98.1e-9*c2 + 0.46e-9*c3,
                   0.72332982
                  )
      _update_mpg
    end
  end

end