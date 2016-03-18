#
# gnuplot.rb: plot visibility maps
#
# $Id: gnuplot.rb,v 1.19 2006/12/05 22:13:35 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

require_relative 'observatory'
require_relative 'allocation'
require_relative 'az_el'
require_relative 'tempdir'
require 'uri'

module Sphere
  class GnuPlot

    # escapes double quates for gnuplot
    def self::escape( str )
      str.gsub( /"/, '\"' )
    end

    attr_reader :az_center, :az_halfwidth, :directory
    attr_reader :el_min, :el_max, :stars, :stars_visible 

    # settings
    attr_writer :az_center, :az_halfwidth
    attr_writer :el_min, :el_max, :stars 

    # default settings on Az plot
    DEF_MINIMUM_EL = 15.0.to_rad

    # extensions for data files
    EXT_DAT = '.dat'
    AZELFORMAT = '%.4f'
    FILE_UNSAFE = /[^-_.!~*'()a-zA-Z\d;\/?:@&=+$,\[\] "]/n
    # URI::unsafe minus ' ' and '"'

    # interval
    DAT_INTERVAL = 300

    # labels
    INITIAL_TAG_NUM = 1001
    LABEL_INTERVAL = 7200

    def initialize( allocation, binpath = nil )
      @allocation = allocation
      @observatory = allocation.observatory
      @el_min = DEF_MINIMUM_EL
      @el_max = 90.to_rad
      @az_center = nil
      @az_halfwidth = nil
      @stars = []
      @stars_visible = []
      @directory = TempDir.new( File.basename( $0, '.rb' ) )
      @tag_num = INITIAL_TAG_NUM
      @binpath = binpath
      @timeformat = '%Y/%m/%d-%H:%M:%S'
    end

    def create_datafiles
      @stars.each_with_index do |star, istar|
        path = File.join( @directory, data_filename( star ) )
        unless FileTest.exist?( path ) then
          visible = false
          space = false
          star.col_time_format = @timeformat
          File.open( path, 'w' ) do |dst|
            dst.puts( star.cols_comment( @allocation.tz ) )
            # scan through allocated time
            @allocation.each_sec( DAT_INTERVAL ) do |time|
              lst = time.to_lst( @observatory.lon )
              azel = star.radec( time ).to_azel( lst, @observatory.lat )
              unless _azel_visible?( azel, 5.to_rad ) then
                dst.puts unless space
                space = true
              else
                dst.puts( star.cols( time, @observatory.lon, @observatory.lat ) )
                visible = true
                space = false
              end
            end
          end
          @stars_visible[istar] = visible
        end
      end
    end

    def create_plotfile
      File.open( File.join( @directory, plot_filename ), 'w' ) do |f|
        f.print( multiplot )
      end
    end

    def data_filename( star )
      URI.escape( star.name, FILE_UNSAFE ) + EXT_DAT
    end

    def frame_legend
      text = "#{@allocation.from.localtime.strftime( '%Y/%m/%d %H:%M' )} - #{@allocation.to.localtime.strftime( '%m/%d %H:%M %Z' )}\\n#{@allocation.comment ? 'on ' + @allocation.comment + '\\n' : ''}from #{@observatory.comment ? @observatory.comment + ' at ' : ''}#{@observatory.coord}"
      header = %Q|set label #{@tag_num} "#{GnuPlot::escape( text )}" at screen 0.95, screen 0.95 right\n|
      footer = %Q|unset label #{@tag_num}\n|
      @tag_num += 1
      [ header, footer ]
    end

    def multiplot
      @tag_num = INITIAL_TAG_NUM
      lheader, lfooter = frame_legend
      header, footer = multiplot_setups
      body = Array.new
      # time plot
      theader, tfooter = multiplot_timeplot
      body << theader + time_plot + tfooter
      # polar plot
      pheader, pfooter = multiplot_polarplot
      body << pheader + polar_plot + pfooter
      #
      [lheader, header, body, footer, lfooter].join("\n").gsub(/\n\n+/, "\n\n")
    end

    def multiplot_polarplot
      [ "# polar plot\nset origin 0.65,0\nset size 0.35,1\n", '' ]
    end 

    def multiplot_setups
      header =<<'_END'
set size 1, 1
set terminal png size 1200,800
set output 'tonight.png'
#set multiplot
_END
      footer =<<'_END'
#unset multiplot
#unset size
_END
      [ header, footer ]
    end

    def multiplot_timeplot
      [ "# elevation changes\nset origin 0,0\nset size 0.7,1\n", '' ]
    end 

    def plot( terminal = 'x11', outputfile = nil )
      create_datafiles
      create_plotfile
      command = "set terminal push\nset terminal #{terminal}\n"
      command << %Q|set output "#{GnuPlot::escape( outputfile )}"\n| if outputfile
      command << %Q|load "#{plot_filename}"\n|
      command << %Q|set terminal pop\n|
      if 'png' == terminal then
        opt = ' -persist'
      else
        opt = ''
      end
      Dir.chdir( @directory ) do
        open( "| #{@binpath ? @binpath : 'gnuplot'}#{opt}", 'w') do |proc|
          proc.print command
        end
      end
    end

    def plot_filename
      'visibility.plot'
    end

    def polar_plot
      header, footer = polar_plot_setups
      @stars.each do |star|
        set, unset = polar_timestamps( star )
        header += set
        footer = unset + footer
      end
      header + polar_plot_plots + footer
    end

    def polar_plot_plots
      if visible_stars.size > 0 then
        'plot' + \
          visible_stars.map{ |star| %Q| "#{GnuPlot::escape( data_filename( star ) )}" using ($#{star.col_az}+90):(90-$#{star.col_el}) notitle with lines| }.join( ',' ) + \
          "\n"
      else
        "# no star is visible\n"
      end
    end

    def polar_plot_setups
      orig_tag_num = @tag_num
      header =<<"_END"
set polar
set xtics (5, 30, 60, 75)
unset border
set format x ""
set ytics ("15" 75, "30" 60, "60" 30, "85" 5)
set xtics axis nomirror
set ytics axis nomirror
set angles degrees
set size square
set grid polar 30
set xrange [-75:75]
set yrange [-75:75]
set label #{(@tag_num += 1) - 1} "N" at 0,80 center front
set label #{(@tag_num += 1) - 1} "E" at -80,0 right front
set label #{(@tag_num += 1) - 1} "S" at 0,-80 center front
set label #{(@tag_num += 1) - 1} "W" at 80,0 left front
_END
      footer = (orig_tag_num...@tag_num).map{ |tag|
        "unset label #{tag}\n"
      }.join( '' ) + <<'_END'
unset polar
unset xtics
set xtics auto
set border
set format x "% g"
unset ytics
set ytics auto
unset angles
set grid nopolar
set grid xtics ytics
unset grid
set size nosquare
set xrange [*:*]
set yrange [*:*]
_END
      [ header, footer ]
    end  

    def polar_timestamps( star )
      set = ''
      unset = ''
      @allocation.each_sec_on( LABEL_INTERVAL ) do |time|
        azel = star.radec( time ).to_azel( time, @observatory.lon, @observatory.lat )
        next unless _azel_visible?( azel )
        x = ( 90.0 - azel.el.to_deg )*Math::cos( Math::PI/2 + azel.az )
        y = ( 90.0 - azel.el.to_deg )*Math::sin( Math::PI/2 + azel.az )
        set += %Q|set label #{@tag_num} "" at #{x},#{y} point #{timestamp_pt( time )}\n|
        unset += "unset label #{@tag_num}\n"
        @tag_num += 1
      end
      [ set, unset ]
    end

    def store_file( file, ddir )
      spath = File.join( @directory, file )
      if File.exist?( spath ) and File.file?( spath ) 
        src = File.open( spath )
        dpath = File.join( ddir, file )
        File.open( dpath, 'w' ) do |dst|
          dst.print( src.read )
        end
        src.close
      end
    end

    def store_files( ddir )
      FileUtils.mkdir_p( ddir )
      Dir.entries( @directory ).each do |file|
        store_file( file, ddir )
      end
    end

    def time_plot
      header = ''
      footer = ''
      [ time_plot_setups, time_timestamps, time_plot_twilights ].each do |s|
        header +=  s[0]
        footer +=  s[1]
      end
      header + time_plot_plots + footer
    end 

    def time_plot_plots
      if visible_stars.size > 0 then
        #'plot' + visible_stars.map{ |star| %Q| "#{GnuPlot::escape( data_filename( star ) )}" using #{star.col_time}:#{star.col_secz} title "#{GnuPlot::escape( star.name )} #{ star.radec( @allocation.from ).coord( -1 ) }" with lines| }.join( ',' ) + "\n"
        'plot' + visible_stars.map{ |star|
          %Q| "#{GnuPlot::escape( data_filename( star ) )}" using #{star.col_time}:#{star.col_secz} title "#{GnuPlot::escape( star.name )} #{ "%.1fh" % (star.radec( @allocation.from ).ra.to_deg/15) }" with lines| }.join( ',' ) + "\n"

      else
        "# no star is visible\n"
      end
    end

    def time_plot_setups
      els = [15, 30, 45, 60, 75]
      lstfrom = Time.at( ( @allocation.from.to_lst( @observatory.lon )*12.0*3600.0/Math::PI ).round )
      lstto = lstfrom + @allocation.duration / Sphere::sidereal_day
      if @allocation.to - @allocation.from < 2*3600 then  # 2 hours
        timefmt = '%H:%M'
        timeunit = ''
        xtics = 'auto'
        mxtics = '0'
      elsif @allocation.to - @allocation.from < 8*3600 then # 8 hours
        timefmt = '%H'
        timeunit = ' (hours)'
        xtics = '3600'
        mxtics = '6'
      elsif @allocation.to - @allocation.from < 36*3600 then  # 1.5 days
        timefmt = '%H'
        timeunit = ' (hours)'
        xtics = '7200'
        mxtics = '4'
      elsif @allocation.to - @allocation.from < 72*3600 then  # 3 days
        timefmt = '%H'
        timeunit = ' (hours)'
        xtics = '21600'
        mxtics = '4'
      else
        timefmt = '%d'
        timeunit = ' (day)'
        xtics = '86400'
        mxtics = '4'
      end
      header =<<"_END"
set timefmt "#{@stars[0].col_time_format}"
set xdata time
set xrange ["#{@allocation.from.localtime.strftime( @timeformat )}":"#{@allocation.to.localtime.strftime( @timeformat )}"]
set xlabel "#{@allocation.from.localtime.strftime( '%Z' )}#{timeunit}"
set format x "#{timefmt}"
set xtics #{xtics}
set mxtics #{mxtics}
set xtics nomirror
set x2data time
set x2range ["#{lstfrom.utc.strftime( @timeformat )}":"#{lstto.utc.strftime( @timeformat )}"]
set x2label "LST#{timeunit}"
set x2tics #{xtics}
set mx2tics #{mxtics}
set format x2 "#{timefmt}"
set yrange [#{1.0/Math::sin( @el_min )}:#{1.0/Math::sin( @el_max )}]
set ylabel "sec(z)"
set ytics auto
set mytics 5
set ytics nomirror
set y2label "El(deg)"
set y2tics (#{els.map{|el| %Q|"#{el}" #{1.0/Math::sin(el.to_f.to_rad)}|}.join(', ')})
set grid
set key bottom
set key samplen 2
_END
footer =<<'_END'
unset timefmt
unset xdata
set xrange [*:*]
unset xlabel
set mxtics
set yrange [*:*] noreverse
unset ylabel
set format x "% g"
set xtics mirror
unset x2label
unset x2tics
set ytics auto
set mytics
unset y2label
unset y2tics
set ytics mirror
unset grid
set key default
_END
[ header, footer ]
    end

    def time_plot_twilights
      blank = 30
      set = ''
      unset = ''
      [
        [ @allocation.sunsets( blank ), 'sunset' ],
        [ @allocation.sunrises( blank ), 'sunrise' ],
        [ @allocation.nautical_twilight_ends( blank ), 'nautical' ],
        [ @allocation.nautical_twilight_begins( blank ), 'nautical' ],
      ].each do |ts, comment|
        ts.each do |t|
          set += _time_plot_twilight_label( t, @tag_num, comment + t.localtime.strftime( ' %H:%M' ) )
          unset += "unset label #{@tag_num}\n"
          @tag_num += 1
        end
      end
      [ set, unset ]
    end

    def time_timestamps
      set = ''
      unset = ''
      @allocation.each_sec_on( LABEL_INTERVAL ) do |time|
        set += %Q|set label #{@tag_num} "" at "#{time.localtime.strftime( @timeformat )}",graph 0 point #{timestamp_pt( time )}\n|
        unset += "unset label #{@tag_num}\n"
        @tag_num += 1
      end
      [ set, unset ]
    end

    def timestamp_pt( time )
      "pt #{time.localtime.hour + 1}"
    end

    def visible_stars
      r = Array.new
      @stars.each_with_index do |star, i|
        r << star if @stars_visible[i]
      end
      r
    end    

    def _time_plot_twilight_label( time, tagnum, label )
      %Q|set label #{tagnum} "#{label}" at "#{time.localtime.strftime( @timeformat )}",graph 0.98 right rotate nopoint\n|
    end
    private :_time_plot_twilight_label     

    def _azel_visible?( azel, margin = 0 )
      return false if azel.el < ( @el_min - margin ) or azel.el > ( @el_max + margin )
      if @az_center and @az_halfwidth then
        daz = ( azel.az - @az_center ) % ( Math::PI * 2.0 )
        daz -= Math::PI * 2.0 if daz > Math::PI
        return false if daz.abs > ( @az_halfwidth - margin )
      end
      return true
    end

    private :_azel_visible?

  end
end
