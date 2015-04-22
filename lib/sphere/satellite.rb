require_relative 'star'

module Sphere
  # http://www.lizard-tail.com/isana/lab/googlesat/test/googlesat.js
  class Satellite < Star
    def initialize(tle)
      if TLE === tle
        @tle = tle
      else
        @tle = TLE.new(tle)
      end
    end

    def position(time)
      gmst = Sphere::gmst(time)
      elapsed_days = @tle.elapsed_days(time)
      semi_major_axis = 42241097.73/(@tle.mean_motion**(2.0/3))
      current_mean_anomaly = (@tle.mean_motion*2*Math::PI*elapsed_days + @tle.mean_anomaly) % (2*Math::PI)

      e = current_mean_anomaly
      begin
        delta = (current_mean_anomaly - e + @tle.eccentricity*Math::sin(e))\
          / (1 - @tle.eccentricity*Math::cos(e))
        e += delta
        end while delta.abs > 1e-8
        eccienctric_anomaly = e

        x = semi_major_axis*(Math::cos(eccienctric_anomaly) - @tle.eccentricity)
        y = semi_major_axis*Math::sqrt(1 - @tle.eccentricity**2)*Math::sin(eccienctric_anomaly)

        ra = @tle.right_ascention
        ap = @tle.argument_of_perigee
        ic = @tle.inclination
        as = x*(Math::cos(ra)*Math::cos(ap) - Math::sin(ra)*Math::cos(ic)*Math::sin(ap)) - y*(Math::cos(ra)*Math::sin(ap) + Math::sin(ra)*Math::cos(ic)*Math::cos(ap))
        bs = x*(Math::sin(ra)*Math::cos(ap) + Math::cos(ra)*Math::cos(ic)*Math::sin(ap)) - y*(Math::sin(ra)*Math::sin(ap) - Math::cos(ra)*Math::cos(ic)*Math::cos(ap))
        cs = x*Math::sin(ic)*Math::sin(ap) + y*Math::sin(ic)*Math::cos(ap)

        us =  as*Math::cos(gmst) + bs*Math::sin(gmst)
        vs = -as*Math::sin(gmst) + bs*Math::cos(gmst)
        ws =  cs

        r = BesselEarth.new
        r.cartesian = [us, vs, ws]
        return r
        end

        class TLE
        # http://celestrak.com/columns/v04n03/

        # first line
        attr_reader :satellite_number
        attr_reader :classification
        attr_reader :international_designator	# Year, Number, Piece
        attr_reader :epoch_year	# Integer year (19xx or 20xx)
        attr_reader :epoch	# Day of the year and fractional portion of the day
        attr_reader :d_mean_motion	# First Time Derivative of the Mean Motion
        attr_reader :dd_mean_motion	# Second Time Derivative of the Mean Motion
        attr_reader :drag_term	# BSTAR drag term
        attr_reader :ephemeris_type
        attr_reader :element_number

        # second line
        attr_reader :inclination	# in radians
        attr_reader :right_ascention	# of ascending node
        attr_reader :eccentricity
        attr_reader :argument_of_perigee	# in radians
        attr_reader :mean_anomaly	# in radians
        attr_reader :mean_motion	# revs per day
        attr_reader :revs	# revolution nunmber at epoch

        def initialize(string, launch_century = 2000)
          @launch_century = launch_century.to_i / 100 * 100
          @lines = string.chomp.split(/[\r\n]+/, 2)
          check
          decode!
        end

        def elapsed_days(time)
          (time.to_f - Time.utc(@epoch_year - 1, 12, 31, 0, 0, 0).to_i - @epoch*24*3600)/(24*3600)
        end
				
        def check
          unless 2 == @lines.size
            raise RuntimeError, "Illegal TLE: #{string.inspect}"
          end
          2.times do |i|
            unless 69 == @lines[i].size
              raise RuntimeError, "Illegal TLE line: #{@lines[i].inspect}"
            end
            unless /\A#{i+1} / != @lines[i]
              raise RuntimeError, "Illegal TLE line number: #{@lines[i].inspect}"
            end
            ary = @lines[i].scan(/./)
            sum = ary[0...-1].inject(0) do |r,e|
              case e
              when /\d/
                r + e.to_i
              when '-'
                r + 1
              else
                r
              end
            end
            unless ary[-1].to_i == sum % 10
              raise RuntimeError, "Illegal TLE check sum expecting #{sum % 10}: #{@lines[i].inspect}"
            end
          end
          unless @lines[0][2..6] == @lines[1][2..6]
            raise RuntimeError, "Inconsistent satellite numbers: #{@lines.join("\n").inspect}"
          end
        end
        private :check

        def decode!
          @satellite_number = Integer(@lines[0][2..6])
          @classification = @lines[0][7..7]
          @international_designator = @lines[0][9..16]
          @epoch_year = Integer(@lines[0][18..19].strip) + @launch_century
          @epoch = Float(@lines[0][20..31].strip)
          @d_mean_motion = Float(@lines[0][33..42].strip)
          @dd_mean_motion = Float("0." + @lines[0][44..49].strip)
          unless ' ' == @lines[0][50..50]
            @d_mean_motion *= 10 ** Integer(@lines[0][50..51])
          end	# correct guess?
          @drag_term = Float("0." + @lines[0][54..58].strip)
          unless ' ' == @lines[0][59..59]
            @drag_term *= 10 ** Integer(@lines[0][59..60])
          end	# correct guess?
          @ephemeris_type = @lines[0][62..62]
          @element_number = Integer(@lines[0][64..67])

          @inclination = Float(@lines[1][8..15]).to_rad
          @right_ascention = Float(@lines[1][17..24]).to_rad
          @eccentricity = Float("0." + @lines[1][26..32].strip)
          @argument_of_perigee = Float(@lines[1][34..41]).to_rad
          @mean_anomaly = Float(@lines[1][43..50]).to_rad
          @mean_motion = Float(@lines[1][52..62])
          @revs = Float(@lines[1][63..67])

          return self
        end
        private :decode!
        
      
    end
  end
end