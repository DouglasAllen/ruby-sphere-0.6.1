module Sphere
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
end