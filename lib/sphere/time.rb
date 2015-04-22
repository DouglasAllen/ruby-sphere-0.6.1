class Time
  # conversion to LST in radians from longitude (rad)
  def to_lst( lon )
    Sphere::lst( self, lon )
  end
end