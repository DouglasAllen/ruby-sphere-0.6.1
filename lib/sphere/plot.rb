require_relative 'conf'

module Sphere
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