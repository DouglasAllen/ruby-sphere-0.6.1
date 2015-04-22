#
# wcs.rb: WCS conversinos
#
# This file is NOT automatically loaded through: require 'sphere'.
# You have to require 'sphere/wcs'.
#
# $Id: wcs.rb,v 1.4 2005/12/07 22:23:33 tomono Exp $
#
# Copyright:: Copyright (C) 2005 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#
require 'matrix'

require_relative 'xy'

module Sphere

  # World coordinate system to be used for XY coordinate.
  # Reference: `FITS no Tebiki Rev. 5' 2004, Astronomical Data Analysis
  # Center, National Astronomical Observatory of Japan,
  # ((<URL:http://www.fukuoka-edu.ac.jp/~kanamitu/fits/fits_t50/>)).
  class WCS
    include Math

    # CDi_j in radian/pixel as a Matrix
    attr_reader :cd

    # projection: 'TAN', 'STG', 'AZP', 'ARC', or '' for a linear projection
    attr_accessor :ctype

    # CRVALi: RaDec, AzEl, etc.
    attr_accessor :reference

    # LONPOLE: longitude in native coordinate
    # of the pole of the stellar coordinate
    attr_accessor :lonpole

    # LATPOLE: latitude in local coordinate
    # of the pole of the stellar coordinate, currently ignored.
    attr_accessor :latpole

    # specify CDi_j as a Matrix, CTYPE as a String,
    # LONPOLE in radian, and reference as a RaDec, etc.
    def initialize( cd = Matrix.unit( 2 ), ctype = '', lonpole = 0.0, reference = nil )
      # default from `FITS no Tebiki Rev. 5' 2004 by NAOJ ATC
      # ((<URL:http://www.fukuoka-edu.ac.jp/~kanamitu/fits/fits_t50/>))
      self.cd = cd
      @ctype = ctype
      @lonpole = lonpole
      @reference = reference
    end

    # sets CDi_j from a Matrix or an Array of Arrays: [[CDxx, CDxy], [CDyx, CDyy]]
    def cd=(matrix_or_array)
      if Matrix == matrix_or_array.class then
        @cd = matrix_or_array
      else
        @cd = Matrix.rows( matrix_or_array )
      end
    end

    # convert a RaDec, etc. to an XY
    def radec_to_xy( src )
      if src.class != @reference.class then
        raise TypeError, "Coordinate systems do not match"
      end
      s = src.long_and_lat
      r = @reference.long_and_lat

      # to native coordinate (phi, theta)
      ddelta = s[0] - r[0]
      phi = atan2(
        -cos(s[1])*sin(ddelta),
        sin(s[1])*cos(r[1]) - cos(s[1])*sin(r[1])*cos(ddelta)
      ) + @lonpole
      theta = asin( sin(s[1])*sin(r[1]) + cos(s[1])*cos(r[1])*cos(ddelta) )

      # project onto a plane
      case @ctype
      when ''
        rtheta = theta
      when 'TAN'
        rtheta = 1.0/tan( theta )
      when 'STG'
        rtheta = 2.0*cos( theta )/(1.0 + sin(theta))
      when 'ARC'
        rtheta = PI/2.0 - theta
      else
        raise NotImplementedError, "ctype #{@ctype.inspect} is not supported"
      end

      # Cartesian coordinate
      x = rtheta * sin( phi )
      y = -rtheta * cos( phi )

      # CDij
      XY.new( *(( @cd.inv * Vector[ x, y ] ).to_a) )
    end

    # convert an XY to a RaDec, etc.
    def xy_to_radec( src )
      # Cartesian coordinate
      #$stderr.puts "\np1: #{src.x} pix"
      #$stderr.puts "p2: #{src.y} pix"
      x, y = *((@cd*Vector[ src.x, src.y ]).to_a)
      #$stderr.puts "x: #{x.to_deg} deg"
      #$stderr.puts "y: #{y.to_deg} deg"

      # projected on a plane
      begin
        phi = atan2( -y, x )
      rescue Math::DomainError
        phi = 0.0
      end
      rtheta = sqrt( x**2 + y**2 )  

      # to nateive coordinate (phi, theta)
      case @ctype
      when ''
        theta = rtheta
      when 'TAN'
        theta = atan( 1.0/rtheta )
      when 'ARC'
        theta = PI/2.0 - rtheta
      else
        raise NotImplementedError, "ctype #{@ctype.inspect} is not supported"
      end
      #$stderr.puts "phi:  #{phi.to_deg} deg"
      #$stderr.puts "theta:#{theta.to_deg} deg"

      # to Celestial cooridnate
      r = @reference.long_and_lat
      dphi = phi - @lonpole
      lat = asin( sin(theta)*sin(r[1]) + cos(theta)*cos(dphi)*cos(r[1]) )
      lon = atan2(
        -cos(theta)*sin(dphi),
        sin(theta)*cos(r[1]) - cos(theta)*cos(dphi)*sin(r[1])
      ) + r[0]

      # output
      @reference.class.new( lon, lat )
    end

    def ==(other)	# :nodoc:
      self.class == other.class and\
      self.cd == other.cd and\
      self.ctype == other.ctype and\
      self.reference == other.reference and\
      self.lonpole == other.lonpole and\
      self.latpole == other.latpole
    end

  end
end
