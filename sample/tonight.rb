#!/usr/bin/env ruby
#
# tonight.rb: show the sky of tonight
#
# $Id: tonight.rb,v 1.2 2005/06/18 00:52:41 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#
$:.unshift(File.join(File.expand_path(".."), "lib"))
require 'sphere'

require_relative 'constellations'

def plot( device = 'x11', output = nil, tz='UTC', location='NIU' )
  offset = 10
  tzorig = ENV['TZ']
  ENV['TZ'] = tz
  now = Time.now
  #~ firstday = (( now - offset*3600 ).to_a)[3..5].reverse + [24-offset]
	p firstday = (( now).to_a)[3..5].reverse + [0]
  p secondday = (( now - offset*3600 + 24*3600 ).to_a)[3..5].reverse + [offset]
  t1 = Time.local( *firstday )
  t2 = Time.local( *secondday )
  plot = Sphere::GnuPlot.new( 
                             Sphere::Allocation.new( 
                                                    t1, 
                                                    t2, 
                                                    Sphere::Observatory.of( 
                                                                           location 
                                                                          )
                                                    )
                            )
  #plot.stars << Sphere::Sun.new
  #~ plot.stars << Sphere::Moon.new
  #~ plot.stars << Sphere::Venus.new
  #~ plot.stars << Sphere::Mercury.new
  #~ plot.stars << Sphere::Mars.new
  #~ Sphere::Ecliptics.map do |c|
	 p c = Sphere::Ecliptics[0]
	#~ Sphere::Constellations.map do | ab, data |
		#~ #p ab[0], data[0], data[1], data[2]
   p d = Sphere::Constellations[c]
   #~ [ d[1], d[2], c ]
  #~ end.sort.each do |c|
    #~ plot.stars << Sphere::Star.new( c[0], c[1], c[2] )
	plot.stars << Sphere::Star.new(  d[1], d[2], c  )
  #~ end
  plot.plot( device, output )
  ENV['TZ'] = tzorig
  plot
end

plot( 'png', 'tonight.png' ).store_files( 'tonight' )
#puts 'Have a look at tonight/tonight.png'

if __FILE__ == $PROGRAM_NAME
	
	include Sphere
	Ecliptics
	#Constellations.keys.each {| item | p item }
	#plot.instance_variables.each {| item | p item }
	
	plot.stars.each {| item | p item }
	#plot.stars
	#~ p plot.stars[0].name	
  #~ p plot.stars[1].name	
  #~ p plot.stars[2].name	
	#~ p plot.stars[3].name
	
end