#
# conf.rb: a class to handle configuration files
#
# $Id: conf.rb,v 1.19 2006/08/30 09:24:02 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

require 'time'
require 'sphere/azel'
require 'sphere/observatory'
require 'sphere/allocation'
require 'sphere/star'
require 'sphere/gnuplot'

module Sphere
  #
  # time parser
  #
  class AstroTime
    SYMBOLS = [ :sunrise, :sunset, :twilight, :midnight, :noon, :now ]

    attr_reader :string, :symbol
    def initialize( string, hint = nil )
      @time = nil
      @hint = hint	# :evening or :morning
      @symbol = nil	# listed in SYMBOLS
      @string = string.dup

      # cache
      @observatory = nil
      @near_to = nil

      _get_symbol!
    end

    def time( observatory_or_allocation = nil, near_to = nil )
      if observatory_or_allocation and
        observatory_or_allocation.respond_to?( :from ) and
        observatory_or_allocation.respond_to?( :to ) then
        time_with_allocation( observatory_or_allocation )
      else
        time_with_observatory( observatory_or_allocation, near_to )
      end
    end

    def time_with_observatory( observatory, near_to )
      if (observatory and @observatory != observatory) or (near_to and @near_to != near_to)
        @time = nil
        @observatory = observatory
        @near_to = near_to
      end
      _get_time! unless @time
      @time
    end

    def time_with_allocation( allocation )
      midtime = allocation.from + (allocation.to - allocation.from) / 2
      oncemore = true
      begin
        time = time_with_observatory( allocation.observatory, midtime )
        if not @symbol and oncemore then
          if time < allocation.from then
            midtime += 24 * 3600
            oncemore = false
            redo
          elsif allocation.to < time then
            midtime -= 24 * 3600
            oncemore = false
            redo
          end
        end
      end while false
      @time = time
    end

    def _get_symbol!
      a = SYMBOLS.find_all{|s| @string.gsub!( /\s*#{s}\s*/i, '' )}
        if 1 < a.size
          raise 'only one of sunrise, sunset, or twilight can be specified'
      end
      if 1 == a.size
        @symbol = a[0]
      end
      @string.strip!
    end
    private :_get_symbol!

    def _get_time!
      @time = @near_to
      timestring = @string.dup
      time_added = false

      unless timestring.empty?
        # Convert 26:00:00 into 01:00:00 in the next day
        date_offset = 0
        timestring.sub!(  /((?!\d)-?\d{1,2})(?=:)/ ) do |s|
          date_offset, hour = s.to_i.divmod(24)
          '%02d' % hour
        end
        # Prefix 00:00:00 if no time seems to be given
        unless timestring =~ /(^|\D)\d\d:\d\d(?!\d)/
          timestring = "00:00:00 " + timestring
          time_added = true
        end
        # Let the Ruby library guess the time
        begin
          if Time.parse( '00:00:00', Time.at(0) ) == Time.parse( timestring, Time.at(0) )
            if time_added or Time.parse( '00:00:00', Time.at(1) ) == Time.parse( timesting, Time.at(1) )
              raise "'#{@string}' is not recognized as a time"
            end
          end
          @time = Time.parse( timestring, @near_to || Time.now )
        rescue ArgumentError
          raise "'#{@string}' is not recognized as a time"
        end
        if time_added and Time.at(0) == @time
          raise "'#{@string}' is not recognized as a time"
        end
        @time += date_offset * 24*3600
      end

      if @symbol
        astronomical = true
        case @symbol
        when :now
          @time = Time.now
          astronomical = false
        when :midnight
          @time = Time.local( 0, 0, 0, *@time.to_a[ 3..-1 ] ) + 24*3600
          astronomical = false
        when :noon
          @time = Time.local( 0, 0, 0, *@time.to_a[ 3..-1 ] ) + 12*3600
          astronomical = false
        when :sunrise
          f = @symbol
        when :sunset
          f = @symbol
        when :twilight
          case @hint
          when :evening
            f = :nautical_twilight_end
          when :morning
            f = :nautical_twilight_begin
          else
            raise "A hint (evening/morning) is needed to get time for `#{@symbol}'"
          end
        else
          raise "'#{@symbol}' is not recognized as a time"
        end
        if astronomical
          unless @observatory
            raise "Observatory is needed to get time for `#{@symbol}'"
          end
          @time = Sphere.send( f, @time, @observatory.lon, @observatory.lat )
        end
      end
    end
    private :_get_time!
  end

  #
  # an item to configure
  #
  class ConfItem
    attr_reader :key, :val, :path, :line, :error, :remark

    def initialize( key, val, path = nil, line = nil, remark = nil )
      @key = key
      @val = val
      @path = path
      @line = line
      @error = nil
      @remark = remark
    end

    def self::readline( string, path = nil, line = nil )
      data, remark = string.strip.split( /\s*#\s*/, 2 )
        if data then
          key, val = data.strip.split( /\s+/, 2 )
          if key then
            return new( key, val, path, line, remark )
          end
      end
      nil
    end

    def error=(message)
      @error = message
      @key = nil
      @val = nil
    end

    def error_to_s
      if @path then
        "#{@path}:#{@line}: #{@error}"
      else
        "#{@line}: #{@error}"
      end
    end

    # add omitted keyword
    def unshift_key!( key )
      @val = "#{@key}#{@val ? " #{@val}" : ''}"
      @key = key
      self
    end

    def unishift_key( key )
      self.dup.unshift_key( key )
    end

    # omit the keyword (for a Star)
    def omit_key!
      @key, @val = @val.split( /\s+/, 2 )
      self
    end

    def omit_key
      self.dup.omit_key!
    end


    def to_s
      r = @key.dup
      r << ' ' + @val if @val
      r << "\t# " + @remark if @remark
      r
    end

  end

  #
  # a set of configuration
  #
  class ConfError < StandardError
  end

  class Conf
    # configuration file locations
    FILES  = %w( /etc/ruby-sphere.conf ~/.ruby-sphere.conf ./ruby-sphere.conf )

    # an Array of cnfigurations
    attr_reader :confs

    # a Hash of parsed configurations
    attr_reader :parsed

    # items needs to be configured and defaults and takes one argument
    REQ_ITEMS = {
      'location' => nil,	# allocation
      'start' => nil,	# allocation
      'finish' => nil,	# allocation
      'plotter' => 'GnuPlot',	# plot
    }

    # optional items that takes one argument
    OPT_ITEMS = {
      'lon' => nil,	# allocation
      'lat' => nil,	# allocation
      'device' => 'x11',	# plot
      'output' => nil,	# plot
      'datadir' => nil,	# plot
      'el-min' => nil,	# plot
      'el-max' => nil,	# plot
      'az-center' => nil,	# plot
      'az-halfwidth' => nil,	# plot
    }

    # planets
    PLANETS = %w( Sun Moon Venus Mercury Mars )	# plot

    def initialize( now = nil )
      @confs = Array.new
      @now = now || Time.now.localtime
      @parsed = Hash.new
      @parsed['Star'] = Array.new
      @parsed['AzEl'] = Array.new
      REQ_ITEMS.each_pair do |key, val|
        @parsed[ key ] = val
      end
      OPT_ITEMS.each_pair do |key, val|
        @parsed[ key ] = val
      end
      @fatal = nil
    end

    # read configuration files
    def self::read( additional_paths = [], now = nil )
      r = self::new( now )
      ( FILES + additional_paths ).each do |path|
        abspath = File.expand_path( path )
        if FileTest.exist?( abspath ) and FileTest.readable?( abspath ) then
          File.open( abspath ) { |f| r.readconf( f ) }
        end
      end
      r
    end

    # read configuration items from an IO
    def readconf( io )
      io.each do |line|
        i = ConfItem.readline( line, io.path, io.lineno )
        if i then
          @confs << i
          _parse( i )
        end
      end
      self
    end

    # get the ConfItem values as an Array
    def [](key)
      r = Array.new
      @confs.each do |i|
        r << i if key == i.key
      end
      r
    end

    # add a ConfItem
    def push( item )
      @confs << item
      _parse( item )
    end

    # converts an item into configuration checking for errors
    def _parse( item )
      if REQ_ITEMS.has_key?( item.key ) || OPT_ITEMS.has_key?( item.key ) then
        if 'lon' == item.key  or 'lat' == item.key then
          _parse_as_degrees( item )
        elsif 'start' == item.key or 'finish' == item.key then
          _parse_as_time( item )
        else
          if item.val or 'datadir' == item.key then	# only datadir can be nil
            @parsed[ item.key ] = item.val
          else
            item.error = "'#{item.key}' needs an argument"
          end
        end
      elsif PLANETS.include?( item.key ) then
        @parsed['Star'] << [ item.key ]	# name
        item.unshift_key!( 'Star' )
      elsif 'Star' == item.key then
        _parse_as_star( item, item.val.split( /(?:\s+|,)/, 3 ) )
      elsif 'AzEl' == item.key then
        _parse_as_azel( item, item.val.split( /(?:\s+|,)/, 3 ) )
      else
        a = [ item.key, item.val ].join( ' ' ).split( /(?:\s+|,)/, 3 )
        begin
          a[0].hms_to_rad
          _parse_as_star( item, a )	# first column is RA
          item.unshift_key!( 'Star' )
        rescue RuntimeError	# first column is not RA
          item.error = "'#{item.key}' is not recognized as a configuration keyword"
        end
      end
    end
    private :_parse

    def _parse_as_star( item, data )
      if 3 != data.size then
        item.error = 'error in parsing as a star'
      else
        ra = data[0].hms_to_rad
        dec = data[1].dms_to_rad
        @parsed['Star'] << [ data[2], ra, dec ]
      end
    end
    private :_parse_as_star

    def _parse_as_azel( item, data )
      if 3 != data.size then
        item.error = 'error in parsing as an azel'
      else
        az = data[0].to_f.to_rad
        el = data[1].to_f.to_rad
        @parsed['AzEl'] << [ "Az:#{data[0]} El:#{data[1]} at #{data[2]}", az, el, data[2] ]
      end
    end
    private :_parse_as_star

    def _parse_as_degrees( item )
      rad = nil
      begin
        rad = item.val.dms_to_rad
      rescue RuntimeError
        rad = item.val.to_f.to_rad
      end
      if rad then
        @parsed[ item.key ] = rad
      else
        item.error = "'#{item.val}' is not recognized as a number"
      end
    end
    private :_parse_as_degrees

    def _parse_as_time( item )
      begin
        case item.key
        when 'start'
          hint = :evening
        when 'finish'
          hint = :morning
        else
          hint = nil
        end
        @parsed[ item.key ] = AstroTime.new( item.val, hint )
      rescue RuntimeError
        item.error = $!
      end
    end
    private :_parse_as_time

    # error messages as an Array
    def errors
      r = Array.new
      @confs.each do |conf|
        r << conf.error_to_s if conf.error
      end
      r << @fatal if @fatal
      r
    end

    # error messages as a String
    def errors_to_s
      r = errors.map{ |error| error + "\n" }.join( '' )
      r << @fatal + "\n" if @fatal
      r
    end

    # create an Allocation, returns nil for an error
    def allocate!
      @fatal = false
      # define observatory
      if not @parsed['lon'] or not @parsed['lat'] then
        unless @parsed['location'] then
          @fatal = 'location must be specified'
          raise ConfError, @fatal
        end
        begin
          observatory = Observatory::of( @parsed['location'] )
        rescue RuntimeError
          @fatal = "location '#{@parsed['location']}' not found"
          raise ConfError, @fatal
        end
      else
        unless @parsed['location'] then
          location = "#{self['lon'][-1].val} #{self['lat'][-1].val}"
        else
          location = @parsed['location']
        end
        observatory = Observatory.new( @parsed['lon'], @parsed['lat'], location )
      end
      # define time span
      unless @parsed['start'] then
        @fatal = 'start time must be specified'
        raise ConfError, @fatal
      end
      unless @parsed['finish'] then
        @fatal = 'finish time must be specified'
        raise ConfError, @fatal
      end
      begin
        t1 = @parsed['start'].time( observatory, @now )
        t2 = @parsed['finish'].time( observatory, @now )
      rescue RuntimeError
        raise ConfError, $!
      end
      if t2 <= t1 then
        if @parsed['finish'].symbol then
          t2 = @parsed['finish'].time( observatory, t2 + 24*3600 )
        else
          t1 = @parsed['start'].time( observatory, t1 - 24*3600 )
        end
      end
      @allocation = Sphere::Allocation.new( t1, t2, observatory )
    end

    def azel_to_radec!
      allocate! unless @allocation
      @parsed['Star'] += @parsed['AzEl'].map do |azel|
        name = azel[0]
        time = AstroTime.new( azel[3] ).time( @allocation )
        radec = AzEl.new( azel[1], azel[2] ).to_radec( time, @allocation.observatory )
        [ name, radec.ra, radec.dec ]
      end
    end

    # creates a Plot, returns nil for an error
    def to_plot
      # allocation
      allocate! unless @allocation
      # finalize AzEl reference points
      azel_to_radec!
      # check for Gnuplot
      unless @parsed['plotter'] then
        @fatal = 'plotter must be specified'
        raise ConfError, @fatal
      end
      # plot
      if Sphere.const_defined?( @parsed['plotter'] ) then
        p = Sphere.const_get( @parsed['plotter'] ).send( 'new', @allocation )
      else
        @fatal = "'#{@parsed['plotter']}' is an illegal plotter"
        raise ConfError, @fatal
      end
      # stars
      if @parsed['Star'].empty? then
        @fatal = 'there is no star specified'
        raise ConfError, @fatal
      end
      @parsed['Star'].each do |star|
        if PLANETS.include?( star[0] ) then
          p.stars << Sphere.const_get( star[0] ).send( 'new' )
        else
          p.stars << Sphere::Star.new( star[1], star[2], star[0] )
        end
      end
      p
    end

    # plot according to the configuration
    def plot
      p = to_plot
      [
        [ 'el-min', 'el_min' ],
        [ 'el-max', 'el_max' ],
        [ 'az-center', 'az_center' ],
        [ 'az-halfwidth', 'az_halfwidth' ],
      ].each do |a|
        p.send( "#{a[1]}=", @parsed[a[0]].to_f.to_rad ) if @parsed[a[0]]
      end
      p.plot( @parsed['device'], @parsed['output'] )
      if @parsed['datadir'] then
        p.store_files( @parsed['datadir'] )
      elsif @parsed['output'] then
        p.store_file( @parsed['output'], '.' )
      end
    end

    # a String of configuration
    def to_conf( what = Plot )
      if Class != what.class then
        what = what.class
      end
      if Allocation == what then
        _allocation_to_conf
      elsif Plot == what then
        _plot_to_conf
      else
        raise ArgumentError, "#{what} cannot be conveted to a Conf"
      end
    end

    def _allocation_to_conf
      r = <<"_END"
# observatory
#{self['location'][-1].to_s}
_END
      r << self['lon'][-1].to_s + "\n" unless self['lon'].empty?
      r << self['lat'][-1].to_s + "\n" unless self['lat'].empty?
      r << <<"_END"

# time span
#{self['start'][-1].to_s}
#{self['finish'][-1].to_s}
_END
      r
    end

    private :_allocation_to_conf

    def _plot_to_conf
      r = _allocation_to_conf + "\n"
      s = ''
      %w( plotter device output datadir el-min el-max az-center az-halfwidth ).each do |key|
        s << self[key][-1].to_s + "\n" unless self[key].empty?
      end
      unless s.empty? then
        r += "# plotting options\n" + s + "\n"
      end

      r << "# stars\n"
      self['Star'].each do |c|
        r << c.omit_key.to_s + "\n"
      end
      r
    end

  end

  class Allocation
    # a String of configuration,
    # making use of original configuraion if +conf+ supplied.
    def to_conf( conf = nil )
      if conf then
        conf.to_conf( self )
      else
        Conf::to_conf( self )
      end
    end
  end

  class Plot
    # a String of configuration,
    # making use of original configuraion if +conf+ supplied.
    def to_conf( conf = nil )
      if conf then
        conf.to_conf( self )
      else
        Conf::to_conf( self )
      end
    end
  end

end
