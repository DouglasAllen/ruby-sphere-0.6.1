#
# alloction.rb: a class of allocated observation time
#
# $Id: allocation.rb,v 1.8 2006/05/17 05:51:07 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

module Sphere
  #
  # Observatory time allocated for this observation.
  #
  class Allocation
    # starting Time
    attr_reader :from
    # ending Time
    attr_reader :to
    # time zone as String
    attr_reader :tz
    # Observatory
    attr_reader :observatory
    # comment as String
    attr_reader :comment

    # from, to: duration as Time
    # observatory: Observatory
    # comment: comment as String
    def initialize( from, to, observatory = nil, comment = nil )
      @from, @to = from, to
      @tz = @from.localtime.strftime( '%Z' )
      @observatory = observatory
      @comment = comment
    end

    # runs block giving Time for each secstep
    def each_sec( secstep, &block )
      _each_sec( secstep, @from, &block )
    end

    # Array of Time for each secstep
    def each_secs( secstep )
      r = []
      each_sec( secstep ) do |time|
        r << time
      end
      r
    end

    # runs block giving Time for each secstep rounded
    def each_sec_on( secstep, &block )
      local = @from.localtime
      current = Time.local( 0, 0, 0, *local.to_a[ 3..-1 ] ) + ( ( local.hour * 3600.0 + local.min * 60 + local.sec + local.usec * 1e-6 ).div( secstep ) + 1 ) * secstep
      _each_sec( secstep, current, &block )
    end

    # Array of Time for each secstep rounded
    def each_secs_on( secstep )
      r = []
      each_sec_on( secstep ) do |time|
        r << time
      end
      r
    end

    # duration in seconds
    def duration
      @to - @from
    end

    # middle time
    def middle
      @from + duration / 2
    end

    # Array of Time of sunrises
    def sunrises( blank = 0 )
      _sun_times( blank ){ |*args| Sphere::sunrise( *args ) }
    end
    # Array of Time of sunsets
    def sunsets( blank = 0 )
      _sun_times( blank ){ |*args| Sphere::sunset( *args ) }
    end
    def civil_twilight_begins( blank = 0 )
      _sun_times( blank ){ |*args| Sphere::civil_twilight_begin( *args ) }
    end
    def civil_twilight_ends( blank = 0 )
      _sun_times( blank ){ |*args| Sphere::civil_twilight_end( *args ) }
    end
    def nautical_twilight_begins( blank = 0 )
      _sun_times( blank ){ |*args| Sphere::nautical_twilight_begin( *args ) }
    end
    def nautical_twilight_ends( blank = 0 )
      _sun_times( blank ){ |*args| Sphere::nautical_twilight_end( *args ) }
    end
    def astronomical_twilight_begins( blank = 0 )
      _sun_times( blank ){ |*args| Sphere::astronomical_twilight_begin( *args ) }
    end
    def astronomical_twilight_ends( blank = 0 )
      _sun_times( blank ){ |*args| Sphere::astronomical_twilight_end( *args ) }
    end

    def _each_sec( secstep, current, extend = 0, &block )
      while current <= @to + extend do
        yield( current )
        current += secstep
      end
    end
    private :_each_sec

    def _sun_times( blank = 0, &block )
      r = Array.new
      aday = 3600*24
      _each_sec( aday, @from - aday, aday ) do |date|
        t = yield( date, @observatory.lon, @observatory.lat )
        if @from + blank <= t and t <= @to - blank then
          r << t
        end
      end
      r
    end
    private :_sun_times

  end
end
