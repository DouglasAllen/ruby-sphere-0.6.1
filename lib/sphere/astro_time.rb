#
# conf.rb: a class to handle configuration files
#
# $Id: conf.rb,v 1.19 2006/08/30 09:24:02 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

require 'time'
#~ require_relative 'az_el'
#~ require_relative 'observatory'
#~ require_relative 'allocation'
#~ require_relative 'star'
#~ require_relative 'gnuplot'
#~ require_relative 'sphere'

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
end
