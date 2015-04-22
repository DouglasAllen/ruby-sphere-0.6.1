module Sphere
  # generalize arguments of some methods
  module MethodArgs

	  # gets ( +lst+, +lat+ ) or ( +time+, +lon+, +lat+ )
	  # and returns [ +lst+, +lat+ ]
	  def self::args_to_lst_and_lat( *args )
		  case args.size
		  when 2
			  lst = args.shift
			  lat = args.shift
		  when 3
			  time = args.shift
			  lon = args.shift
			  lat = args.shift
			  lst = Sphere::lst( time, lon )
		  else
			  raise ArgumentError, "wrong number of arguments(#{args.size} for 2-3)"
		  end
		  [ lst, lat ]
	  end

	  # gets ( +time+, +lon+, +lat+ )
	  # and returns [ +time+, +lon+, +lat+ ]
	  def self::args_to_time_lon_lat( time, lon, lat )
		  [ time, lon, lat ]
	  end
  end

  class << MethodArgs
    alias args_to_lst_and_lat_orig args_to_lst_and_lat    
	  alias args_to_time_lon_lat_orig args_to_time_lon_lat
	end
	module MethodArgs
	  # gets ( +lst+, +lat+ ), ( +time+, +lon+, +lat+ ), or
	  # ( +time+, +observatoty+ ) and returns [ +lst+, +lat+ ]
	  def self::args_to_lst_and_lat( *args )
		  if 2 == args.size and args[1].respond_to?( :lon ) and args[1].respond_to?( :lat ) then
			  args = [ args[0], args[1].lon, args[1].lat ]
		  end
		  self::args_to_lst_and_lat_orig( *args )
	  end
	

	  # gets ( +time+, +lon+, +lat+ ), or
	  # ( +time+, +observatoty+ ) and returns [ +time+, +lon+, +lat+ ]
	  def self::args_to_time_lon_lat( *args )
		  if 2 == args.size and args[1].respond_to?( :lon ) and args[1].respond_to?( :lat ) then
			  args = [ args[0], args[1].lon, args[1].lat ]
		  end
		  self::args_to_time_lon_lat_orig( *args )
	  end
	end
end
	
	
