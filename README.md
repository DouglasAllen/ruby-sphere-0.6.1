# ruby-sphere-0.6.1
my reorganized version of the same and some other experiments

'''ruby

  lib = File.expand_path('../../lib', __FILE__)
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
  require File.expand_path('../../lib/sphere', __FILE__)

  sun = Sphere::Sun.new

  p time = sun.time(Time.now)
  p date = time.to_date.to_time
  el = -0.8333.to_rad
  lat = 41.948.to_rad
  lon = -88.743.to_rad
  p sun.rise_at( el, date, lon, lat )
  p sun.meridian_transit( date, lon )
  p sun.set_at( el, date, lon, lat )
'''