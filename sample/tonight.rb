#!/usr/bin/env ruby
#
# tonight.rb: show the sky of tonight
#
# $Id: tonight.rb,v 1.2 2005/06/18 00:52:41 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../../lib/sphere', __FILE__)

require_relative 'constellations'

def plot( device = 'x11', output = nil, tz='UTC', location='NIU' )
  offset = 15
  tzorig = ENV['TZ']
  ENV['TZ'] = tz
  now = Time.now
  #p firstday = (( now - offset*3600 ).to_a)[3..5].reverse + [24-offset]
  p firstday = (( now).to_a)[3..5].reverse + [9]
  #p secondday = (( now - offset*3600 + 0*3600 ).to_a)[3..5].reverse + [offset]
  p secondday = (( now + 1*3600).to_a)[3..5].reverse + [offset]
  t1 = Time.local( *firstday )
  t2 = Time.local( *secondday )
  plot = Sphere::GnuPlot.new( \
	   Sphere::Allocation.new( \
             t1, t2, Sphere::Observatory.of( location ) )
	 )
  
  plot.stars << Sphere::Jupiter.new
  plot.stars << Sphere::Mars.new
  plot.stars << Sphere::Venus.new
  plot.stars << Sphere::Mercury.new
  plot.stars << Sphere::Sun.new
  #plot.stars << Sphere::Moon.new
#
#  plot.stars << Sphere::Star.new('18 30'.hms_to_rad, -10.to_rad, 'Scutum')
#  plot.stars << Sphere::Star.new('18 45'.hms_to_rad, +36.to_rad, 'Lyra')
#  plot.stars << Sphere::Star.new('19 40'.hms_to_rad, +18.to_rad, 'Sagitta')
#  plot.stars << Sphere::Star.new('20 30'.hms_to_rad, +43.to_rad, 'Cygnus')
#  plot.stars << Sphere::Star.new('20 35'.hms_to_rad, +12.to_rad, 'Delphinus')
#  
#  plot.stars << Sphere::Star.new('22  0'.hms_to_rad, +70.to_rad, 'Cepheus')
#  plot.stars << Sphere::Star.new('22 25'.hms_to_rad, +43.to_rad, 'Lacerta')
  
  
  # Sphere::Ecliptics.map do |c|
  #   c = Sphere::Ecliptics[0]
  #   Sphere::Constellations.map do | ab, data |
  #     ab[0], data[0], data[1], data[2]
  #   d = Sphere::Constellations[c]
  #   [ d[1], d[2], c ]
  # end.sort.each do |c|
  #   plot.stars << Sphere::Star.new( c[0], c[1], c[2] )    
  #   plot.stars << Sphere::Star.new(  d[1], d[2], c  )
  # end
  plot.plot( device, output )
  ENV['TZ'] = tzorig
  plot
end

if __FILE__ == $PROGRAM_NAME
	
  #plot
  plot( 'png', 'tonight.png' ).store_files( 'tonight' )
  #puts 'Have a look at tonight/tonight.png'
	
end