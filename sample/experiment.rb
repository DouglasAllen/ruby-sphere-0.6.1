# http://www.blackbytes.info/2015/12/ruby-time/

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../../lib/sphere', __FILE__)

lon = -88.743 * 180.0 / Math::PI
gmst = Sphere.gmst(Time.now).to_deg / 15.0


sun = Sphere::Sun.new

time = sun.time(Time.now)
lst = time.to_lst(lon)
lst.to_deg / 15.0
Sphere.lst_to_ut( time, lst, lon )

sun.public_methods(false)
sun.name
sun.c2000(time)
p sun.lambdabeta(time).lambda.to_deg
sun.sml(time).to_deg
sun.sax
sun.smpg(time).to_deg
sun.sl(time).to_deg
sun.spr(time).to_deg
sun.ss(time).to_deg
sun.diameter(time).to_deg
sun.xyz(time)
sun.lambdabeta(time)

# LambdaBeta at a given Time
sun.lambdabeta(time).beta.to_deg
# solar mean anomaly (rad)
p ma = sun.sma
# solar eccentricity
p e = sun.sec(time)
# solar eccentric anomaly 
p ea = ma + e * Math.sin(ma) * ( 1.0 + e * Math.cos(ma) )
# x vector
p xv = Math.cos(ea) - e
# y vector
p yv = Math.sqrt(1.0 - e * e) * Math.sin(ea)
# solar true anomaly (rad)
p v = Math.atan2( yv, xv )
p sun.sta(time)
# solar semi-major axis (AU)
p sun.sax
p r = Math.sqrt( xv * xv + yv * yv )
# solar longitude (rad)
p w = sun.spl(time)
p lonsun = v + w
p sun.sl(time)
p xs = r * Math.cos(lonsun)
p ys = r * Math.sin(lonsun)
p sun.xyz(time)

ecl = 23.4393 - 3.563E-7 * time.to_datetime.ajd
p xe = xs
p ye = ys * Math.cos(ecl)
p ze = ys * Math.sin(ecl)
p ra  = Math.atan2( ye, xe )
p dec = Math.atan2( ze, Math.sqrt(xe * xe + ye * ye) )
p ra.to_deg / 15.0
p dec.to_deg

jupiter = Sphere::Jupiter.new
jupiter.name
jupiter.ml(time).to_deg
jupiter.pnl(time).to_deg
jupiter.omg(time).to_deg
jupiter.inc(time).to_deg
jupiter.ec(time)
jupiter.ax(time)
jupiter.mpg(time).to_deg
jupiter.ma(time).to_deg
jupiter.ta(time).to_deg
jupiter.uu(time).to_deg
jupiter.cc(time).to_deg
jupiter.ll(time).to_deg
jupiter.tb(time).to_deg
jupiter.rr(time)
jupiter.xyz(time)
jupiter.lambdabeta(time)
jupiter.lambdabeta(time).lambda.to_deg
jupiter.lambdabeta(time).beta.to_deg

mars = Sphere::Mars.new
mars.name
mars.ml(time).to_deg
mars.pnl(time).to_deg
mars.omg(time).to_deg
mars.inc(time).to_deg
mars.ec(time)
mars.ax(time)
mars.mpg(time).to_deg
mars.ma(time).to_deg
mars.ta(time).to_deg
mars.uu(time).to_deg
mars.cc(time).to_deg
mars.ll(time).to_deg
mars.tb(time).to_deg
mars.rr(time)
mars.xyz(time)
mars.lambdabeta(time)
mars.lambdabeta(time).lambda.to_deg
mars.lambdabeta(time).beta.to_deg

venus = Sphere::Venus.new
venus.name
venus.ml(time).to_deg
venus.pnl(time).to_deg
venus.omg(time).to_deg
venus.inc(time).to_deg
venus.ec(time)
venus.ax(time)
venus.mpg(time).to_deg
venus.ma(time).to_deg
venus.ta(time).to_deg
venus.uu(time).to_deg
venus.cc(time).to_deg
venus.ll(time).to_deg
venus.tb(time).to_deg
venus.rr(time)
venus.xyz(time)
venus.lambdabeta(time)
venus.lambdabeta(time).lambda.to_deg
venus.lambdabeta(time).beta.to_deg
