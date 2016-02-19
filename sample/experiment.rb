# http://www.blackbytes.info/2015/12/ruby-time/

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../../lib/sphere', __FILE__)

sun = Sphere::Sun.new

p time = sun.time(Time.now)
p date = time.to_date.to_time
d = time.to_datetime.ajd - 2451545.0
ecl = 23.4393 - 3.563E-7 * d
el = -0.8333.to_rad
lat = 41.948.to_rad
lon = -88.743.to_rad

# solar mean anomaly (rad)
ma = sun.sma
# solar eccentricity
e = sun.sec(time)
# solar eccentric anomaly 
ea = ma + e * Math.sin(ma) * ( 1.0 + e * Math.cos(ma) )
# x vector
xv = Math.cos(ea) - e
# y vector
yv = Math.sqrt(1.0 - e * e) * Math.sin(ea)
# solar true anomaly (rad)
v = Math.atan2( yv, xv )
r = Math.sqrt( xv * xv + yv * yv )

sun.public_methods(false)
sun.name
sun.c2000(time)
sun.sml(time).to_deg
sun.sta(time)

# solar semi-major axis (AU)
sun.sax
sun.smpg(time).to_deg
# solar longitude of perihelion (rad)
w = sun.spl(time)
lonsun = v + w
xs = r * Math.cos(lonsun)
xs = sun.xyz(time)[0]
ys = r * Math.sin(lonsun)
ys = sun.xyz(time)[1]

sun.spr(time).to_deg
sun.ss(time).to_deg
sun.diameter(time).to_deg
sun.xyz(time)
sun.lambdabeta(time)
# LambdaBeta at a given Time
sun.lambdabeta(time).beta.to_deg
sun.sl(time).to_deg
sun.lambdabeta(time).lambda.to_deg

xe = xs
ye = ys * Math.cos(ecl.to_rad)
ze = ys * Math.sin(ecl.to_rad)

ra  = Math.atan2( ye, xe ).to_deg
ra = sun.radec(time).ra.to_deg / 15.0
dec = Math.atan2( ze, Math.sqrt(xe * xe + ye * ye) ).to_deg
dec = sun.radec(time).dec.to_deg

p sun.rise_at( el, date, lon, lat )
p sun.meridian_transit( date, lon )
p sun.set_at( el, date, lon, lat )

lst = time.to_lst(lon)
Sphere.ra_to_ha( ra, lst ).to_deg
lst.to_deg / 15.0
p ut = Sphere.lst_to_ut( time, lst, lon )
gmst = Sphere.gmst(ut)

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

Sphere::GnuPlot.public_methods(false).sort
Sphere::GnuPlot.public_instance_methods(false).sort

Sphere::SolarSystemBody.public_methods(false).sort
Sphere::SolarSystemBody.public_instance_methods(false).sort