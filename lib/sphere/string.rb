
class String
  # conversion to radians from DD:MM:SS
  def dms_to_rad
    Sphere::dms_to_rad( self )
  end

  # conversion to radians from HH:MM:SS
  def hms_to_rad
    Sphere::hms_to_rad( self )
  end
end
