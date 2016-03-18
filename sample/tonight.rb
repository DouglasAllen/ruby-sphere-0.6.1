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

def plot( device = nil, output = nil, tz='UTC', location='NIU' )
  
  start = 0
  offset = start + 16
  tzorig = ENV['TZ']
  ENV['TZ'] = tz
  now = Time.now
  #p firstday = (( now - offset*3600 ).to_a)[3..5].reverse + [24-offset]
  p firstday = (( now).to_a)[3..5].reverse + [start]
  #p secondday = (( now - offset*3600 + 0*3600 ).to_a)[3..5].reverse + [offset]
  p secondday = (( now + 1*3600).to_a)[3..5].reverse + [offset]
  t1 = Time.local( *firstday )
  t2 = Time.local( *secondday )
  plot = Sphere::GnuPlot.new( \
	   Sphere::Allocation.new( \
             t1, t2, Sphere::Observatory.of( location ) )
	 )
  
  plot.stars << Sphere::Star.new('4 36'.hms_to_rad, +16.533.to_rad, 'Aldebaran')
  plot.stars << Sphere::Star.new('5 15'.hms_to_rad, +-8.183.to_rad, 'Rigel')
  plot.stars << Sphere::Star.new('5 16'.hms_to_rad, +45.998.to_rad, 'Capella')
  plot.stars << Sphere::Star.new('5 56'.hms_to_rad, +7.4.to_rad, 'Betelgeuse')
  plot.stars << Sphere::Star.new('6 45'.hms_to_rad, +-16.733.to_rad, 'Sirius')
  plot.stars << Sphere::Star.new('7 40'.hms_to_rad, +5.166.to_rad, 'Procyon')
  plot.stars << Sphere::Star.new('7 45'.hms_to_rad, +28.0262.to_rad, 'Pollux')  
  
  # plot.stars << Sphere::Star.new(''.hms_to_rad, +.to_rad, '')
  plot.stars << Sphere::Jupiter.new
  # plot.stars << Sphere::Moon.new
  # plot.stars << Sphere::Mars.new
  # plot.stars << Sphere::Saturn.new
  #plot.stars << Sphere::Mercury.new
  #plot.stars << Sphere::Sun.new
  

  


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
	
  # plot
  plot( 'png', 'tonight.png' ).store_files( 'tonight' )
  
  #puts 'Have a look at tonight/tonight.png'
  # set terminal png
  # set output 'tonight.png'
	
end