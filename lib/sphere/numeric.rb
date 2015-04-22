require_relative 'sphere'

class Numeric
  # from degrees to radian
  def to_rad
    self.to_f * Math::PI / 180.0
  end

  # from radian to degrees
  def to_deg
    self.to_f * 180.0 / Math::PI
  end

  # from radian to hh:mm:ss
  def rad_to_hms( prec = 0 )
    Sphere::rad_to_dms( self / 15.0, prec, nil, ['', '-'] )
  end

  # from radian to hh:mm:ss
  def rad_to_dms( prec = 0 )
    Sphere::rad_to_dms( self, prec )
  end
end